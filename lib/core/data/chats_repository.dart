import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';

abstract class IChatsRepository {
  Future<List<Chat>> getChats();

  Future<Chat?> getChatWithUser(int otherUserId);

  Future<Chat?> getChatWithId(int chatId);
}

class ChatsRepository implements IChatsRepository {
  final ChatsApi _chatsApi;

  ChatsRepository({required ChatsApi chatsApi}) : _chatsApi = chatsApi;

  @override
  Future<List<Chat>> getChats() async {
    final res = await _chatsApi.getChats().timeout(ApiConstants.timeout);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get chats: ${res.response.statusCode}",
      );
    }

    return res.data.data!.map(Chat.fromDto).toList();
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

    return Chat.fromDto(res.data.data!);
  }
}
