// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  profileImage: json['profileImage'] as String,
  isCurrent: json['isCurrent'] as bool,
  fcmTokens: (json['fcmTokens'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'profileImage': instance.profileImage,
  'isCurrent': instance.isCurrent,
  'fcmTokens': instance.fcmTokens,
};
