part of 'messenger_repository.dart';

extension _OnNewMessageExtension on MessengerRepositoryImpl {
  void _onNewMessage(MessageDto messageDto) async {
    _messagesLocal.insert(messageDto);

    if (_lastMessagesCollection != null &&
        _lastMessagesCollection!.chatId == messageDto.chatId) {
      final newList = <Message>[
        Message.fromDto(messageDto),
        ..._lastMessagesCollection!.messages,
      ];
      _emitMessages(newList);
    }

    if (_lastChatsCollection != null) {
      final newChats = List<Chat>.from(_lastChatsCollection!.chats);
      final affectedChat = newChats.firstWhereOrNull(
        (chat) => chat.id == messageDto.chatId,
      );
      if (affectedChat != null) {
        _chatsLocal.increaseUnreadCountBy1(affectedChat.id);
        newChats.remove(affectedChat);
        newChats.insert(
          0,
          affectedChat.copyWith(
            lastMessage: Message.fromDto(messageDto),
            lastTypingActivityTime: null,
            unreadCount:
                affectedChat.unreadCount +
                (!messageDto.isCurrentUser && !messageDto.isRead ? 1 : 0),
          ),
        );
        _emitChatsCollection(ChatsCollection(chats: newChats));
      } else {
        /// it's a new chat
        final newChat = await _chatsApi.getChatWithId(messageDto.chatId);
        if (newChat == null) return;
        _chatsLocal.insert(newChat);
        _emitChatsCollection(
          ChatsCollection(
            chats: [Chat.fromDto(newChat, fromCache: false), ...newChats],
          ),
        );
      }
    }
  }
}
