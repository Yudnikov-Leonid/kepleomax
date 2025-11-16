// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chats_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
  data: json['data'] == null
      ? null
      : ChatDto.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};

ChatsResponse _$ChatsResponseFromJson(Map<String, dynamic> json) =>
    ChatsResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ChatDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ChatsResponseToJson(ChatsResponse instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};

ChatDto _$ChatDtoFromJson(Map<String, dynamic> json) => ChatDto(
  id: (json['id'] as num).toInt(),
  otherUser: UserDto.fromJson(json['other_user'] as Map<String, dynamic>),
  lastMessage: json['last_message'] == null
      ? null
      : MessageDto.fromJson(json['last_message'] as Map<String, dynamic>),
  unreadCount: (json['unread_count'] as num).toInt(),
);

Map<String, dynamic> _$ChatDtoToJson(ChatDto instance) => <String, dynamic>{
  'id': instance.id,
  'other_user': instance.otherUser,
  'last_message': instance.lastMessage,
  'unread_count': instance.unreadCount,
};
