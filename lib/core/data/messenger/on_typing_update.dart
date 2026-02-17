part of 'messenger_repository.dart';

extension _OnTypingUpdateExtension on MessengerRepositoryImpl {
  void _onTypingUpdate(TypingActivityUpdate update) {
    if (_lastChatsCollection != null) {
      final newChats = List.of(_lastChatsCollection!.chats);
      for (int i = 0; i < newChats.length; i++) {
        if (newChats[i].id == update.chatId) {
          newChats[i] = newChats[i].copyWith(lastTypingActivityTime: DateTime.now());
          _emitChatsCollection(ChatsCollection(chats: newChats));
          break;
        }
      }
    }
  }
}
