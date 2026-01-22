import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kepleomax/core/data/data_sources/chats_data_sources.dart';
import 'package:kepleomax/core/data/data_sources/messages_data_sources.dart';
import 'package:kepleomax/core/data/local/local_database.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

import 'models/chats_collection.dart';
import 'models/messages_collection.dart';

const int _messagesPagingLimit = 15;

abstract class IMessagesRepository {
  /// api/db calls
  Future<void> loadChats({bool withCache = true});

  Future<void> loadMessages({required int chatId, bool withCache = true});

  Future<void> loadMoreMessages({required int chatId, required int? toMessageId});

  /// ws streams
  Stream<MessagesCollection> get messagesUpdatesStream;

  Stream<ChatsCollection> get chatsUpdatesStream;
}

class MessagesRepository implements IMessagesRepository {
  final ILocalDatabase _localDatabase;

  final MessagesWebSocket _webSocket;

  final IMessagesApiDataSource _messagesApi;
  final IMessagesLocalDataSource _messagesLocal;

  final IChatsApiDataSource _chatsApi;
  final IChatsLocalDataSource _chatsLocal;

  final _messagesUpdatesController =
      StreamController<MessagesCollection>.broadcast();
  final _chatsUpdatesController = StreamController<ChatsCollection>.broadcast();
  MessagesCollection? _lastMessagesCollection;
  ChatsCollection? _lastChatsCollection;

  MessagesRepository({
    required ILocalDatabase localDatabase,
    required MessagesWebSocket webSocket,
    required IMessagesApiDataSource messagesApi,
    required IMessagesLocalDataSource messagesLocal,
    required IChatsApiDataSource chatsApi,
    required IChatsLocalDataSource chatsLocal,
  }) : _localDatabase = localDatabase,
       _webSocket = webSocket,
       _messagesApi = messagesApi,
       _messagesLocal = messagesLocal,
       _chatsApi = chatsApi,
       _chatsLocal = chatsLocal {
    _webSocket.newMessageStream.listen(_onNewMessage, cancelOnError: false);
    _webSocket.readMessagesStream.listen(_onReadMessages, cancelOnError: false);
  }

  void _onNewMessage(MessageDto messageDto) {
    _messagesLocal.insert(message: messageDto);

    if (_lastMessagesCollection != null) {
      final messages = <Message>[
        Message.fromDto(messageDto),
        ..._lastMessagesCollection!.messages,
      ];
      _emitMessagesCollection(MessagesCollection(messages: messages));
    }

    if (_lastChatsCollection != null &&
        !messageDto.isCurrentUser &&
        !messageDto.isRead) {
      final chats = List<Chat>.from(_lastChatsCollection!.chats);
      final chat = chats.firstWhereOrNull((chat) => chat.id == messageDto.chatId);
      if (chat != null) {
        _chatsLocal.increaseUnreadCountBy1(chat.id);
        chats.remove(chat);
        chats.insert(
          0,
          chat.copyWith(
            lastMessage: Message.fromDto(messageDto),
            unreadCount: chat.unreadCount + 1,
          ),
        );
        _emitChatsCollection(ChatsCollection(chats: chats));
      }
    }
  }

  void _onReadMessages(ReadMessagesUpdate update) {
    _messagesLocal.readMessages(update: update);

    if (_lastMessagesCollection != null) {
      final messages = _lastMessagesCollection!.messages.map(
        (m) => update.messagesIds.contains(m.id) ? m.copyWith(isRead: true) : m,
      );
      _emitMessagesCollection(MessagesCollection(messages: messages));
    }

    if (_lastChatsCollection != null && !update.isCurrentUser) {
      _chatsLocal.decreaseUnreadCount(update.chatId, update.messagesIds.length);
      final chats = _lastChatsCollection!.chats.map(
        (chat) => chat.id == update.chatId
            ? chat.copyWith(
                unreadCount: chat.unreadCount - update.messagesIds.length,
              )
            : chat,
      );
      _emitChatsCollection(ChatsCollection(chats: chats));
    }
  }

  void _emitMessagesCollection(MessagesCollection collection) {
    _messagesUpdatesController.add(collection);
    _lastMessagesCollection = collection;
  }

  void _emitChatsCollection(ChatsCollection collection) {
    _chatsUpdatesController.add(collection);
    _lastChatsCollection = collection;
  }

