import 'dart:async';

import 'package:dio/dio.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/presentation/map_exceptions.dart';
import 'package:kepleomax/main.dart';

class MessagesRepository {
  final MessagesApi _messagesApi;
  final MessagesWebSocket _webSocket;

  MessagesRepository({
    required MessagesApi messagesApi,
    required MessagesWebSocket messagesWebSocket,
  }) : _messagesApi = messagesApi,
       _webSocket = messagesWebSocket;

  void initSocket() => _webSocket.init();

  void dispose() => _webSocket.disconnect();

  Future<List<Message>> getMessages({
    required int chatId,
    required int userId,
    required int limit,
    required int offset,
  }) async {
    try {
      final res = await _messagesApi
          .getMessages(chatId: chatId, limit: limit, offset: offset)
          .timeout(ApiConstants.timeout);

      if (res.response.statusCode != 200) {
        throw Exception(
          res.data.message ?? "Failed to get messages: ${res.response.statusCode}",
        );
      }

      return res.data.data!.map((e) => Message.fromDto(e)).toList();
    } on DioException catch (e, st) {
      logger.e(e, stackTrace: st);
      throw Exception(MapExceptions.dioExceptionToString(e));
    }
  }

  void sendMessage({required String message, required int recipientId}) =>
      _webSocket.sendMessage(message: message, recipientId: recipientId);

  void readAllMessages({required int chatId}) =>
      _webSocket.readAllMessages(chatId: chatId);

  void readMessageBeforeTime({required int chatId, required int time}) =>
      _webSocket.readMessageBeforeTime(chatId: chatId, time: time);

  Stream<Message> get messagesStream => _webSocket.messagesStream;

  Stream<ReadMessagesUpdate> get readMessagesStream => _webSocket.readMessagesStream;

  Stream<bool> get connectionStateStream => _webSocket.connectionStateStream;
}
