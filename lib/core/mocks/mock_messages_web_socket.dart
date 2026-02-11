import 'dart:async';

import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/read_messages_update.dart';

class MockMessagesWebSocket implements MessagesWebSocket {
  /// testing stuff
  bool _isConnected = false;

  void setIsConnected(bool value) {
    _isConnected = value;
    _connectionController.add(value);
  }

  void addMessage(MessageDto messageDto) => _messageController.add(messageDto);

  void addReadMessagesUpdate(ReadMessagesUpdate update) =>
      _readMessagesController.add(update);

  void addDeletedMessagesUpdate(DeletedMessageUpdate update) =>
      _deletedMessageController.add(update);

  /// streams
  final StreamController<MessageDto> _messageController =
      StreamController.broadcast();
  final StreamController<ReadMessagesUpdate> _readMessagesController =
      StreamController.broadcast();
  final StreamController<DeletedMessageUpdate> _deletedMessageController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController = StreamController.broadcast();

  @override
  Stream<MessageDto> get newMessageStream => _messageController.stream;

  @override
  Stream<ReadMessagesUpdate> get readMessagesStream =>
      _readMessagesController.stream;

  @override
  Stream<DeletedMessageUpdate> get deletedMessageStream =>
      _deletedMessageController.stream;

  @override
  Stream<bool> get connectionStateStream => _connectionController.stream;

  /// websocket
  @override
  Future<void> init() async {}

  @override
  Future<void> reinit() async {}

  @override
  void connectIfNot() {}

  @override
  void disconnect() {}

  @override
  bool get isConnected => _isConnected;

  /// events
  @override
  void sendMessage({required String message, required int recipientId}) {}

  @override
  void deleteMessage({required int messageId}) {}

  @override
  void readAllMessages({required int chatId}) {}

  @override
  void readMessageBeforeTime({required int chatId, required DateTime time}) {}
}
