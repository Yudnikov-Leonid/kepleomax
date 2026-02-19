import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/network/websockets/models/online_status_update.dart';
import 'package:kepleomax/core/network/websockets/models/typing_activity_update.dart';

abstract class ConnectionRepository {
  void initSocket();

  void disconnect();

  void reconnect({bool onlyIfDisconnected = false});

  void sendMessage({required String messageBody, required int recipientId});

  void deleteMessage({required int messageId});

  void readAllMessages({required int chatId});

  void readMessageBeforeTime({required int chatId, required DateTime time});

  void listenOnlineStatusUpdates({required List<int> usersIds});

  void activityDetected();

  void typingActivityDetected({required int chatId});

  Stream<bool> get connectionStateStream;

  bool get isConnected;

  Stream<OnlineStatusUpdate> get onlineUpdatesStream;

  Stream<TypingActivityUpdate> get typingUpdatesStream;
}

/// TODO why does this class exist?
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
  void reconnect({bool onlyIfDisconnected = false}) =>
      onlyIfDisconnected ? _webSocket.connectIfNot() : _webSocket.reinit();

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
  void listenOnlineStatusUpdates({required List<int> usersIds}) =>
      _webSocket.subscribeOnOnlineStatusUpdates(usersIds: usersIds);

  @override
  void activityDetected() => _webSocket.activityDetected();

  @override
  void typingActivityDetected({required int chatId}) =>
      _webSocket.typingActivityDetected(chatId: chatId);

  @override
  Stream<bool> get connectionStateStream => _webSocket.connectionStateStream;

  @override
  bool get isConnected => _webSocket.isConnected;

  @override
  Stream<OnlineStatusUpdate> get onlineUpdatesStream =>
      _webSocket.onlineUpdatesStream;

  @override
  Stream<TypingActivityUpdate> get typingUpdatesStream =>
      _webSocket.typingUpdatesStream;
}