  /// api calls
  @override
  Future<void> loadChats({bool withCache = true}) async {
    if (withCache) {
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

    //await Future.delayed(const Duration(seconds: 1));
    final chats = await _chatsApi.getChats();
    await _chatsLocal.clearAndInsertChats(chats);
    _emitChatsCollection(
      ChatsCollection(
        chats: chats.map((chat) => Chat.fromDto(chat, fromCache: false)),
        fromCache: false,
      ),
    );
  }

  @override
  Future<void> loadMessages({required int chatId, bool withCache = true}) async {
    /// add to the stream data from cache
    List<MessageDto> cache = [];
    if (withCache) {
      cache = await _messagesLocal.getMessagesByChat(chatId: chatId);
      _emitMessagesCollection(
        MessagesCollection(
          messages: cache.map(Message.fromDto),
          maintainLoading: true,
        ),
      );
    }

    /// add to the stream data from api
    final apiMessagesDtos = await _messagesApi.getMessages(
      chatId: chatId,
      limit: _messagesPagingLimit,
    );
    final newList = await _combineCacheAndApi(
      cache.map(Message.fromDto),
      apiMessagesDtos,
    );
    _emitMessagesCollection(
      MessagesCollection(messages: newList, maintainLoading: false),
    );
    for (final message in apiMessagesDtos) {
      _localDatabase.insertMessage(message);
    }
  }

  Future<Iterable<Message>> _combineCacheAndApi(
    Iterable<Message> cache,
    Iterable<MessageDto> messages,
  ) async {
    final newList = List<Message>.from(cache);

    final firstIndex = newList.indexWhere((e) => e.id == messages.first.id);
    final lastIndex = newList.indexWhere((e) => e.id == messages.last.id);

    print('MyLog firstIndex: $firstIndex, lastIndex: $lastIndex');

    /// todo handle -1
    if (firstIndex == -1 && lastIndex == -1) {
      /// it's paging and need to add the messages to the top
      newList.addAll(messages.map(Message.fromDto));
    } else if (lastIndex == -1) {
      final removedMessages = newList.sublist(firstIndex);
      newList.replaceRange(
        firstIndex,
        newList.length,
        messages.map(Message.fromDto),
      );
      await _messagesLocal.removeWithIds(ids: removedMessages.map((m) => m.id));
    } else {
      final removedMessages = newList.sublist(firstIndex, lastIndex + 1);
      newList.replaceRange(firstIndex, lastIndex + 1, messages.map(Message.fromDto));
      await _messagesLocal.removeWithIds(ids: removedMessages.map((m) => m.id));
    }

    await _messagesLocal.insertAll(messages: messages);
    return newList;
  }

  @override
  Future<void> loadMoreMessages({
    required int chatId,
    required int? toMessageId,
  }) async {
    //await Future.delayed(const Duration(seconds: 1));
    if (_lastMessagesCollection == null) return;
    final messages = _lastMessagesCollection!.messages;
    final messagesFromCache = messages.where((m) => m.fromCache).toList();

    /// if toMessageId is null, it means we are on top and have to load more
    /// messages AND all that have not been loaded
    final limitCorrection = toMessageId == null
        ? messagesFromCache.length
        : messagesFromCache.toList().indexWhere((m) => m.id == toMessageId);
    final newLimit = limitCorrection == -1
        ? _messagesPagingLimit
        : limitCorrection + _messagesPagingLimit;
    final newMessagesDtos = await _messagesApi.getMessages(
      chatId: chatId,
      limit: newLimit,
      cursor: messages.lastWhere((e) => !e.fromCache).id,
    );
    final newMessages = newMessagesDtos.map(Message.fromDto);
    if (newMessages.isEmpty) {
      _emitMessagesCollection(
        MessagesCollection(
          messages: messages,
          maintainLoading: false,
          allMessagesLoaded: true,
        ),
      );
      return;
    }

    final newList = await _combineCacheAndApi(messages, newMessagesDtos);

    print('MyLog, newLimit: $newLimit, newMessagesLength: ${newMessages.length}');
    _emitMessagesCollection(
      MessagesCollection(
        messages: newList,
        maintainLoading: false,
        allMessagesLoaded: newLimit > newMessages.length,
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
