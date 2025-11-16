import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/main.dart';

import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessagesRepository _messagesRepository;
  final ChatsRepository _chatsRepository;
  final int _userId;
  late ChatData _data = ChatData.initial();
  late StreamSubscription _sub;

  ChatBloc({
    required int userId,
    required MessagesRepository messagesRepository,
    required ChatsRepository chatsRepository,
  }) : _messagesRepository = messagesRepository,
       _chatsRepository = chatsRepository,
       _userId = userId,
       super(ChatStateBase.initial()) {
    _messagesRepository.initSocket(userId: userId);
    _sub = _messagesRepository.messagesStream.listen((message) {
      add(ChatEventNewMessage(newMessage: message));
    });

    on<ChatEventLoad>(_onLoad);
    on<ChatEventNewMessage>(_onNewMessage);
    on<ChatEventSendMessage>(_onSendMessage);
  }

  void _onSendMessage(ChatEventSendMessage event, Emitter<ChatState> emit) {
    _messagesRepository.sendMessage(
      message: event.message,
      recipientId: event.otherUserId,
    );
  }

  void _onNewMessage(ChatEventNewMessage event, Emitter<ChatState> emit) {
    _data = _data.copyWith(messages: [event.newMessage, ..._data.messages]);
    emit(ChatStateBase(data: _data));
  }

  void _onLoad(ChatEventLoad event, Emitter<ChatState> emit) async {
    _data = _data.copyWith(chatId: event.chatId, isLoading: true);
    emit(ChatStateBase(data: _data));

    int chatId = event.chatId;
    try {
      if (event.chatId == -1) {
        final chat = await _chatsRepository.getChatWithUser(event.otherUserId!);
        if (chat == null) {
          _data = _data.copyWith(chatId: -1, isLoading: false, messages: []);
          emit(ChatStateBase(data: _data));
          return;
        } else {
          chatId = chat.id;
        }
      }

      final messages = await _messagesRepository.getMessages(
        chatId: chatId,
        userId: _userId,
      );

      _data = _data.copyWith(messages: messages, isLoading: false);
      emit(ChatStateBase(data: _data));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    _messagesRepository.dispose();
    return super.close();
  }
}

/// events
abstract class ChatEvent {}

class ChatEventLoad implements ChatEvent {
  final int chatId;

  /// send if chatId is -1
  final int? otherUserId;

  const ChatEventLoad({required this.chatId, required this.otherUserId});
}

class ChatEventNewMessage implements ChatEvent {
  final Message newMessage;

  const ChatEventNewMessage({required this.newMessage});
}

class ChatEventSendMessage implements ChatEvent {
  final String message;
  final int otherUserId;

  const ChatEventSendMessage({required this.message, required this.otherUserId});
}
