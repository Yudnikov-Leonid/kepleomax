import 'dart:async';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MessagesWebSocket {
  final String _baseUrl;
  final TokenProvider _tokenProvider;

  MessagesWebSocket({required String baseUrl, required TokenProvider tokenProvider})
    : _tokenProvider = tokenProvider,
      _baseUrl = baseUrl;

  /// streams
  final StreamController<MessageDto> _messageController =
      StreamController.broadcast();
  final StreamController<ReadMessagesUpdate> _readMessagesController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController = StreamController.broadcast();

  Stream<MessageDto> get newMessageStream => _messageController.stream;

  Stream<ReadMessagesUpdate> get readMessagesStream =>
      _readMessagesController.stream;

  Stream<bool> get connectionStateStream => _connectionController.stream;

  /// socket
  Socket? _socket;

  void init() async {
    logger.d('WebSocketLog! init, _socket != null: ${_socket != null}');
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }

    /// you can't pass auth data in OptionBuilder cause on reconnect it won't update
    /// for some reason (idk why)
    final accessToken = await _tokenProvider.getAccessToken();

    /// socket
    _socket = io(
      _baseUrl,
      OptionBuilder()
          .enableForceNew()
          .setAuth({'token': 'Bearer $accessToken'})
          .enableAutoConnect()
          .setTransports(['websocket'])
          .build(),
    );

    /// events
    _socket!.onConnect((_) {
      logger.d('WebSocketLog Connected');
      _connectionController.add(true);
    });
    _socket!.onDisconnect((_) {
      logger.d('WebSocketLog Disconnected');
      _connectionController.add(false);
    });
    _socket!.onReconnect((_) async {
      logger.d('WebSocketLog Reconnect');
    });
    _socket!.on('new_message', (data) {
      logger.d('WebSocketLog new_message: $data');
      final messageDto = MessageDto.fromJson(data, fromCache: false);
      _messageController.add(messageDto);
    });
    _socket!.on('read_messages', (data) {
      logger.d('WebSocketLog read_messages: $data');
      final updates = ReadMessagesUpdate.fromJson(data);
      _readMessagesController.add(updates);
    });
    _socket!.onError((error) {
      logger.e('WebSocketLog error: $error');
    });
    _socket!.on('auth_error', (data) async {
      logger.d('WebSocketLog auth_error $data');
      if (data == 401) {
        final token = await _tokenProvider.getAccessToken();
        if (token == null) {
          logger.e('try to connect to ws, but no accessToken');
          _socket!.disconnect();
          return;
        }
        _socket!.disconnect();
        _socket!.auth = {'token': 'Bearer $token'};
        _socket!.connect();
      }
    });
  }

  void reconnect() {
    logger.d('WebSocketLog! reconnect');
    disconnect();
    init();
  }

  void connectIfNot() {
    logger.d(
      'WebSocketLog! connectIfNot, _socket != null: ${_socket != null}, _socket.disconnected: ${_socket?.disconnected}',
    );
    if (_socket != null && _socket!.disconnected) {
      _socket!.connect();
    }
  }

  void disconnect() {
    logger.d('WebSocketLog! disconnect, socket != null: ${_socket != null}');
    if (_socket != null) {
      _socket!.dispose();
    }
  }

  bool get isConnected => _socket?.connected ?? false;

  /// events
  void sendMessage({required String message, required int recipientId}) {
    if (_socket?.connected ?? false) {
      _socket!.emit('message', {'recipient_id': recipientId, 'message': message});
    }
  }

  void readAllMessages({required int chatId}) {
    print('WebSocketLog readAllMessages from chat: $chatId');
    if (_socket?.connected ?? false) {
      _socket!.emit('read_all', {'chat_id': chatId});
    }
  }

  void readMessageBeforeTime({required int chatId, required int time}) {
    if (_socket?.connected ?? false) {
      _socket!.emit('read_before_time', {'chat_id': chatId, 'time': time});
    }
  }
}

class ReadMessagesUpdate {
  final int chatId;
  final int senderId;
  final bool isCurrentUser;
  final List<int> messagesIds;

  ReadMessagesUpdate({
    required this.chatId,
    required this.senderId,
    required this.isCurrentUser,
    required this.messagesIds,
  });

  factory ReadMessagesUpdate.fromJson(Map<String, dynamic> json) =>
      ReadMessagesUpdate(
        chatId: json['chat_id'],
        senderId: json['sender_id'],
        isCurrentUser: json['is_current_user'],
        messagesIds: json['messages_ids']
            .map<int>((id) => int.parse(id.toString()))
            .toList(),
      );
}

class OnlineStatusUpdate {
  final int userId;
  final bool newStatus;

  OnlineStatusUpdate({required this.userId, required this.newStatus});
}
