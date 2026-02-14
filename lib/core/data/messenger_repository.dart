import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/data_sources/chats_api_data_sources.dart';
import 'package:kepleomax/core/data/data_sources/messages_api_data_sources.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/read_messages_update.dart';

import 'local_data_sources/chats_local_data_source.dart';
import 'local_data_sources/messages_local_data_source.dart';
import 'models/chats_collection.dart';
import 'models/messages_collection.dart';

abstract class MessengerRepository {
  /// api/db calls
  /// on BlocInit call loadChatsFromCache(); on ws connected call loadChats()
  Future<void> loadChatsFromCache();

  Future<void> loadChats();

  Future<void> loadMessages({required int chatId, bool withCache = true});

  Future<void> loadMoreMessages({required int chatId, required int? toMessageId});

  /// ws streams
  Stream<MessagesCollection> get messagesUpdatesStream;

  Stream<ChatsCollection> get chatsUpdatesStream;
}

class MessengerRepositoryImpl implements MessengerRepository {
  final MessagesWebSocket _webSocket;

  final ChatsApiDataSource _chatsApi;
  final MessagesApiDataSource _messagesApi;

  final MessagesLocalDataSource _messagesLocal;
  final ChatsLocalDataSource _chatsLocal;
  final UsersLocalDataSource _usersLocal;

  final _messagesUpdatesController =
      StreamController<MessagesCollection>.broadcast();
  final _chatsUpdatesController = StreamController<ChatsCollection>.broadcast();
  MessagesCollection? _lastMessagesCollection;
  ChatsCollection? _lastChatsCollection;

  MessengerRepositoryImpl({
    required MessagesWebSocket webSocket,
    required ChatsApiDataSource chatsApiDataSource,
    required MessagesApiDataSource messagesApiDataSource,
    required MessagesLocalDataSource messagesLocalDataSource,
    required ChatsLocalDataSource chatsLocalDataSource,
    required UsersLocalDataSource usersLocalDataSource,
  }) : _webSocket = webSocket,
       _chatsApi = chatsApiDataSource,
       _messagesApi = messagesApiDataSource,
       _chatsLocal = chatsLocalDataSource,
       _messagesLocal = messagesLocalDataSource,
       _usersLocal = usersLocalDataSource {
    _webSocket.newMessageStream.listen(_onNewMessage, cancelOnError: false);
    _webSocket.readMessagesStream.listen(_onReadMessages, cancelOnError: false);
    _webSocket.deletedMessageStream.listen(_onDeletedMessage, cancelOnError: false);
  }

  /// websocket listeners TODO need refactor, maybe put it in another class
  // TODO make tests
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

  // TODO make tests
  void _onReadMessages(ReadMessagesUpdate update) {
    _messagesLocal.readMessages(update);

    if (_lastMessagesCollection != null &&
        _lastMessagesCollection!.chatId == update.chatId) {
      final newList = _lastMessagesCollection!.messages.map(
        (m) => update.messagesIds.contains(m.id) ? m.copyWith(isRead: true) : m,
      );
      _emitMessages(newList);
    }

    if (_lastChatsCollection != null) {
      if (!update.isCurrentUser) {
        _chatsLocal.decreaseUnreadCount(update.chatId, update.messagesIds.length);
        final newList = _lastChatsCollection!.chats.map(
          (chat) => chat.id == update.chatId
              ? chat.copyWith(
                  unreadCount: chat.unreadCount - update.messagesIds.length,
                )
              : chat,
        );
        _emitChatsCollection(ChatsCollection(chats: newList));
      } else if (update.messagesIds.contains(
        _lastChatsCollection!.chats
            .firstWhereOrNull((c) => c.id == update.chatId)
            ?.lastMessage
            ?.id,
      )) {
        final newList = _lastChatsCollection!.chats.map(
          (chat) => chat.id == update.chatId
              ? chat.copyWith(lastMessage: chat.lastMessage!.copyWith(isRead: true))
              : chat,
        );
        _emitChatsCollection(ChatsCollection(chats: newList));
      }
    }
  }

  /// TODO make test
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

  /// emitters
  void _emitMessagesCollection(MessagesCollection collection) {
    _messagesUpdatesController.add(collection);
    _lastMessagesCollection = collection;
  }

