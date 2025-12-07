import 'dart:async';

import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

abstract class IMessagesRepository {
  /// callbacks
  void initSocket();

  void dispose();

  void reconnect();

  /// api calls
  Future<List<Message>> getMessages({
    required int chatId,
    required int userId,
    required int limit,
    required int offset,
  });

  /// ws sends
  void sendMessage({required String message, required int recipientId});

  void readAllMessages({required int chatId});

  void readMessageBeforeTime({required int chatId, required int time});

  /// ws streams
  Stream<Message> get newMessageStream;

  Stream<ReadMessagesUpdate> get readMessagesStream;

  Stream<bool> get connectionStateStream;

  bool get isConnected;
}

class MessagesRepository implements IMessagesRepository {
  final MessagesApi _messagesApi;
  final MessagesWebSocket _webSocket;

  MessagesRepository({
    required MessagesApi messagesApi,
    required MessagesWebSocket messagesWebSocket,
  }) : _messagesApi = messagesApi,
       _webSocket = messagesWebSocket;

  /// callbacks
  @override
  void initSocket() => _webSocket.init();

  @override
  void dispose() => _webSocket.disconnect();

  @override
  void reconnect() => _webSocket.reconnect();

  @override
  bool get isConnected => _webSocket.isConnected;

  /// api calls
  @override
  Future<List<Message>> getMessages({
    required int chatId,
    required int userId,
    required int limit,
    required int offset,
  }) async {
    final res = await _messagesApi
        .getMessages(chatId: chatId, limit: limit, offset: offset)
        .timeout(ApiConstants.timeout);

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get messages: ${res.response.statusCode}",
      );
    }

    return res.data.data!.map((e) => Message.fromDto(e)).toList();
  }

  /// ws sends
  @override
  void sendMessage({required String message, required int recipientId}) =>
      _webSocket.sendMessage(message: message, recipientId: recipientId);

  @override
  void readAllMessages({required int chatId}) =>
      _webSocket.readAllMessages(chatId: chatId);

  @override
  void readMessageBeforeTime({required int chatId, required int time}) =>
      _webSocket.readMessageBeforeTime(chatId: chatId, time: time);

  /// ws streams
  @override
  Stream<Message> get newMessageStream => _webSocket.newMessageStream;

  @override
  Stream<ReadMessagesUpdate> get readMessagesStream => _webSocket.readMessagesStream;

  @override
  Stream<bool> get connectionStateStream => _webSocket.connectionStateStream;
}
