import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_dtos.g.dart';

@JsonSerializable()
class UploadFileResponseDto {

  UploadFileResponseDto({required this.data, required this.message});

  factory UploadFileResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UploadFileResponseDtoFromJson(json);
  final UploadFileResponseData? data;
  final String? message;

  Map<String, dynamic> toJson() => _$UploadFileResponseDtoToJson(this);
}

@JsonSerializable()
class UploadFileResponseData {

  UploadFileResponseData({required this.path});

  factory UploadFileResponseData.fromJson(Map<String, dynamic> json) =>
      _$UploadFileResponseDataFromJson(json);
  final String path;

  Map<String, dynamic> toJson() => _$UploadFileResponseDataToJson(this);
}
