import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_url_or_file.freezed.dart';

@freezed
abstract class ImageUrlOrFile with _$ImageUrlOrFile {
  @Assert('url != null || file != null', 'Both fields cannot be null')
  @Assert('url != null && file != null', 'Both fields cannot be filled')
  const factory ImageUrlOrFile({String? url, File? file}) = _ImageUrlOrFile;
}