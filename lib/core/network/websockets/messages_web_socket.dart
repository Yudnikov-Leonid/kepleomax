import 'dart:async';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/common/refresh_token.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';
import 'package:ntp/ntp.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../common/api_constants.dart';

class MessagesWebSocket {
  final String baseUrl;
  final TokenProvider tokenProvider;
  final Dio dio;

  MessagesWebSocket({
    required this.baseUrl,
    required this.tokenProvider,
    required this.dio,
  });

  /// streams
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<ReadMessagesUpdate> _readMessagesController =
      StreamController<ReadMessagesUpdate>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<Message> get messagesStream => _messageController.stream;

  Stream<ReadMessagesUpdate> get readMessagesStream =>
      _readMessagesController.stream;

  Stream<bool> get connectionStateStream => _connectionController.stream;

  /// socket
  Socket? _socket;

  void init() async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }

    /// you can't pass auth data in OptionBuilder cause on reconnect it won't update
    /// for some reason (idk why)
    final token = await _getAccessToken();
    if (token == null) {
      logger.e('try to connect to ws, but no accessToken');
      _socket?.disconnect();
      return;
    }

    /// socket
    _socket = io(baseUrl, OptionBuilder().setTransports(['websocket']).build());
    _socket!.auth = {'token': 'Bearer $token'};
    _socket!.connect();

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
      final messageDto = MessageDto.fromJson(data);
      _messageController.add(Message.fromDto(messageDto));
    });
    _socket!.on('read_messages', (data) {
      logger.d('WebSocketLog read_messages: $data');
      _readMessagesController.add(ReadMessagesUpdate.fromJson(data));
    });
    _socket!.onError((error) {
      logger.e('WebSocketLog error: $error');
    });
    _socket!.on('auth_error', (data) async {
      logger.d('WebSocketLog auth_error $data');
      if (data == 401) {
        final token = await _getAccessToken();
        if (token == null) {
          logger.e('try to connect to ws, but no accessToken');
          _socket!.disconnect();
          return;
        }
        _socket!.auth = {'token': 'Bearer $token'};
        _socket!.connect();
      }
    });
  }

  void reconnect() {
    disconnect();
    init();
  }

  void connectIfNot() {
    if (_socket != null && _socket!.disconnected) {
      _socket!.connect();
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.dispose();
    }
  }

  bool get isConnected => _socket?.connected ?? false;

  /// events
  void sendMessage({required String message, required int recipientId}) {
    _socket!.emit('message', {'recipient_id': recipientId, 'message': message});
  }

  void readAllMessages({required int chatId}) {
    _socket!.emit('read_all', {'chat_id': chatId});
  }

  void readMessageBeforeTime({required int chatId, required int time}) {
    _socket!.emit('read_before_time', {'chat_id': chatId, 'time': time});
  }

  /// handle auth
  Future<String?> _getAccessToken() async {
    final accessToken = tokenProvider.getAccessToken();
    final refreshToken = await tokenProvider.getRefreshToken();
    if (accessToken == null || refreshToken == null) {
      return null;
    }

    final now = await NTP.now(timeout: ApiConstants.timeout);
    final accessTokenHasExpired = now.isAfter(
      JwtDecoder.getExpirationDate(accessToken),
    );
    final refreshTokenHasExpired = now.isAfter(
      JwtDecoder.getExpirationDate(refreshToken),
    );

    if (refreshTokenHasExpired) {
      return null;
    } else if (accessTokenHasExpired) {
      final newToken = await RefreshToken(dio: dio).refreshToken(refreshToken);
      if (newToken == null) {
        logger.e('WebSocketLog try to connect to ws, failed to update accessToken');
        return null;
      } else {
        await tokenProvider.saveAccessToken(newToken);
        return newToken;
      }
    } else {
      return accessToken;
    }
  }
}

class ReadMessagesUpdate {
  final int chatId;
  final int senderId;
  final List<int> messagesIds;

  ReadMessagesUpdate({
    required this.chatId,
    required this.senderId,
    required this.messagesIds,
  });

  factory ReadMessagesUpdate.fromJson(Map<String, dynamic> json) =>
      ReadMessagesUpdate(
        chatId: json['chat_id'],
        senderId: json['sender_id'],
        messagesIds: json['messages_ids']
            .map<int>((e) => int.parse(e.toString()))
            .toList(),
      );
}
