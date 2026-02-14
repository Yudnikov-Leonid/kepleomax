import 'dart:async';

import 'package:collection/collection.dart';
import 'package:kepleomax/core/app_constants.dart';
import 'package:kepleomax/core/data/data_sources/chats_api_data_sources.dart';
import 'package:kepleomax/core/data/data_sources/messages_api_data_sources.dart';
import 'package:kepleomax/core/data/local_data_sources/users_local_data_source.dart';
import 'package:kepleomax/core/data/messenger/combine_cache_and_api.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/read_messages_update.dart';

import '../local_data_sources/chats_local_data_source.dart';
import '../local_data_sources/messages_local_data_source.dart';
import '../models/chats_collection.dart';
import '../models/messages_collection.dart';

part 'on_new_message.dart';

part 'on_read_messages.dart';

part 'on_delete_message.dart';

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
    var newList = (CombineCacheAndApi().combineLoad(
      cache,
      apiMessagesDtos,
    )).toList();

    /// TODO add unreadMessages
    _emitMessagesCollection(
      MessagesCollection(
        messages: newList.map(Message.fromDto),
        chatId: chatId,
        allMessagesLoaded: newList.length < AppConstants.msgPagingLimit,
        maintainLoading: false,
      ),
    );
    _messagesLocal.insertAll(apiMessagesDtos);
  }

  @override
  Future<void> loadMoreMessages({
    required int chatId,
    required int? toMessageId,
  }) async {
    // await Future.delayed(const Duration(milliseconds: 500));
    if (_lastMessagesCollection == null) return;
    final messages = _lastMessagesCollection!.messages;

    /// if toMessageId is null, it means we are on top and have to load more
    /// messages AND all that have not been loaded
    final messagesFromCache = messages.where((m) => m.fromCache).toList();
    final limitCorrection = toMessageId == null
        ? messagesFromCache.length
        : messagesFromCache.indexWhere((m) => m.id == toMessageId);
    final newLimit = limitCorrection == -1
        ? AppConstants.msgPagingLimit
        : limitCorrection + AppConstants.msgPagingLimit;
    final api = await _messagesApi.getMessages(
      chatId: chatId,
      limit: newLimit,
      cursor: messages.lastWhere((e) => !e.fromCache).id,
    );
    if (api.isEmpty) {
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

    final newList = CombineCacheAndApi.combineLoadMore(
      messages.toList(),
      api,
      limit: newLimit,
    );
    _emitMessagesCollection(
      MessagesCollection(
        messages: newList,
        chatId: chatId,
        maintainLoading: false,
        allMessagesLoaded: newLimit > api.length,
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
