import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';

abstract class IChatsApiDataSource {
  Future<Iterable<ChatDto>> getChats();
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