class TypingActivityUpdate {
  final int chatId;
  final bool isTyping;

  const TypingActivityUpdate({required this.chatId, required this.isTyping});

  factory TypingActivityUpdate.fromJson(
    Map<String, dynamic> json, {
    required bool isTyping,
  }) => TypingActivityUpdate(chatId: json['chat_id'], isTyping: isTyping);
}
