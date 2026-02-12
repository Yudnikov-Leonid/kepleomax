class ReadMessagesUpdate {
  final int chatId;
  final int senderId;
  final bool isCurrentUser;
  final List<int> messagesIds;

  const ReadMessagesUpdate({
    required this.chatId,
    required this.senderId,
    required this.isCurrentUser,
    required this.messagesIds,
  });

  factory ReadMessagesUpdate.fromJson(Map<String, dynamic> json) =>
      ReadMessagesUpdate(
        chatId: json['chat_id'],
        senderId: json['sender_id'],
        isCurrentUser: json['is_current_user'],
        messagesIds: json['messages_ids']
            .map<int>((id) => int.parse(id.toString()))
            .toList(),
      );
}