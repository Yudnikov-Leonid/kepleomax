import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_dtos.g.dart';

@JsonSerializable()
class MessagesResponse {
  final List<MessageDto>? data;
  final String? message;

  MessagesResponse({required this.data, required this.message});

  factory MessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$MessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessagesResponseToJson(this);
}

class MessageDto extends Equatable {
  final int id;
  final int chatId;
  final int senderId;
  final bool isCurrentUser;
  final String message;
  final bool isRead;
  final int createdAt;
  final int? editedAt;
  final bool fromCache;

  const MessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.isCurrentUser,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.editedAt,
    required this.fromCache,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json, {bool fromCache = false}) =>
      MessageDto(
        id: json['id'],
        chatId: json['chat_id'],
        senderId: json['sender_id'],
        isCurrentUser: json['is_current_user'] == null && json['user'] == null
            ? throw Exception('is_current_user or user should be provided')
            : json['user']?['is_current'] ??
                  (json['is_current_user'] == 1
                      ? true
                      : json['is_current_user'] == 0
                      ? false
                      : json['is_current_user']),
        message: json['message'],
        isRead: json['is_read'] == 1
            ? true
            : json['is_read'] == 0
            ? false
            : json['is_read'],
        createdAt: json['created_at'],
        editedAt: json['edited_at'],
        fromCache: fromCache,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chat_id': chatId,
    'sender_id': senderId,
    'is_current_user': isCurrentUser,
    'message': message,
    'is_read': isRead,
    'created_at': createdAt,
    'edited_at': editedAt,
  };

  Map<String, dynamic> toLocalJson() => {
    'id': id,
    'chat_id': chatId,
    'sender_id': senderId,
    'is_current_user': isCurrentUser ? 1 : 0,
    'message': message,
    'is_read': isRead ? 1 : 0,
    'created_at': createdAt,
    'edited_at': editedAt,
  };

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    isCurrentUser,
    message,
    isRead,
    createdAt,
    editedAt,
  ];
}
