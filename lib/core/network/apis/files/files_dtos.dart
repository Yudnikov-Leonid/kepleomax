import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_dtos.g.dart';

@JsonSerializable()
class UploadFileResponseDto {
  final UploadFileResponseData? data;
  final String? message;

  UploadFileResponseDto({required this.data, required this.message});

  factory UploadFileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UploadFileResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UploadFileResponseDtoToJson(this);
}

@JsonSerializable()
class UploadFileResponseData {
  final String path;

  UploadFileResponseData({required this.path});

  factory UploadFileResponseData.fromJson(Map<String, dynamic> json) =>
      _$UploadFileResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$UploadFileResponseDataToJson(this);
}
