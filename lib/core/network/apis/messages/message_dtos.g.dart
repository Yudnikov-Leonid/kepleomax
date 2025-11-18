// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagesResponse _$MessagesResponseFromJson(Map<String, dynamic> json) =>
    MessagesResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MessagesResponseToJson(MessagesResponse instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
  id: (json['id'] as num).toInt(),
  chatId: (json['chat_id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  isCurrentUser: json['is_current_user'] as bool?,
  user: json['user'] == null
      ? null
      : UserDto.fromJson(json['user'] as Map<String, dynamic>),
  message: json['message'] as String,
  isRead: json['is_read'] as bool,
  createdAt: json['created_at'] as String,
  editedAt: json['edited_at'] as String?,
);

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'is_current_user': instance.isCurrentUser,
      'user': instance.user,
      'message': instance.message,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
      'edited_at': instance.editedAt,
    };
