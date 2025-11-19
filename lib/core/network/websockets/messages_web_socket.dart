import 'dart:async';

import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/main.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MessagesWebSocket {
  final String baseUrl;

  MessagesWebSocket({required this.baseUrl});

  /// streams
  late StreamController<Message> _messageController;
  late StreamController<ReadMessagesUpdate> _readMessagesController;
  late StreamController<bool> _connectionController;

  Stream<Message> get messagesStream => _messageController.stream;

  Stream<ReadMessagesUpdate> get readMessagesStream =>
      _readMessagesController.stream;

  Stream<bool> get connectionStateStream => _connectionController.stream;

  /// socket
  late Socket _socket;

  void init({required int userId}) {
    /// stream controllers
    _messageController = StreamController<Message>.broadcast();
    _readMessagesController = StreamController<ReadMessagesUpdate>.broadcast();
    _connectionController = StreamController<bool>.broadcast();

    /// socket
    _socket = io(
      baseUrl,
      OptionBuilder().setTransports(['websocket']).enableAutoConnect().setQuery({
        'user_id': userId,
      }).build(),
    );

    /// events
    _socket.on('connect', (_) {
      logger.d('WebSocketLog Connected');
      _connectionController.add(true);
    });
    _socket.on('disconnect', (_) {
      logger.d('WebSocketLog Disconnected');
      _connectionController.add(false);
    });
    _socket.on('new_message', (data) {
      logger.d('WebSocketLog new_message: $data');
      final messageDto = MessageDto.fromJson(data);
      _messageController.add(Message.fromDto(messageDto));
    });
    _socket.on('read_messages', (data) {
      logger.d('WebSocketLog read_messages: $data');
      _readMessagesController.add(ReadMessagesUpdate.fromJson(data));
    });
  }

  void dispose() {
    _socket.disconnect();
    _messageController.close();
    _connectionController.close();
    _readMessagesController.close();
  }

  /// events
  void sendMessage({required String message, required int recipientId}) {
    _socket.emit('message', {'recipient_id': recipientId, 'message': message});
  }

  void readAllMessages({required int chatId}) {
    _socket.emit('read_all', {'chat_id': chatId});
  }

  void readMessageBeforeTime({required int chatId, required int time}) {
    _socket.emit('read_before_time', {'chat_id': chatId, 'time': time});
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
