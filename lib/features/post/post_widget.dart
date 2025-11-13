import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kepleomax/core/models/post.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/presentation/caching_image.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/parse_time.dart';
import 'package:kepleomax/core/presentation/photos_preview/photos_preview_screen.dart';
import 'package:kepleomax/core/presentation/user_image.dart';
import 'package:kepleomax/generated/images_keys.images_keys.dart';
import 'package:kepleomax/main.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({required this.post, this.onDelete, super.key});

  final Post post;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: post.isMockLoadingPost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                UserImage(
                  url: post.user.profileImage,
                  size: 34,
                  isLoading: post.isMockLoadingPost,
                ),
                const SizedBox(width: 10),
                Text(
                  post.user.username,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                  ),
                ),
                const Expanded(child: SizedBox()),
                if (post.user.isCurrent) PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {

                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Edit post')),
                    if (onDelete != null) PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete post',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (post.images.isNotEmpty) ...[
            _PostImagesWidget(images: post.images),
            const SizedBox(height: 10),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              post.content,
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    children: [
                      if (!post.isMockLoadingPost) ...[
                        SvgPicture.asset(ImagesKeys.favorite_icon_svg, height: 24),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        post.likesCount.toString(),
                        style: context.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
                Tooltip(
                  message:
                      '${ParseTime.unixTimeToPreciseDate(post.createdAt)}${post.updatedAt == null ? '' : '\nedited: ${ParseTime.unixTimeToPreciseDate(post.updatedAt!)}'}',
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: false,
                  showDuration: Duration(seconds: 5),
                  child: Text(
                    ParseTime.unixTimeToDate(post.createdAt),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PostImagesWidget extends StatelessWidget {
  const _PostImagesWidget({required List<String> images}) : _images = images;

  final List<String> _images;

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenSize.width;
    final double maxHeight = _images.length == 1
        ? 700
        : _images.length == 4
        ? screenWidth
        : 450;
    final double spaceBetween = 4;
    final sizeOffset = spaceBetween / 2;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Builder(
        builder: (context) {
          switch (_images.length) {
            case 1:
              return _PhotoWidget(
                width: screenWidth,
                index: 0,
                imagesToOpen: _images,
              );
            case 2:
              return Row(
                children: [
                  _PhotoWidget(
                    width: screenWidth * 0.5 - sizeOffset,
                    height: maxHeight,
                    index: 0,
                    imagesToOpen: _images,
                  ),
                  SizedBox(width: spaceBetween),
                  _PhotoWidget(
                    width: screenWidth * 0.5 - sizeOffset,
                    height: maxHeight,
                    index: 1,
                    imagesToOpen: _images,
                  ),
                ],
              );
            case 3:
              return Row(
                children: [
                  _PhotoWidget(
                    width: screenWidth * 0.6 - sizeOffset,
                    height: maxHeight,
                    index: 0,
                    imagesToOpen: _images,
                  ),
                  SizedBox(width: spaceBetween),
                  Column(
                    children: [
                      _PhotoWidget(
                        width: screenWidth * 0.4 - sizeOffset,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: 1,
                        imagesToOpen: _images,
                      ),
                      SizedBox(height: spaceBetween),
                      _PhotoWidget(
                        width: screenWidth * 0.4 - sizeOffset,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: 2,
                        imagesToOpen: _images,
                      ),
                    ],
                  ),
                ],
              );
            case 4:
              return GridView.count(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: spaceBetween,
                crossAxisSpacing: spaceBetween,
                children: _images
                    .mapIndexed(
                      (i, url) => _PhotoWidget(
                        width: screenWidth * 0.5 - sizeOffset,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: i,
                        imagesToOpen: _images,
                      ),
                    )
                    .toList(),
              );
            case 5:
              return Column(
                children: [
                  Row(
                    children: [
                      _PhotoWidget(
                        width: screenWidth * 0.5 - sizeOffset,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: 0,
                        imagesToOpen: _images,
                      ),
                      SizedBox(width: spaceBetween),
                      _PhotoWidget(
                        width: screenWidth * 0.5 - sizeOffset,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: 1,
                        imagesToOpen: _images,
                      ),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PhotoWidget(
                        width: screenWidth ~/ 3 - sizeOffset * 1.5,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: 2,
                        imagesToOpen: _images,
                      ),
                      SizedBox(width: spaceBetween),
                      _PhotoWidget(
                        width: screenWidth ~/ 3 - sizeOffset * 1.5,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: 3,
                        imagesToOpen: _images,
                      ),
                      SizedBox(width: spaceBetween),
                      _PhotoWidget(
                        width: screenWidth ~/ 3 - sizeOffset * 1.5,
                        height: maxHeight * 0.5 - sizeOffset,
                        index: 4,
                        imagesToOpen: _images,
                      ),
                    ],
                  ),
                ],
              );
          }

          return _PhotosRow(images: _images, maxHeight: maxHeight);
        },
      ),
    );
  }
}

class _PhotosRow extends StatefulWidget {
  const _PhotosRow({required this.images, required this.maxHeight});

  final List<String> images;
  final double maxHeight;

  @override
  State<_PhotosRow> createState() => _PhotosRowState();
}

class _PhotosRowState extends State<_PhotosRow> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenSize.width;
    final maxHeight = widget.maxHeight;

    return Stack(
      children: [
        SizedBox(
          height: maxHeight,
          width: screenWidth,
          child: PageView(
            controller: PageController(initialPage: 0),
            onPageChanged: (newIndex) {
              setState(() {
                _index = newIndex;
              });
            },
            children: widget.images
                .mapIndexed(
                  (i, image) => _PhotoWidget(
                    width: screenWidth,
                    height: maxHeight,
                    index: i,
                    imagesToOpen: widget.images,
                  ),
                )
                .toList(),
          ),
        ),
        Positioned(
          right: 7,
          top: 7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
            child: Text(
              '${_index + 1}/${widget.images.length}',
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoWidget extends StatelessWidget {
  const _PhotoWidget({
    required this.width,
    this.height,
    required this.index,
    required this.imagesToOpen,
  });

  final double width;
  final double? height;
  final int index;
  final List<String> imagesToOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppNavigator.of(context)!.showGeneralDialog(
          context,
          PhotosPreviewScreen(urls: imagesToOpen, initialIndex: index),
        );
      },
      child: SizedBox(
        width: width,
        height: height,
        child: KlmCachedImage(
          imageUrl: flavor.imageUrl + imagesToOpen[index],
          showProgress: true,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
