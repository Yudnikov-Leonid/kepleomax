// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshRequestDto _$RefreshRequestDtoFromJson(Map<String, dynamic> json) =>
    RefreshRequestDto(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestDtoToJson(RefreshRequestDto instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

RefreshResponseDto _$RefreshResponseDtoFromJson(Map<String, dynamic> json) =>
    RefreshResponseDto(accessToken: json['accessToken'] as String);

Map<String, dynamic> _$RefreshResponseDtoToJson(RefreshResponseDto instance) =>
    <String, dynamic>{'accessToken': instance.accessToken};
