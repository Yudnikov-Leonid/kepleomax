import 'dart:async';

import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/main.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MessagesRepository {
  final MessagesApi _messagesApi;
  late Socket _socket;
  late StreamController<Message> _messageController;
  late StreamController<ReadMessagesUpdate> _readMessagesController;
  late StreamController<bool> _connectionController;

  MessagesRepository({required MessagesApi messagesApi})
    : _messagesApi = messagesApi;

  void initSocket({required int userId}) {
    _messageController = StreamController<Message>.broadcast();
    _readMessagesController = StreamController<ReadMessagesUpdate>.broadcast();
    _connectionController = StreamController<bool>.broadcast();
    _socket = io(
      flavor.baseUrl,
      OptionBuilder().setTransports(['websocket']).enableAutoConnect().setQuery({
        'user_id': userId,
      }).build(),
    );
    _socket.on('connect', (_) {
      print('WebSocketLog Connected');
      _connectionController.add(true);
    });
    _socket.on('disconnect', (_) {
      print('WebSocketLog Disconnected');
      _connectionController.add(false);
    });
    _socket.on('new_message', (data) {
      print('WebSocketLog new_message: $data');
      final messageDto = MessageDto.fromJson(data);
      _messageController.add(Message.fromDto(messageDto));
    });
    _socket.on('read_messages', (data) {
      print('WebSocketLog read_messages: $data');
      _readMessagesController.add(ReadMessagesUpdate.fromJson(data));
    });
    // _socket.on('new_chat', (data) {
    //   print('new_chat: $data');
    //   _chatsStreamController.add(Chat.fromDto(data));
    // });
  }

  Stream<Message> get messagesStream => _messageController.stream;

  Stream<ReadMessagesUpdate> get readMessagesStream =>
      _readMessagesController.stream;

  Stream<bool> get connectionStateStream => _connectionController.stream;

  Future<List<Message>> getMessages({
    required int chatId,
    required int userId,
    required int limit,
    required int offset,
  }) async {
    final res = await _messagesApi.getMessages(
      chatId: chatId,
      limit: limit,
      offset: offset,
    );

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? "Failed to get messages: ${res.response.statusCode}",
      );
    }

    return res.data.data!.map((e) => Message.fromDto(e)).toList();
  }

  void sendMessage({required String message, required int recipientId}) {
    _socket.emit('message', {'recipient_id': recipientId, 'message': message});
  }

  void readAllMessages({required int chatId}) {
    _socket.emit('read_all', {'chat_id': chatId});
  }

  void readMessageBeforeTime({required int chatId, required int time}) {
    _socket.emit('read_before_time', {'chat_id': chatId, 'time': time});
  }

  void close() {
    _socket.disconnect();
    _messageController.close();
    _connectionController.close();
    _readMessagesController.close();
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
