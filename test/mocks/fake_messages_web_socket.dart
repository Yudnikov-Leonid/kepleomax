import 'dart:async';

import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

class FakeMessagesWebSocket implements MessagesWebSocket {
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
  // TODO: implement newMessageStream
  Stream<Message> get newMessageStream => _newMessagesController.stream;

  @override
  void connectIfNot() {
    // TODO: implement connectIfNot
  }

  @override
  void disconnect() {
    // TODO: implement disconnect
  }

  @override
  void init() {
    // TODO: implement init
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
  void reinit() {
    // TODO: implement reconnect
  }

  @override
  void sendMessage({required String message, required int recipientId}) {
    // TODO: implement sendMessage
  }
}
