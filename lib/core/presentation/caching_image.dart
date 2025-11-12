import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class KlmCachedImage extends CachedNetworkImage {
  KlmCachedImage({
    required super.imageUrl,
    bool showProgress = true,
    super.fit,
    super.key,
  }) : super(
         progressIndicatorBuilder: (context, url, downloadProgress) =>
             showProgress ? const SizedBox() : ColoredBox(color: Colors.grey.shade200),
         errorWidget: (context, url, error) => Icon(Icons.error),

       );
}
