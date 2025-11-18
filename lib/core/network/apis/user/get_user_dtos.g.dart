// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_dtos.dart';

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

GetUsersDto _$GetUsersDtoFromJson(Map<String, dynamic> json) => GetUsersDto(
  data: (json['data'] as List<dynamic>)
      .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$GetUsersDtoToJson(GetUsersDto instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};

FCMTokenRequestDto _$FCMTokenRequestDtoFromJson(Map<String, dynamic> json) =>
    FCMTokenRequestDto(token: json['token'] as String);

Map<String, dynamic> _$FCMTokenRequestDtoToJson(FCMTokenRequestDto instance) =>
    <String, dynamic>{'token': instance.token};
