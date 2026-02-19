import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';

class NewMessageUpdate {
  final MessageDto message;
  final CreatedChatInfo? createdChatInfo;

  NewMessageUpdate({required this.message, required this.createdChatInfo});

  factory NewMessageUpdate.fromJson(Map<String, dynamic> json) => NewMessageUpdate(
    message: MessageDto.fromJson(json['message']),
    createdChatInfo: json['created_chat_info'] == null
        ? null
        : CreatedChatInfo.fromJson(json['created_chat_info']),
  );
}

class CreatedChatInfo {
  final int chatId;
  final Iterable<int> usersIds;

  CreatedChatInfo({required this.chatId, required this.usersIds});

  factory CreatedChatInfo.fromJson(Map<String, dynamic> json) => CreatedChatInfo(
    chatId: json['chat_id'],
    usersIds: json['users_ids'].map<int>((id) => int.parse(id.toString())).toList(),
  );
}
