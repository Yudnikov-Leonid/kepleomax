import 'dart:async';

import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MessagesWebSocket {
  final String baseUrl;
  final TokenProvider tokenProvider;

  MessagesWebSocket({required this.baseUrl, required this.tokenProvider});

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
  late Socket? _socket;

  void init() {
    /// socket
    _socket = io(
      baseUrl,
      OptionBuilder().setTransports(['websocket']).enableAutoConnect().build(),
    );

    /// you can't pass auth data in OptionBuilder cause on reconnect it won't update
    /// for some reason (idk why)
    _socket!.auth = {'token': 'Bearer ${tokenProvider.getAccessToken()}'};
    logger.d('WebSocketLog connected with token: ${tokenProvider.getAccessToken()}');

    /// events
    _socket!.on('connect', (_) {
      logger.d('WebSocketLog Connected');
      _connectionController.add(true);
    });
    _socket!.on('disconnect', (_) {
      logger.d('WebSocketLog Disconnected');
      _connectionController.add(false);
    });
    _socket!.on('reconnect', (_) {
      logger.t('WebSocketLog Reconnect');
      _socket!.auth = {'token': 'Bearer ${tokenProvider.getAccessToken()}'};
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
  }

  void reconnect() {
    disconnect();
    init();
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.dispose();
    }
  }

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