  void _emitMessages(Iterable<Message> messages) {
    final collection = _lastMessagesCollection!.copyWith(messages: messages);
    _messagesUpdatesController.add(collection);
    _lastMessagesCollection = collection;
  }

  void _emitChatsCollection(ChatsCollection collection) {
    _chatsUpdatesController.add(collection);
    _lastChatsCollection = collection;
  }

  /// api calls
  @override
  Future<void> loadChatsFromCache() async {
    final cache = await _chatsLocal.getChats();
    _emitChatsCollection(
      ChatsCollection(
        chats: cache
            .map((chat) => Chat.fromDto(chat, fromCache: true))
            .toList(growable: false),
        fromCache: true,
      ),
    );
  }

  @override
  Future<void> loadChats() async {
    //await Future.delayed(const Duration(seconds: 1));
    final chats = await _chatsApi.getChats();
    _emitChatsCollection(
      ChatsCollection(
        chats: chats.map((chat) => Chat.fromDto(chat, fromCache: false)),
        fromCache: false,
      ),
    );
    _chatsLocal.clearAndInsertChats(chats);
    for (final chat in chats) {
      if (chat.lastMessage != null) {
        _messagesLocal.insert(chat.lastMessage!);
      }
      _usersLocal.insert(chat.otherUser);
    }
  }

  @override
  Future<void> loadMessages({required int chatId, bool withCache = true}) async {
    /// add to the stream data from cache
    List<MessageDto> cache = [];
    if (withCache) {
      cache = await _messagesLocal.getMessagesByChatId(chatId);

      /// TODO add unreadMessages
      _emitMessagesCollection(
        MessagesCollection(
          messages: cache.map(Message.fromDto),
          chatId: chatId,
          maintainLoading: true,
        ),
      );
    }

    /// add to the stream data from api
    final apiMessagesDtos = await _messagesApi.getMessages(
      chatId: chatId,
      limit: AppConstants.msgPagingLimit,
    );
    var newList = (await _combineCacheAndApi(
      cache.map(Message.fromDto),
      apiMessagesDtos,
      loadMoreMode: false,
    )).toList();
    if (apiMessagesDtos.isEmpty) {
      /// chat is empty now
      _messagesLocal.deleteAllByChatId(chatId);
    }
    if (newList.isNotEmpty && newList.first.fromCache == true) {
      /// some first messages were deleted
      final firstIndexNotFromCache = newList.indexWhere((m) => !m.fromCache);
      _messagesLocal.deleteAllWithIds(
        newList.sublist(0, firstIndexNotFromCache).map((m) => m.id),
      );
      newList = newList.sublist(firstIndexNotFromCache);
    }
    if (apiMessagesDtos.isNotEmpty &&
        apiMessagesDtos.length < AppConstants.msgPagingLimit) {
      /// last cached messages should be deleted
      newList = newList.where((m) => !m.fromCache).toList();
      _messagesLocal.deleteAllByChatId(chatId);
    }

    /// TODO add unreadMessages
    _emitMessagesCollection(
      MessagesCollection(
        messages: newList,
        chatId: chatId,
        allMessagesLoaded: newList.length < AppConstants.msgPagingLimit,
        maintainLoading: false,
      ),
    );
    _messagesLocal.insertAll(apiMessagesDtos);
  }

