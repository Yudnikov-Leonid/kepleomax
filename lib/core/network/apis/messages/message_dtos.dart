import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/network/common/user_dto.dart';

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

@JsonSerializable()
class MessageDto {
  final int id;
  @JsonKey(name: 'chat_id')
  final int chatId;
  @JsonKey(name: 'sender_id')
  final int senderId;
  @JsonKey(name: 'is_current_user')
  final bool? isCurrentUser;
  final UserDto? user;
  @JsonKey(name: 'other_user_id')
  final int? otherUserId;
  final String message;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'edited_at')
  final int? editedAt;

  MessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.isCurrentUser,
    required this.user,
    required this.otherUserId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.editedAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) => MessageDto(
    id: json['id'],
    chatId: json['chat_id'],
    senderId: json['sender_id'],
    isCurrentUser: json['is_current_user'] == 1
        ? true
        : json['is_current_user'] == 0
        ? false
        : json['is_current_user'],
    user: json['user'] == null ? null : UserDto.fromJson(json['user']),
    otherUserId: json['other_user_id'],
    message: json['message'],
    isRead: json['is_read'] == 1
        ? true
        : json['is_read'] == 0
        ? false
        : json['is_read'],
    createdAt: json['created_at'],
    editedAt: json['edited_at'],
  );

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
