import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';

abstract class IMessagesApiDataSource {
  Future<List<MessageDto>> getMessages({
    required int chatId,
    required int limit,
    int cursor,
  });
}

class MessagesApiDataSource implements IMessagesApiDataSource {
  final MessagesApi _messagesApi;

  MessagesApiDataSource({required MessagesApi messagesApi})
    : _messagesApi = messagesApi;

  @override
  Future<List<MessageDto>> getMessages({
    required int chatId,
    required int limit,
    int? cursor,
  }) async {
    final res = await _messagesApi
        .getMessages(chatId: chatId, limit: limit, cursor: cursor)
        .timeout(ApiConstants.timeout);
    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get messages: ${res.response.statusCode}",
      );
    }
    return res.data.data!;
  }
}
