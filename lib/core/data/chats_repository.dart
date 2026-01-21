import 'dart:async';

import 'package:kepleomax/core/data/local/local_database.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

abstract class IChatsRepository {
  Stream<ChatsCollection> getChats2({bool withCache = true});

  /// api
  Future<List<Chat>> getChats(); // test covered

  Future<Chat?> getChatWithUser(int otherUserId);

  Future<Chat?> getChatWithId(int chatId);

  /// cache
  Future<List<Chat>> getChatsFromCache(); // test covered

  Future<Chat?> getChatWithUserFromCache(int otherUserId);

  Future<Chat?> getChatWithIdFromCache(int chatId);

  /// other
  Stream<ChatsCollection> get chatsUpdatesStream;
}

class ChatsRepository implements IChatsRepository {
  final ChatsApi _chatsApi;
  final ILocalChatsDatabase _localDatabase;
  final MessagesWebSocket _webSocket;

  final _chatsUpdatesController = StreamController<ChatsCollection>.broadcast();

  ChatsRepository({
    required ChatsApi chatsApi,
    required ILocalChatsDatabase localChatsDatabase,
    required MessagesWebSocket webSocket,
  }) : _localDatabase = localChatsDatabase,
       _webSocket = webSocket,
       _chatsApi = chatsApi {
    _webSocket.newMessageStream.listen(_onNewMessage);
    _webSocket.readMessagesStream.listen(_onReadMessages);
  }

  @override
  Stream<ChatsCollection> getChats2({bool withCache = true}) async* {
    /// return cache
    if (withCache) {
      print('MyLog2 loadCache');
      final cache = await _localDatabase.getChats();
      yield ChatsCollection(
        chats: cache.map(Chat.fromDto).toList(growable: false),
        fromCache: true,
      );
    }

    /// return actual chats from api
    await Future.delayed(const Duration(seconds: 1));
    final res = await _chatsApi.getChats().timeout(ApiConstants.timeout);
    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ??
            "Failed to get chats, statusCode: ${res.response.statusCode}",
      );
    }
    final data = res.data.data!;
    _localDatabase.clearAndInsertChats(data);
    yield ChatsCollection(
      chats: data.map(Chat.fromDto).toList(growable: false),
      fromCache: false,
    );

    /// return stream for future changes
    yield* _chatsUpdatesController.stream;
  }

  /// api
  @Deprecated('use getChats2 instead')
  @override
  Future<List<Chat>> getChats() async {
    final res = await _chatsApi.getChats().timeout(ApiConstants.timeout);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ??
            "Failed to get chats, statusCode: ${res.response.statusCode}",
      );
    }

    final data = res.data.data!;
    await _localDatabase.clearAndInsertChats(data);
    return data.map(Chat.fromDto).toList();
  }

  @override
  Future<Chat?> getChatWithUser(int otherUserId) async {
    final res = await _chatsApi
        .getChatWithUser(otherUserId: otherUserId)
        .timeout(ApiConstants.timeout);

    if (res.response.statusCode == 404) {
      return null;
    }
    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get chat: ${res.response.statusCode}",
      );
    }

    return Chat.fromDto(res.data.data!);
  }

  @override
  Future<Chat?> getChatWithId(int chatId) async {
    final res = await _chatsApi
        .getChatWithId(chatId: chatId)
        .timeout(ApiConstants.timeout);

    if (res.response.statusCode == 404) {
      return null;
    }
    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get chat: ${res.response.statusCode}",
      );
    }

    final data = res.data.data!;
    _localDatabase.insertChat(data);
    return Chat.fromDto(data);
  }

  /// cache
  @override
  Future<Chat?> getChatWithUserFromCache(int otherUserId) async {
    final chats = await _localDatabase.getChats();

    /// TODO make query in _localDatabase to this
    final dto = chats.where((e) => e.otherUser.id == otherUserId).firstOrNull;
    if (dto == null) {
      return null;
    } else {
      return Chat.fromDto(dto);
    }
  }

  @override
  Future<List<Chat>> getChatsFromCache() async {
    final chats = await _localDatabase.getChats();
    final mapped = chats.map(Chat.fromDto).toList();
    return mapped;
  }

  @override
  Future<Chat?> getChatWithIdFromCache(int chatId) async {
    final dto = await _localDatabase.getChat(chatId);
    if (dto == null) return null;
    return Chat.fromDto(dto);
  }

  /// stream
  void _onNewMessage(Message message) async {
    /// messageDto already is inserted to the localDatabase
    final newList = await getChatsFromCache();
    _chatsUpdatesController.add(ChatsCollection(chats: newList));
  }

  void _onReadMessages(ReadMessagesUpdate data) async {
    /// localDatabase already is updated
    final newList = await getChatsFromCache();
    _chatsUpdatesController.add(ChatsCollection(chats: newList));
  }

  @override
  Stream<ChatsCollection> get chatsUpdatesStream =>
      _chatsUpdatesController.stream.asBroadcastStream();
}

class ChatsCollection {
  final List<Chat> chats;
  final bool fromCache;

  ChatsCollection({required this.chats, this.fromCache = false});
}
