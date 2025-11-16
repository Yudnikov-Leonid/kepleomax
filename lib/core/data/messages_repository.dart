import 'dart:async';

import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/apis/messages/message_dtos.dart';
import 'package:kepleomax/core/network/apis/messages/messages_api.dart';
import 'package:kepleomax/main.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MessagesRepository {
  final MessagesApi _messagesApi;
  late Socket _socket;
  final _messageStreamController = StreamController<Message>.broadcast();
  final _readMessagesStreamController =
      StreamController<ReadMessagesUpdate>.broadcast();

  MessagesRepository({required MessagesApi messagesApi})
    : _messagesApi = messagesApi;

  void initSocket({required int userId}) {
    _socket = io(
      flavor.baseUrl,
      OptionBuilder().setTransports(['websocket']).enableAutoConnect().setQuery({
        'user_id': userId,
      }).build(),
    );
    _socket.on('connect', (_) {
      print('MyLog Connected');
    });
    _socket.on('disconnect', (_) {
      print('MyLog Disconnected');
    });
    _socket.on('new_message', (data) {
      print('MyLog new_message: $data');
      final messageDto = MessageDto.fromJson(data);
      _messageStreamController.add(Message.fromDto(messageDto));
    });
    _socket.on('read_messages', (data) {
      print('MyLog read_messages: $data');
      _readMessagesStreamController.add(ReadMessagesUpdate.fromJson(data));
    });
    // _socket.on('new_chat', (data) {
    //   print('new_chat: $data');
    //   _chatsStreamController.add(Chat.fromDto(data));
    // });
  }

  Stream<Message> get messagesStream => _messageStreamController.stream;

  Stream<ReadMessagesUpdate> get readMessagesStream =>
      _readMessagesStreamController.stream;

  Future<List<Message>> getMessages({
    required int chatId,
    required int userId,
  }) async {
    final res = await _messagesApi.getMessages(chatId: chatId);

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

  void dispose() {
    _messageStreamController.close();
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