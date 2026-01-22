import 'package:kepleomax/core/data/local/local_database.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';

abstract class IChatsApiDataSource {
  Future<Iterable<ChatDto>> getChats();
}

abstract class IChatsLocalDataSource {
  Future<Iterable<ChatDto>> getChats();

  Future<void> clearAndInsertChats(Iterable<ChatDto> chats);

  Future<void> increaseUnreadCountBy1(int chatId);

  Future<void> decreaseUnreadCount(int chatId, int amount);
}

class ChatsApiDataSource implements IChatsApiDataSource {
  final ChatsApi _chatsApi;

  ChatsApiDataSource({required ChatsApi chatsApi}) : _chatsApi = chatsApi;

  @override
  Future<Iterable<ChatDto>> getChats() async {
    final res = await _chatsApi.getChats().timeout(ApiConstants.timeout);
    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ??
            "Failed to get chats, statusCode: ${res.response.statusCode}",
      );
    }
    return res.data.data!;
  }
}

/// TODO do I need this class?
class ChatsLocalDataSource implements IChatsLocalDataSource {
  final ILocalChatsDatabase _localStorage;

  ChatsLocalDataSource({required ILocalChatsDatabase localDatabase})
    : _localStorage = localDatabase;

  @override
  Future<Iterable<ChatDto>> getChats() => _localStorage.getChats();

  @override
  Future<void> clearAndInsertChats(Iterable<ChatDto> chats) =>
      _localStorage.clearAndInsertChats(chats);

  @override
  Future<void> increaseUnreadCountBy1(int chatId) =>
      _localStorage.increaseUnreadCountBy1(chatId);

  @override
  Future<void> decreaseUnreadCount(int chatId, int amount) =>
      _localStorage.decreaseUnreadCount(chatId, amount);
}
