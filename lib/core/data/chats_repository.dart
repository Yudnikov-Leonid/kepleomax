import 'package:dio/dio.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/network/apis/chats/chats_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/presentation/map_exceptions.dart';
import 'package:kepleomax/main.dart';

class ChatsRepository {
  final ChatsApi _chatsApi;

  ChatsRepository({required ChatsApi chatsApi}) : _chatsApi = chatsApi;

  Future<List<Chat>> getChats() async {
    try {
      final res = await _chatsApi.getChats().timeout(ApiConstants.timeout);

      if (res.response.statusCode != 200) {
        throw Exception(
          res.data.message ?? "Failed to get chats: ${res.response.statusCode}",
        );
      }
      
      return res.data.data!.map(Chat.fromDto).toList();
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  Future<Chat?> getChatWithUser(int otherUserId) async {
    try {
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
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  Future<Chat?> getChatWithId(int chatId) async {
    try {
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
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }
}
