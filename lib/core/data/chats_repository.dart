import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';

class ChatsRepository {
  final ChatsApi _chatsApi;

  ChatsRepository({required ChatsApi chatsApi}) : _chatsApi = chatsApi;

  Future<List<Chat>> getChats() async {
    final res = await _chatsApi.getChats();

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get chats: ${res.response.statusCode}",
      );
    }

    return res.data.data!.map(Chat.fromDto).toList();
  }

  Future<Chat?> getChatWithUser(int otherUserId) async {
    final res = await _chatsApi.getChatWithUser(otherUserId: otherUserId);

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

  Future<Chat?> getChatWithId(int chatId) async {
    final res = await _chatsApi.getChatWithId(chatId: chatId);

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
