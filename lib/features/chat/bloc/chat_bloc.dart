import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/notifications/notifications_service.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/main.dart';

import 'chat_state.dart';

const _pagingCount = 25;

/// don't need to clear method, it may cause some bugs (if you navigate from chats to
/// chat, from it to user page and click "message" button)
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IMessagesRepository _messagesRepository;
  final IChatsRepository _chatsRepository;
  late ChatData _data = ChatData.initial();
  late StreamSubscription _newMessageSub;
  late StreamSubscription _readMessagesSub;
  late StreamSubscription _connectionStateSub;

  ChatBloc({
    required IMessagesRepository messagesRepository,
    required IChatsRepository chatsRepository,
  }) : _messagesRepository = messagesRepository,
       _chatsRepository = chatsRepository,
       super(ChatStateBase.initial()) {
    _messagesRepository.initSocket();
    _newMessageSub = _messagesRepository.newMessageStream.listen((message) {
      add(ChatEventNewMessage(newMessage: message));
    }, cancelOnError: false);
    _readMessagesSub = _messagesRepository.readMessagesStream.listen((data) {
      add(ChatEventReadMessagesUpdate(updates: data));
    }, cancelOnError: false);
    _connectionStateSub = _messagesRepository.connectionStateStream.listen((
      isConnected,
    ) {
      if (_data.chatId == -1 || _data.otherUser == null) return;
      if (isConnected) {
        add(ChatEventLoad(chatId: _data.chatId, otherUser: _data.otherUser));
      } else {
        add(const ChatEventLoading());
      }
    }, cancelOnError: false);

    on<ChatEvent>(
      (event, emit) => switch (event) {
        ChatEventLoad event => _onLoad(event, emit),
        ChatEventNewMessage event => _onNewMessage(event, emit),
        ChatEventReadMessagesUpdate event => _onReadMessagesUpdate(event, emit),
        ChatEventLoading event => _onLoading(event, emit),
        ChatEventLoadMore event => _onLoadMore(event, emit),
        _ => () {},
      },
      transformer: sequential(),
    );
    on<ChatEventSendMessage>(_onSendMessage);
    on<ChatEventReadAllMessages>(_onReadAllMessages);
    on<ChatEventReadMessagesBeforeTime>(_onReadMessagesBeforeTime);
  }

  /// cause can be called on init and on connect at the same time
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
      /// show cached messages
      final cache = await _messagesRepository.getMessagesFromCache(chatId: chatId);
      _data = _data.copyWith(messages: _withUnreadMessages(cache));
      emit(ChatStateBase(data: _data));

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
        limit: _pagingCount,
        offset: 0,
      );
      if (messages.length < _pagingCount) {
        _data = _data.copyWith(isAllMessagesLoaded: true);
      }

      /// add unread messages line
      final newList = _withUnreadMessages(messages);

      _data = _data.copyWith(messages: newList, isLoading: false);
      emit(ChatStateBase(data: _data));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatStateError(message: e.userErrorMessage));
    }
  }

  List<Message> _withUnreadMessages(List<Message> messages) {
    var newList = <Message>[];
    bool isStopMessageFound = false;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].user.isCurrent) {
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

    return newList;
  }

  void _onReadMessagesBeforeTime(
    ChatEventReadMessagesBeforeTime event,
    Emitter<ChatState> emit,
  ) {
    _messagesRepository.readMessageBeforeTime(
      chatId: _data.chatId,
      time: event.time,
    );
  }

  void _onReadAllMessages(ChatEventReadAllMessages event, Emitter<ChatState> emit) {
    _messagesRepository.readAllMessages(chatId: _data.chatId);
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

  bool _isLoadingMore = false;
  int _lastTimeLoadMoreCalled = 0;

  void _onLoadMore(ChatEventLoadMore event, Emitter<ChatState> emit) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastTimeLoadMoreCalled + 500 > now) {
      return;
    }
    _lastTimeLoadMoreCalled = now;

    if (_data.isAllMessagesLoaded || _data.isLoading || _isLoadingMore) return;
    _isLoadingMore = true;

    try {
      final newMessages = await _messagesRepository.getMessages(
        chatId: _data.chatId,
        limit: _pagingCount,
        offset: _data.messages.where((e) => e.id >= 0).length,
      );

      _data = _data.copyWith(
        messages: [..._data.messages, ...newMessages],
        isAllMessagesLoaded: newMessages.length < _pagingCount,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(
        const ChatStateMessage(
          message: 'Failed to load more messages',
          isError: true,
        ),
      );
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

  @override
  Future<void> close() {
    _newMessageSub.cancel();
    _readMessagesSub.cancel();
    _connectionStateSub.cancel();
    _messagesRepository.dispose();
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
