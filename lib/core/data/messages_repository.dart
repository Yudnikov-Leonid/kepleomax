import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kepleomax/core/data/local_database.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/core/network/common/api_constants.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

abstract class IMessagesRepository {
  /// callbacks
  void initSocket();

  void dispose();

  void reconnect();

  /// api/db calls
  Future<List<Message>> getMessages({
    required int chatId,
    required int limit,
    required int offset,
  });

  Future<List<Message>> getMessagesFromCache({required int chatId});

  /// ws sends
  void sendMessage({required String message, required int recipientId});

  void readAllMessages({required int chatId});

  void readMessageBeforeTime({required int chatId, required int time});

  /// ws streams
  Stream<Message> get newMessageStream;

  Stream<ReadMessagesUpdate> get readMessagesStream;

  Stream<bool> get connectionStateStream;
}

class MessagesRepository implements IMessagesRepository {
  final MessagesApi _messagesApi;
  final MessagesWebSocket _webSocket;
  final LocalDatabase _localStorage;

  MessagesRepository({
    required MessagesApi messagesApi,
    required MessagesWebSocket messagesWebSocket,
    required LocalDatabase localDatabase,
  }) : _messagesApi = messagesApi,
       _webSocket = messagesWebSocket,
       _localStorage = localDatabase;

  /// callbacks
  @override
  void initSocket() => _webSocket.init();

  @override
  void dispose() => _webSocket.disconnect();

  @override
  void reconnect() => _webSocket.reconnect();

  /// api calls
  @override
  Future<List<Message>> getMessages({
    required int chatId,
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

    final dtos = res.data.data!;
    for (final dto in dtos) {
      /// TODO is it good? or with one query
      _localStorage.insertMessage(dto);
    }

    final mapped = await compute(dtos.map<Message>, Message.fromDto);

    return mapped.toList();
  }

  @override
  Future<List<Message>> getMessagesFromCache({required int chatId}) async {
    final cache = await _localStorage.getMessagesByChatId(chatId);
    return cache.map(Message.fromDto).toList();
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
