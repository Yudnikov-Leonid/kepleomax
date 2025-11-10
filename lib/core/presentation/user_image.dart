import 'package:flutter/material.dart';
import 'package:kepleomax/main.dart';

class UserImage extends StatelessWidget {
  const UserImage({
    required this.url,
    this.size,
    this.isLoading = false,
    super.key,
  });

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
            ? ColoredBox(color: Colors.grey)
            : url == null || url!.isEmpty
            ? DefaultUserIcon()
            : Image.network(flavor.imageUrl + url!, fit: BoxFit.cover),
      ),
    );
  }
}

class DefaultUserIcon extends StatelessWidget {
  const DefaultUserIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Colors.grey);
  }
}
