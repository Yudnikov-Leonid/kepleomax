// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetProfileResponseDto _$GetProfileResponseDtoFromJson(
  Map<String, dynamic> json,
) => GetProfileResponseDto(
  data: json['data'] == null
      ? null
      : GetProfileDataDto.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$GetProfileResponseDtoToJson(
  GetProfileResponseDto instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};

EditProfileRequestDto _$EditProfileRequestDtoFromJson(
  Map<String, dynamic> json,
) => EditProfileRequestDto(
  username: json['username'] as String,
  description: json['description'] as String,
  profileImage: json['profileImage'] as String,
);

Map<String, dynamic> _$EditProfileRequestDtoToJson(
  EditProfileRequestDto instance,
) => <String, dynamic>{
  'username': instance.username,
  'description': instance.description,
  'profileImage': instance.profileImage,
};

GetProfileDataDto _$GetProfileDataDtoFromJson(Map<String, dynamic> json) =>
    GetProfileDataDto(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      description: json['description'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetProfileDataDtoToJson(GetProfileDataDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'description': instance.description,
      'user': instance.user,
    };
