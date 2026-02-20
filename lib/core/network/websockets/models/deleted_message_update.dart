import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

class DeletedMessageUpdate {

  const DeletedMessageUpdate({
    required this.chatId,
    required this.deletedMessage,
    required this.newLastMessage,
    this.deleteChat = false,
  });

  factory DeletedMessageUpdate.fromJson(Map<String, dynamic> json) =>
      DeletedMessageUpdate(
        chatId: json['chat_id'] as int,
        deletedMessage: MessageDto.fromJson(json['message'] as Map<String, dynamic>),
        newLastMessage: json['new_last_message'] == null
            ? null
            : MessageDto.fromJson(json['new_last_message'] as Map<String, dynamic>, fromCache: false),
        deleteChat: json['delete_chat'] as bool? ?? false,
      );
  final int chatId;
  final MessageDto deletedMessage;
  final MessageDto? newLastMessage;
  final bool deleteChat;
}
