import 'dart:async';

import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

class FakeMessagesRepository implements IMessagesRepository {
  final _connectionController = StreamController<bool>();
  final _readMessagesController = StreamController<ReadMessagesUpdate>();
  final _newMessagesController = StreamController<Message>();

  /// tests methods
  void addNewMessage(Message message) {
    _newMessagesController.add(message);
  }

  void addReadMessages(ReadMessagesUpdate value) {
    _readMessagesController.add(value);
  }

  /// overrides
  @override
  Stream<bool> get connectionStateStream => _connectionController.stream;

  @override
  Stream<ReadMessagesUpdate> get readMessagesStream => _readMessagesController.stream;

  @override
  Stream<Message> get newMessageStream => _newMessagesController.stream;

  @override
  Future<List<Message>> getMessages({
    required int chatId,
    required int limit,
    required int offset,
  }) {
    // TODO: implement getMessages
    throw UnimplementedError();
  }

  @override
  Future<List<Message>> getMessagesFromCache({required int chatId}) {
    // TODO: implement getMessagesFromCache
    throw UnimplementedError();
  }

  @override
  void initSocket() {
    // TODO: implement initSocket
  }

  @override
  void disconnect() {
    // TODO: implement dispose
  }

  @override
  // TODO: implement isConnected
  bool get isConnected => throw UnimplementedError();

  @override
  void readAllMessages({required int chatId}) {
    // TODO: implement readAllMessages
  }

  @override
  void readMessageBeforeTime({required int chatId, required int time}) {
    // TODO: implement readMessageBeforeTime
  }

  @override
  void sendMessage({required String message, required int recipientId}) {
    // TODO: implement sendMessage
  }

  @override
  void reconnect({bool onlyIfNot = false}) {
    // TODO: implement reconnect
  }
}
