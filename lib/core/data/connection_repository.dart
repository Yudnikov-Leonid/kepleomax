import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

abstract class ConnectionRepository {
  void initSocket();

  void disconnect();

  void reconnect({bool onlyIfNot = false});

  void sendMessage({required String messageBody, required int recipientId});

  void deleteMessage({required int messageId});

  void readAllMessages({required int chatId});

  void readMessageBeforeTime({required int chatId, required DateTime time});

  Stream<bool> get connectionStateStream;

  bool get isConnected;
}

class ConnectionRepositoryImpl implements ConnectionRepository {
  final MessagesWebSocket _webSocket;

  ConnectionRepositoryImpl({required MessagesWebSocket webSocket})
    : _webSocket = webSocket;

  /// callbacks
  @override
  void initSocket() => _webSocket.init();

  @override
  void disconnect() => _webSocket.disconnect();

  @override
  void reconnect({bool onlyIfNot = false}) =>
      onlyIfNot ? _webSocket.connectIfNot() : _webSocket.reinit();

  /// ws sends
  @override
  void sendMessage({required String messageBody, required int recipientId}) =>
      _webSocket.sendMessage(message: messageBody.trim(), recipientId: recipientId);

  @override
  void deleteMessage({required int messageId}) =>
      _webSocket.deleteMessage(messageId: messageId);

  @override
  void readAllMessages({required int chatId}) =>
      _webSocket.readAllMessages(chatId: chatId);

  @override
  void readMessageBeforeTime({required int chatId, required DateTime time}) =>
      _webSocket.readMessagesBeforeTime(chatId: chatId, time: time);

  @override
  Stream<bool> get connectionStateStream => _webSocket.connectionStateStream;

  @override
  bool get isConnected => _webSocket.isConnected;
}
