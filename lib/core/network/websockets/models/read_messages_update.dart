class ReadMessagesUpdate {

  const ReadMessagesUpdate({
    required this.chatId,
    required this.senderId,
    required this.isCurrentUser,
    required this.messagesIds,
  });

  factory ReadMessagesUpdate.fromJson(Map<String, dynamic> json) =>
      ReadMessagesUpdate(
        chatId: json['chat_id'] as int,
        senderId: json['sender_id'] as int,
        isCurrentUser: json['is_current_user'] as bool,
        messagesIds: (json['messages_ids'] as List<dynamic>)
            .map<int>((id) => int.parse(id.toString()))
            .toList(),
      );
  final int chatId;
  final int senderId;
  final bool isCurrentUser;
  final List<int> messagesIds;
}