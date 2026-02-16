import 'dart:async';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/core/network/websockets/models/deleted_message_update.dart';
import 'package:kepleomax/core/network/websockets/models/online_status_update.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../logger.dart';
import 'models/read_messages_update.dart';

abstract class MessagesWebSocket {
  /// streams
  Stream<MessageDto> get newMessageStream;

  Stream<ReadMessagesUpdate> get readMessagesStream;

  Stream<DeletedMessageUpdate> get deletedMessageStream;

  Stream<bool> get connectionStateStream;

  Stream<OnlineStatusUpdate> get onlineUpdatesStream;

  /// manage
  Future<void> init();

  void reinit();

  void connectIfNot();

  void disconnect();

  bool get isConnected;

  /// events
  void sendMessage({required String message, required int recipientId});

  void deleteMessage({required int messageId});

  void readAllMessages({required int chatId});

  void readMessagesBeforeTime({required int chatId, required DateTime time});

  void subscribeOnOnlineStatusUpdates({required Iterable<int> usersIds});

  void activityDetected();
}

class MessagesWebSocketImpl implements MessagesWebSocket {
  final String _baseUrl;
  final TokenProvider _tokenProvider;

  MessagesWebSocketImpl({
    required String baseUrl,
    required TokenProvider tokenProvider,
  }) : _tokenProvider = tokenProvider,
       _baseUrl = baseUrl;

  /// streams
  final StreamController<MessageDto> _messageController =
      StreamController.broadcast();
  final StreamController<ReadMessagesUpdate> _readMessagesController =
      StreamController.broadcast();
  final StreamController<DeletedMessageUpdate> _deletedMessageController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController = StreamController.broadcast();
  final StreamController<OnlineStatusUpdate> _onlineUpdatesController =
      StreamController.broadcast();

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

  @override
  Stream<OnlineStatusUpdate> get onlineUpdatesStream =>
      _onlineUpdatesController.stream;

  /// socket
  Socket? _socket;

  @override
  Future<void> init() async {
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

    /// errors events
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

    /// logic events
    _socket!.on('new_message', (data) {
      logger.d('WebSocketLog new_message: $data');
      final messageDto = MessageDto.fromJson(data, fromCache: false);
      _messageController.add(messageDto);
    });
    _socket!.on('read_messages', (data) {
      logger.d('WebSocketLog read_messages: $data');
      final update = ReadMessagesUpdate.fromJson(data);
      _readMessagesController.add(update);
    });
    _socket!.on('deleted_message', (data) {
      logger.d('WebSocketLog deleted_message: $data');
      final update = DeletedMessageUpdate.fromJson(data);
      _deletedMessageController.add(update);
    });
    _socket!.on('online_status_update', (data) {
      logger.d('WebSocketLog online_status_update: $data');
      final update = OnlineStatusUpdate.fromJson(data);
      _onlineUpdatesController.add(update);
    });
  }

  @override
  Future<void> reinit() async {
    logger.d('WebSocketLog! reconnect');
    disconnect();
    await init();
  }

  @override
  void connectIfNot() {
    logger.d(
      'WebSocketLog! connectIfNot, _socket != null: ${_socket != null}, _socket.disconnected: ${_socket?.disconnected}',
    );
    if (_socket != null && _socket!.disconnected) {
      _socket!.connect();
    }
  }

  @override
  void disconnect() {
    logger.d('WebSocketLog! disconnect, socket != null: ${_socket != null}');
    if (_socket != null) {
      _socket!.dispose();
    }
  }

  @override
  bool get isConnected => _socket?.connected ?? false;

  /// events
  @override
  void sendMessage({required String message, required int recipientId}) {
    if (_socket?.connected == true) {
      _socket!.emit('message', {'recipient_id': recipientId, 'message': message});
    }
  }

  @override
  void deleteMessage({required int messageId}) {
    if (_socket?.connected == true) {
      _socket!.emit('delete_message', {'message_id': messageId});
    }
  }

  @override
  void readAllMessages({required int chatId}) {
    if (_socket?.connected == true) {
      _socket!.emit('read_all', {'chat_id': chatId});
    }
  }

  @override
  void readMessagesBeforeTime({required int chatId, required DateTime time}) {
    if (_socket?.connected == true) {
      _socket!.emit('read_before_time', {
        'chat_id': chatId,
        'time': time.millisecondsSinceEpoch,
      });
    }
  }

  @override
  void subscribeOnOnlineStatusUpdates({required Iterable<int> usersIds}) {
    if (_socket?.connected == true) {
      _socket!.emit('subscribe_on_online_status_updates', {
        'users_ids': usersIds.toList(),
      });
    }
  }

  @override
  void activityDetected() {
    if (_socket?.connected == true) {
      _socket!.emit('activity_detected');
    }
  }
}
