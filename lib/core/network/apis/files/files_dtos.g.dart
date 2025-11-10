// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'files_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFileResponseDto _$UploadFileResponseDtoFromJson(
  Map<String, dynamic> json,
) => UploadFileResponseDto(
  data: json['data'] == null
      ? null
      : UploadFileResponseData.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$UploadFileResponseDtoToJson(
  UploadFileResponseDto instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};

UploadFileResponseData _$UploadFileResponseDataFromJson(
  Map<String, dynamic> json,
) => UploadFileResponseData(path: json['path'] as String);

Map<String, dynamic> _$UploadFileResponseDataToJson(
  UploadFileResponseData instance,
) => <String, dynamic>{'path': instance.path};
