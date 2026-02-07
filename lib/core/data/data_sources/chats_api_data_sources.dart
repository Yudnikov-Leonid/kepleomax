import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/apis/chats/chats_dtos.dart';

abstract class ChatsApiDataSource {
  Future<Iterable<ChatDto>> getChats();
}

class ChatsApiDataSourceImpl implements ChatsApiDataSource {
  final ChatsApi _chatsApi;

  ChatsApiDataSourceImpl({required ChatsApi chatsApi}) : _chatsApi = chatsApi;

  @override
  Future<Iterable<ChatDto>> getChats() async {
    final res = await _chatsApi.getChats();
    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ??
            "Failed to get chats, statusCode: ${res.response.statusCode}",
      );
    }
    return res.data.data!;
  }
}