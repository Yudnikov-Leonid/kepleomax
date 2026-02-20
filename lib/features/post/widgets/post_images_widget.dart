part of '../post_widget.dart';

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
    const double spaceBetween = 4;
    const sizeOffset = spaceBetween / 2;

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