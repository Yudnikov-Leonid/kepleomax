// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  profileImage: json['profile_image'] as String?,
  isCurrent: json['is_current'] as bool,
  isOnline: json['isOnline'] as bool,
  lastActivityTime: (json['lastActivityTime'] as num).toInt(),
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'profile_image': instance.profileImage,
  'is_current': instance.isCurrent,
  'isOnline': instance.isOnline,
  'lastActivityTime': instance.lastActivityTime,
};
