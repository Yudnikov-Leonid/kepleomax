import 'package:kepleomax/core/data/local/local_database.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

abstract class IMessagesApiDataSource {
  Future<List<MessageDto>> getMessages({
    required int chatId,
    required int limit,
    int cursor,
  });
}

abstract class IMessagesLocalDataSource {
  Future<List<MessageDto>> getMessagesByChat({required int chatId});

  Future<void> removeWithIds({required Iterable<int> ids});

  Future<void> readMessages({required ReadMessagesUpdate update});

  Future<void> insert({required MessageDto message});

  Future<void> insertAll({required Iterable<MessageDto> messages});
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

class MessagesLocalDataSource implements IMessagesLocalDataSource {
  final ILocalMessagesDatabase _localStorage;

  MessagesLocalDataSource({required ILocalMessagesDatabase localDatabase})
    : _localStorage = localDatabase;

  @override
  Future<List<MessageDto>> getMessagesByChat({required int chatId}) =>
      _localStorage.getMessagesByChatId(chatId);

  @override
  Future<void> insertAll({required Iterable<MessageDto> messages}) async {
    for (final message in messages) {
      await _localStorage.insertMessage(message);
    }
  }

  @override
  Future<void> removeWithIds({required Iterable<int> ids}) async {
    for (final id in ids) {
      await _localStorage.deleteMessageById(id);
    }
  }

  @override
  Future<void> insert({required MessageDto message}) =>
      _localStorage.insertMessage(message);

  @override
  Future<void> readMessages({required ReadMessagesUpdate update}) =>
      _localStorage.readMessages(update);
}
