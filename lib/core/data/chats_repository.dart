import 'dart:async';

import 'package:kepleomax/core/data/local/local_database.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';

abstract class IChatsRepository {
  /// api
  Future<Chat?> getChatWithUser(int otherUserId);

  Future<Chat?> getChatWithId(int chatId);

  /// cache
  Future<Chat?> getChatWithUserFromCache(int otherUserId);

  Future<Chat?> getChatWithIdFromCache(int chatId);
}

class ChatsRepository implements IChatsRepository {
  final ChatsApi _chatsApi;
  final ILocalChatsDatabase _localDatabase;

  ChatsRepository({
    required ChatsApi chatsApi,
    required ILocalChatsDatabase localChatsDatabase,
  }) : _localDatabase = localChatsDatabase,
       _chatsApi = chatsApi;

  /// api
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

    return Chat.fromDto(res.data.data!, fromCache: false);
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
    return Chat.fromDto(data, fromCache: false);
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
      return Chat.fromDto(dto, fromCache: true);
    }
  }

  @override
  Future<Chat?> getChatWithIdFromCache(int chatId) async {
    final dto = await _localDatabase.getChat(chatId);
    if (dto == null) return null;
    return Chat.fromDto(dto, fromCache: true);
  }
}
