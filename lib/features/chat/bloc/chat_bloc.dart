import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/notifications/notifications_service.dart';
import 'package:kepleomax/main.dart';

import 'chat_state.dart';

const _pagingCount = 25;

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
      if (_data.chatId == -1 || _data.otherUser == null) return;
      if (isConnected) {
        add(ChatEventLoad(chatId: _data.chatId, otherUser: _data.otherUser));
      } else {
        add(const ChatEventLoading());
      }
    });

    on<ChatEventLoad>(_onLoad);
    on<ChatEventNewMessage>(_onNewMessage);
    on<ChatEventSendMessage>(_onSendMessage);
    on<ChatEventReadMessagesUpdate>(_onReadMessagesUpdate);
    on<ChatEventReadAllMessages>(_onReadAllMessages);
    on<ChatEventClear>(_onClear);
    on<ChatEventLoading>(_onLoading);
    on<ChatEventLoadMore>(_onLoadMore);
    on<ChatEventReadMessagesBeforeTime>(_onReadMessagesBeforeTime);
  }

  void _onReadMessagesBeforeTime(
    ChatEventReadMessagesBeforeTime event,
    Emitter<ChatState> emit,
  ) {
    _messagesRepository.readMessageBeforeTime(
      chatId: _data.chatId,
      time: event.time,
    );
    _data = _data.copyWith(
      messages: _data.messages
          .map(
            (msg) => msg.createdAt <= event.time ? msg.copyWith(isRead: true) : msg,
          )
          .toList(),
    );
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
      /// TODO optimize
      if (updates.contains(message.id)) {
        newMessages.add(message.copyWith(isRead: true));
        NotificationService.instance.closeNotification(message.id);
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
    print('onNewMessage: ${event.newMessage}');
    if (_data.chatId == -1 && event.newMessage.user.id == _data.otherUser?.id) {
      _data = _data.copyWith(chatId: event.newMessage.chatId);
    }
    if (event.newMessage.chatId == _data.chatId) {
      _data = _data.copyWith(
        chatId: event.newMessage.chatId,
        messages: [event.newMessage, ..._data.messages],
      );
    }
    emit(ChatStateBase(data: _data));
  }

  int _lastTimeLoadWasCalled = 0;

  void _onLoad(ChatEventLoad event, Emitter<ChatState> emit) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - 300 < _lastTimeLoadWasCalled) {
      return;
    }
    _lastTimeLoadWasCalled = now;

    _data = _data.copyWith(
      chatId: event.chatId,
      otherUser: event.otherUser,
      isLoading: true,
      isAllMessagesLoaded: false,
    );
    emit(ChatStateBase(data: _data));

    int chatId = event.chatId;
    try {
      /// either chatId == -1 and we have otherUser, or otherUser == null and we have chatId
      if (event.chatId == -1) {
        final chat = await _chatsRepository.getChatWithUser(event.otherUser!.id);
        if (chat == null) {
          /// it's new chat with new user
          _data = _data.copyWith(chatId: -1, isLoading: false, messages: []);
          emit(ChatStateBase(data: _data));
          return;
        } else {
          /// it's existing chat with otherUser, but was opened not from chat page
          chatId = chat.id;
          _data = _data.copyWith(chatId: chat.id);
        }
      } else if (event.otherUser == null) {
        /// chat was opened from notification
        final chat = await _chatsRepository.getChatWithId(event.chatId);
        _data = _data.copyWith(otherUser: chat!.otherUser);
      }

      final messages = await _messagesRepository.getMessages(
        chatId: chatId,
        userId: _userId,
        limit: _pagingCount,
        offset: 0,
      );
      if (messages.length < _pagingCount) {
        _data = _data.copyWith(isAllMessagesLoaded: true);
      }

      /// add unread messages line
      var newList = <Message>[];
      bool isStopMessageFound = false;
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].user.id == _userId) {
          /// message of current user, unreadMessagesLine can't be above, so end the loop
          newList.addAll(messages.sublist(i));
          isStopMessageFound = true;
          break;
        }
        if (messages[i].isRead) {
          /// message of not current user is read. If it's first message, then
          /// don't need the line. If it's not the first one, then add the line
          if (i != 0) {
            newList.add(Message.unreadMessages());
          }
          newList.addAll(messages.sublist(i));
          isStopMessageFound = true;
          break;
        }

        /// message of not current user that unread, go to the next one
        newList.add(messages[i]);
      }
      if (!isStopMessageFound) {
        /// means this is new chat with unread messages from other user
        newList.add(Message.unreadMessages());
      }

      _data = _data.copyWith(messages: newList, isLoading: false);
      emit(ChatStateBase(data: _data));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateError(message: e.toString()));
    }
  }

  bool _isLoadingMore = false;

  void _onLoadMore(ChatEventLoadMore event, Emitter<ChatState> emit) async {
    if (_data.isAllMessagesLoaded || _data.isLoading || _isLoadingMore) return;
    _isLoadingMore = true;

    try {
      final newMessages = await _messagesRepository.getMessages(
        chatId: _data.chatId,
        userId: _userId,
        limit: _pagingCount,
        offset: _data.messages.where((e) => e.id >= 0).length,
      );

      _data = _data.copyWith(
        messages: [..._data.messages, ...newMessages],
        isAllMessagesLoaded: newMessages.length < _pagingCount,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateMessage(message: 'Failed to load more messages', isError: true));
      _data = _data.copyWith(isAllMessagesLoaded: true);
    } finally {
      _isLoadingMore = false;
      emit(ChatStateBase(data: _data));
    }
  }

  void _onLoading(ChatEventLoading event, Emitter<ChatState> emit) {
    _data = _data.copyWith(isLoading: true);
    emit(ChatStateBase(data: _data));
  }

  void _onClear(ChatEventClear event, Emitter<ChatState> emit) {
    _data = _data.copyWith(chatId: -1, otherUser: null, messages: []);
    emit(ChatStateBase(data: _data));
  }

  @override
  Future<void> close() {
    _subMessages.cancel();
    _subReadMessages.cancel();
    _subConnectionState.cancel();
    _messagesRepository.close();
    return super.close();
  }
}

/// events
abstract class ChatEvent {}

class ChatEventLoad implements ChatEvent {
  final int chatId;
  final User? otherUser;

  const ChatEventLoad({required this.chatId, required this.otherUser});
}

class ChatEventLoadMore implements ChatEvent {
  const ChatEventLoadMore();
}

class ChatEventClear implements ChatEvent {
  const ChatEventClear();
}

class ChatEventLoading implements ChatEvent {
  /// or ChatEventHide
  const ChatEventLoading();
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

class ChatEventReadMessagesBeforeTime implements ChatEvent {
  final int time;

  ChatEventReadMessagesBeforeTime({required this.time});
}