  Future<Iterable<Message>> _combineCacheAndApi(
    Iterable<Message> cache,
    Iterable<MessageDto> messages, {
    required bool loadMoreMode,
  }) async {
    if (cache.isEmpty || messages.isEmpty) return messages.map(Message.fromDto);

    final newList = List<Message>.from(cache);

    final firstIndex = newList.indexWhere((e) => e.id == messages.first.id);
    final lastIndex = newList.indexWhere((e) => e.id == messages.last.id);

    //print('MyLog firstIndex: $firstIndex, lastIndex: $lastIndex');

    /// todo handle -1
    if (firstIndex == -1 && lastIndex == -1 && loadMoreMode) {
      /// it's paging and need to add the messages to the top
      /// the case: 0, 1, 2, 3, 4 -> need to add 5, 6, 7
      /// or if it's !loadMoreMode, it can be the case: 5, 6, 7 -> need to add 0, 1, 2
      newList.addAll(messages.map(Message.fromDto));
    } else if (firstIndex == -1 && lastIndex == -1) {
      /// the case: 5, 6, 7 -> need to add 0, 1, 2
      newList.insertAll(0, messages.map(Message.fromDto));
    } else if (lastIndex == -1) {
      /// the case: 0, 1, 2, 3, 4 -> need to add 4, 5, 6, 7
      final removedMessages = newList.sublist(firstIndex);
      newList.replaceRange(
        firstIndex,
        newList.length,
        messages.map(Message.fromDto),
      );
      _messagesLocal.deleteAllWithIds(removedMessages.map((m) => m.id));
    } else if (firstIndex == -1) {
      /// the case: 3, 4, 5, 6 -> need to add 0, 1, 2, 3, 4
      /// or the case: 5, 6 -> need to add 0, 1, 2
      final firstCacheMessageId = newList.first.id;
      final indexOfFirstCollision = messages.toList().indexWhere(
        (m) => m.id == firstCacheMessageId,
      );
      final messages2 = messages.map(Message.fromDto).toList();
      newList.replaceRange(
        0,
        lastIndex + 1,
        messages2.sublist(indexOfFirstCollision),
      );
      final messagesToAddToStart = messages2.sublist(
        0,
        indexOfFirstCollision == -1 ? null : indexOfFirstCollision,
      );
      newList.insertAll(0, messagesToAddToStart);
    } else {
      // firstIndex != -1 && lastIndex != -1
      /// the case: 0, 1, 2, 3, 4 -> need to add 1, 2, 3
      final removedMessages = newList.sublist(firstIndex, lastIndex + 1);
      newList.replaceRange(firstIndex, lastIndex + 1, messages.map(Message.fromDto));
      _messagesLocal.deleteAllWithIds(removedMessages.map((m) => m.id));
    }
    // firstIndex == -1 && lastIndex != -1 -> impossible, case will look like that:
    // 5, 4, 1, 0 -> need to add 3, 2, 1, 0

    if (firstIndex > 0 && newList[firstIndex - 1].fromCache == true) {
      /// the case (a - api, c - cache): 0a, 1a, 2a, 3a, 4c, 5c, 6c -> 0a, 1a, 2a, 3a, 4c, 5a, 6a. 4 should be deleted
      final start = newList.indexWhere((m) => m.fromCache);
      final end = firstIndex; // exclusive
      newList.removeRange(start, end);
    }

    _messagesLocal.insertAll(messages);
    return newList;
  }

  @override
  Future<void> loadMoreMessages({
    required int chatId,
    required int? toMessageId,
  }) async {
    // await Future.delayed(const Duration(milliseconds: 500));
    if (_lastMessagesCollection == null) return;
    final messages = _lastMessagesCollection!.messages;
    final messagesFromCache = messages.where((m) => m.fromCache).toList();

    /// if toMessageId is null, it means we are on top and have to load more
    /// messages AND all that have not been loaded
    final limitCorrection = toMessageId == null
        ? messagesFromCache.length
        : messagesFromCache.indexWhere((m) => m.id == toMessageId);
    final newLimit = limitCorrection == -1
        ? AppConstants.msgPagingLimit
        : limitCorrection + AppConstants.msgPagingLimit;
    final newMessagesDtos = await _messagesApi.getMessages(
      chatId: chatId,
      limit: newLimit,
      cursor: messages.lastWhere((e) => !e.fromCache).id,
    );
    if (newMessagesDtos.isEmpty) {
      print(
        'MyLog newMessagesDtos is empty, chatId: $chatId, toMessageId: $toMessageId, limit: $newLimit',
      );
      _emitMessagesCollection(
        MessagesCollection(
          messages: messages,
          chatId: chatId,
          maintainLoading: false,
          allMessagesLoaded: true,
        ),
      );
      return;
    }

    final newList = await _combineCacheAndApi(
      messages,
      newMessagesDtos,
      loadMoreMode: true,
    );

    print(
      'MyLog, newLimit: $newLimit, newMessagesLength: ${newMessagesDtos.length}',
    );
    _emitMessagesCollection(
      MessagesCollection(
        messages: newList,
        chatId: chatId,
        maintainLoading: false,
        allMessagesLoaded: newLimit > newMessagesDtos.length,
      ),
    );
  }

  /// ws streams
  @override
  Stream<MessagesCollection> get messagesUpdatesStream =>
      _messagesUpdatesController.stream;

  @override
  Stream<ChatsCollection> get chatsUpdatesStream => _chatsUpdatesController.stream;
}
