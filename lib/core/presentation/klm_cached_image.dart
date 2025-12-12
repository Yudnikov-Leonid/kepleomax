import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class KlmCachedImage extends CachedNetworkImage {
  KlmCachedImage({
    required String imageUrl,
    required int? width,
    bool showProgress = false,
    bool showProgressBar = false,
    Color? errorColor,
    super.color,
    super.fit,
    super.key,
  }) : super(
         imageUrl: '$imageUrl${width == null ? '' : '?w=$width'}',
         fadeInDuration: const Duration(milliseconds: 75),
         fadeOutDuration: const Duration(milliseconds: 75),
         placeholder: (context, value) => showProgress
             ? ColoredBox(color: Colors.grey.shade200)
             : showProgressBar
             ? const CircularProgressIndicator(
                 backgroundColor: Colors.transparent,
                 color: KlmColors.primaryColor,
               )
             : const SizedBox(),
         errorWidget: (context, url, error) => Icon(Icons.error, color: errorColor),
       );
}

/// for tests performance
// class KlmCachedImage extends StatelessWidget {
//   KlmCachedImage({
//     required String imageUrl,
//     required int? width,
//     bool showProgress = false,
//     Color? color,
//     BoxFit? fit,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
