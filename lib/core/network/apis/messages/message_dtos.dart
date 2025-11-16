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

@JsonSerializable()
class MessageDto {
  final int id;
  @JsonKey(name: 'chat_id')
  final int chatId;
  @JsonKey(name: 'sender_id')
  final int senderId;
  @JsonKey(name: 'is_current_user')
  final bool isCurrentUser;
  final String message;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'edited_at')
  final String? editedAt;

  MessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.isCurrentUser,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.editedAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
