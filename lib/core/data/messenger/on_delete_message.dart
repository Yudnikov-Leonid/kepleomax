part of 'messenger_repository.dart';

extension _OnDeleteMessageExtension on MessengerRepositoryImpl {
  void _onDeletedMessage(DeletedMessageUpdate update) {
    _messagesLocal.deleteById(update.deletedMessage.id);

    if (_lastMessagesCollection != null &&
        _lastMessagesCollection!.chatId == update.chatId) {
      final newList = _lastMessagesCollection!.messages.where(
            (m) => m.id != update.deletedMessage.id,
      );
      _emitMessages(newList);
    }

    if (_lastChatsCollection != null) {
      final newChats = List<Chat>.from(_lastChatsCollection!.chats);
      final affectedChatIndex = newChats.indexWhere(
            (chat) => chat.id == update.chatId,
      );
      if (affectedChatIndex != -1) {
        final decreaseUnreadCount =
            !update.deletedMessage.isCurrentUser && !update.deletedMessage.isRead;
        final newUnreadCount =
            newChats[affectedChatIndex].unreadCount - (decreaseUnreadCount ? 1 : 0);
        if (update.newLastMessage != null) {
          newChats[affectedChatIndex] = newChats[affectedChatIndex].copyWith(
            lastMessage: Message.fromDto(update.newLastMessage!),
            unreadCount: newUnreadCount,
          );
        } else {
          newChats[affectedChatIndex] = newChats[affectedChatIndex].copyWith(
            unreadCount: newUnreadCount,
          );
        }
        newChats.sort(
              (a, b) =>
          (b.lastMessage?.createdAt.millisecondsSinceEpoch ?? 0) -
              (a.lastMessage?.createdAt.millisecondsSinceEpoch ?? 0),
        );
        _emitChatsCollection(ChatsCollection(chats: newChats));
      }
    }
  }
}