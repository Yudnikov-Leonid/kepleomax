import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_cached_image.dart';
import 'package:kepleomax/generated/images_keys.images_keys.dart';
import 'package:kepleomax/core/flavor.dart';

class UserImage extends StatelessWidget {
  const UserImage({
    required this.url,
    this.size,
    this.isLoading = false,
    this.showIsOnline,
    this.onlineIconSize = 10,
    this.onlineIconPadding = 4,
    super.key,
  });

  final String? url;
  final double? size;
  final bool isLoading;

  /// online
  final bool? showIsOnline;
  final double onlineIconSize;
  final double onlineIconPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SizedBox(
              height: size ?? constraints.maxHeight,
              width: size ?? constraints.maxWidth,
              child: ClipOval(
                child: isLoading
                    ? const ColoredBox(color: Colors.grey)
                    : url == null || url!.isEmpty
                    ? const DefaultUserIcon()
                    : KlmCachedImage(
                        imageUrl: flavor.imageUrl + url!,
                        width: context.imageMaxWidth,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            // Positioned(
            //   bottom: onlineIconPadding / 4,
            //   right: 0,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            //     decoration: BoxDecoration(
            //       color: Colors.grey,
            //       borderRadius: BorderRadius.circular(16),
            //       border: Border.all(
            //         color: Colors.white,
            //         width: 2,
            //         strokeAlign: BorderSide.strokeAlignOutside,
            //       ),
            //     ),
            //     child: Text(
            //       '32 min',
            //       style: TextStyle(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              bottom: onlineIconPadding / 4,
              right: onlineIconPadding,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: showIsOnline == true ? 1 : 0,
                child: Container(
                  height: onlineIconSize,
                  width: onlineIconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DefaultUserIcon extends StatelessWidget {
  const DefaultUserIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ColoredBox(
          color: Colors.grey.shade400,
          child: Padding(
            padding: EdgeInsets.only(top: constraints.maxHeight * 0.2),
            child: SvgPicture.asset(ImagesKeys.user_default_icon_svg),
          ),
        );
      },
    );
  }
}
