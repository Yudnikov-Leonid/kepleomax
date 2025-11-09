// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUserDto _$GetUserDtoFromJson(Map<String, dynamic> json) => GetUserDto(
  data: json['data'] == null
      ? null
      : UserDto.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$GetUserDtoToJson(GetUserDto instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};
