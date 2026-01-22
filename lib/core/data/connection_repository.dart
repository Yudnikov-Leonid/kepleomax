import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';

abstract class IConnectionRepository {
  void initSocket();

  void disconnect();

  void reconnect({bool onlyIfNot = false});

  void sendMessage({required String message, required int recipientId});

  void readAllMessages({required int chatId});

  void readMessageBeforeTime({required int chatId, required int time});

  Stream<bool> get connectionStateStream;

  bool get isConnected;
}

class ConnectionRepository implements IConnectionRepository {
  final MessagesWebSocket _webSocket;

  ConnectionRepository({required MessagesWebSocket webSocket})
    : _webSocket = webSocket;

  /// callbacks
  @override
  void initSocket() => _webSocket.init();

  @override
  void disconnect() => _webSocket.disconnect();

  @override
  void reconnect({bool onlyIfNot = false}) =>
      onlyIfNot ? _webSocket.connectIfNot() : _webSocket.reconnect();

  /// ws sends
  @override
  void sendMessage({required String message, required int recipientId}) =>
      _webSocket.sendMessage(message: message.trim(), recipientId: recipientId);

  @override
  void readAllMessages({required int chatId}) =>
      _webSocket.readAllMessages(chatId: chatId);

  @override
  void readMessageBeforeTime({required int chatId, required int time}) =>
      _webSocket.readMessageBeforeTime(chatId: chatId, time: time);

  @override
  Stream<bool> get connectionStateStream => _webSocket.connectionStateStream;

  @override
  bool get isConnected => _webSocket.isConnected;
}
