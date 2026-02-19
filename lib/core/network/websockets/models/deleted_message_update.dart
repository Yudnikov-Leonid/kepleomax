import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

class DeletedMessageUpdate {
  final int chatId;
  final MessageDto deletedMessage;
  final MessageDto? newLastMessage;
  final bool deleteChat;

  const DeletedMessageUpdate({
    required this.chatId,
    required this.deletedMessage,
    required this.newLastMessage,
    this.deleteChat = false,
  });

  factory DeletedMessageUpdate.fromJson(Map<String, dynamic> json) =>
      DeletedMessageUpdate(
        chatId: json['chat_id'],
        deletedMessage: MessageDto.fromJson(json['message']),
        newLastMessage: json['new_last_message'] == null
            ? null
            : MessageDto.fromJson(json['new_last_message'], fromCache: false),
        deleteChat: json['delete_chat'] ?? false,
      );
}
