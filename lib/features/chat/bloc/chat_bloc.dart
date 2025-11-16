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
  late StreamSubscription _subMessages;
  late StreamSubscription _subReadMessages;
  late StreamSubscription _subConnectionState;

  ChatBloc({
    required int userId,
    required MessagesRepository messagesRepository,
    required ChatsRepository chatsRepository,
  }) : _messagesRepository = messagesRepository,
       _chatsRepository = chatsRepository,
       _userId = userId,
       super(ChatStateBase.initial()) {
    _messagesRepository.initSocket(userId: userId);
    _subMessages = _messagesRepository.messagesStream.listen((message) {
      add(ChatEventNewMessage(newMessage: message));
    });
    _subReadMessages = _messagesRepository.readMessagesStream.listen((data) {
      add(ChatEventReadMessagesUpdate(updates: data));
    });
    _subConnectionState = _messagesRepository.connectionStateStream.listen((
      isConnected,
    ) {
      if (isConnected && _data.chatId != -1 && _data.otherUserId != -1) {
        add(ChatEventLoad(chatId: _data.chatId, otherUserId: _data.otherUserId));
      }
    });

    on<ChatEventLoad>(_onLoad);
    on<ChatEventNewMessage>(_onNewMessage);
    on<ChatEventSendMessage>(_onSendMessage);
    on<ChatEventReadMessagesUpdate>(_onReadMessagesUpdate);
    on<ChatEventReadAllMessages>(_onReadAllMessages);
    on<ChatEventClear>(_onClear);
  }

  void _onClear(ChatEventClear event, Emitter<ChatState> emit) {
    _data = _data.copyWith(chatId: -1, otherUserId: -1, messages: []);
    emit(ChatStateBase(data: _data));
  }

  void _onReadAllMessages(ChatEventReadAllMessages event, Emitter<ChatState> emit) {
    _messagesRepository.readAllMessages(chatId: _data.chatId);
    _data = _data.copyWith(
      messages: _data.messages.map((e) => e.copyWith(isRead: true)).toList(),
    );
    emit(ChatStateBase(data: _data));
  }

  void _onReadMessagesUpdate(
    ChatEventReadMessagesUpdate event,
    Emitter<ChatState> emit,
  ) {
    if (_data.chatId != event.updates.chatId) return;

    final updates = event.updates.messagesIds;
    final newMessages = <Message>[];
    for (final message in _data.messages) {
      /// TODO bigO
      if (updates.contains(message.id)) {
        newMessages.add(message.copyWith(isRead: true));
      } else {
        newMessages.add(message);
      }
    }
    _data = _data.copyWith(messages: newMessages);
    emit(ChatStateBase(data: _data));
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
    _data = _data.copyWith(
      chatId: event.chatId,
      otherUserId: event.otherUserId,
      isLoading: true,
    );
    emit(ChatStateBase(data: _data));

    int chatId = event.chatId;
    try {
      if (event.chatId == -1) {
        final chat = await _chatsRepository.getChatWithUser(event.otherUserId);
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

      var newList = List<Message>.of(messages);
      if (messages.firstOrNull?.user.id != _userId) {
        newList = [];
        for (int i = messages.length - 2; i >= 0; i--) {
          if (!messages[i].isRead) {
            newList.add(Message.unreadMessages());
            newList.addAll(messages.sublist(0, i + 1).reversed);
            break;
          } else {
            newList.add(messages[i]);
          }
        }
        newList = newList.reversed.toList();
      }

      _data = _data.copyWith(messages: newList, isLoading: false);
      emit(ChatStateBase(data: _data));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subMessages.cancel();
    _subReadMessages.cancel();
    _subConnectionState.cancel();
    _messagesRepository.dispose();
    return super.close();
  }
}

/// events
abstract class ChatEvent {}

class ChatEventLoad implements ChatEvent {
  final int chatId;

  /// needs if chatId is -1
  final int otherUserId;

  const ChatEventLoad({required this.chatId, required this.otherUserId});
}

class ChatEventClear implements ChatEvent {
  const ChatEventClear();
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

class ChatEventReadMessagesUpdate implements ChatEvent {
  final ReadMessagesUpdate updates;

  const ChatEventReadMessagesUpdate({required this.updates});
}

class ChatEventReadAllMessages implements ChatEvent {
  const ChatEventReadAllMessages();
}
