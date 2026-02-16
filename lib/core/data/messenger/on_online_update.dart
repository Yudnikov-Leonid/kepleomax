part of 'messenger_repository.dart';

extension _OnOnlineStatusUpdateExtension on MessengerRepositoryImpl {
  void _onOnlineUpdate(OnlineStatusUpdate update) {
    _usersLocal.updateOnlineStatus(update);

    if (_lastChatsCollection != null) {
      final newChats = <Chat>[];
      for (final chat in _lastChatsCollection!.chats) {
        if (chat.otherUser.id == update.userId) {
          newChats.add(
            chat.copyWith(
              otherUser: chat.otherUser.copyWith(
                isOnline: update.isOnline,
                lastActivityTime: update.lastActivityTime,
              ),
            ),
          );
          continue;
        }
        newChats.add(chat);
      }
      
      _emitChatsCollection(ChatsCollection(chats: newChats));
    }
  }
}
