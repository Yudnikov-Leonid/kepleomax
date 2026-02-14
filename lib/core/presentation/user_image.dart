import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_cached_image.dart';
import 'package:kepleomax/generated/images_keys.images_keys.dart';
import 'package:kepleomax/core/flavor.dart';

class UserImage extends StatelessWidget {
  const UserImage({required this.url, this.size, this.isLoading = false, super.key});

  final String? url;
  final double? size;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
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
