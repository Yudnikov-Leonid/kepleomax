import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:kepleomax/main.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final IChatsRepository _chatsRepository;
  final IMessagesRepository _messagesRepository;
  late ChatsData _data = ChatsData.initial();
  late StreamSubscription _subMessages;
  late StreamSubscription _subReadMessages;
  late StreamSubscription _subConnectionState;
  final int _userId;

  ChatsBloc({
    required IChatsRepository chatsRepository,
    required IMessagesRepository messagesRepository,
    required int userId,
  }) : _chatsRepository = chatsRepository,
       _messagesRepository = messagesRepository,
       _userId = userId,
       super(ChatsStateBase.initial()) {
    _subMessages = _messagesRepository.newMessageStream.listen((newMessage) {
      add(ChatsEventNewMessage(message: newMessage));
    }, cancelOnError: false);
    _subReadMessages = _messagesRepository.readMessagesStream.listen((data) {
      add(ChatsEventReadMessages(updates: data));
    }, cancelOnError: false);
    _subConnectionState = _messagesRepository.connectionStateStream.listen(
      (isConnected) => add(ChatsEventConnectingChanged(isConnected)),
      cancelOnError: false,
    );

    on<ChatsEvent>(
      (event, emit) => switch (event) {
        ChatsEventLoad event => _onLoad(event, emit),
        ChatsEventLoadCache event => _onLoadCache(event, emit),
        ChatsEventNewMessage event => _onNewMessage(event, emit),
        ChatsEventReadMessages event => _onReadMessages(event, emit),
        ChatsEvent _ => () {},
      },
      transformer: sequential(),
    );
    on<ChatsEventReconnect>(_onReconnect);
    on<ChatsEventConnectingChanged>(_onConnectingChanged);
  }

  int _lastTimeLoadWasCalled = 0;

  void _onLoad(ChatsEventLoad event, Emitter<ChatsState> emit) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - 300 < _lastTimeLoadWasCalled) {
      return;
    }
    _lastTimeLoadWasCalled = now;

    _data = _data.copyWith(isLoading: true);
    emit(ChatsStateBase(data: _data));

    try {
      final chats = await _chatsRepository.getChats();

      _data = _data.copyWith(
        chats: chats,
        totalUnreadCount: chats.fold(0, (a, b) => a + b.unreadCount),
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatsStateMessage(message: e.userErrorMessage, isError: true));
    } finally {
      _data = _data.copyWith(isLoading: false);
      emit(ChatsStateBase(data: _data));
    }
  }

  void _onLoadCache(ChatsEventLoadCache event, Emitter<ChatsState> emit) async {
    try {
      final cache = await _chatsRepository.getChatsFromCache();
      _data = _data.copyWith(
        chats: cache,
        totalUnreadCount: cache.fold(0, (a, b) => a + b.unreadCount),
      );
      emit(ChatsStateBase(data: _data));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatsStateError(message: e.userErrorMessage));
    }
  }

  void _onReconnect(ChatsEventReconnect event, Emitter<ChatsState> emit) {
    _messagesRepository.reconnect();
  }

  void _onConnectingChanged(
    ChatsEventConnectingChanged event,
    Emitter<ChatsState> emit,
  ) {
    _data = _data.copyWith(isConnected: event.isConnected);
    emit(ChatsStateBase(data: _data));
    if (event.isConnected) {
      add(const ChatsEventLoad());
    }
  }

  void _onReadMessages(
    ChatsEventReadMessages event,
    Emitter<ChatsState> emit,
  ) async {
    final chatIndex = _data.chats.indexWhere(
      (chat) => chat.id == event.updates.chatId,
    );
    final newChats = _data.chats.toList();

    if (event.updates.senderId == _userId) {
      /// current user message was read
      if (event.updates.messagesIds.contains(
        _data.chats[chatIndex].lastMessage!.id,
      )) {
        newChats[chatIndex] = newChats[chatIndex].copyWith(
          lastMessage: newChats[chatIndex].lastMessage!.copyWith(isRead: true),
        );
        _chatsRepository.updateLocalChat(newChats[chatIndex]).ignore();
        _data = _data.copyWith(chats: newChats);
        emit(ChatsStateBase(data: _data));
      }
      return;
    }

    if (chatIndex == -1 ||
        event.updates.senderId == _userId ||
        event.updates.messagesIds.isEmpty) {
      return;
    }
    final newUnreadCount =
        (newChats[chatIndex].unreadCount - event.updates.messagesIds.length).clamp(
          0,
          999,
        );
    newChats[chatIndex] = newChats[chatIndex].copyWith(unreadCount: newUnreadCount);
    _chatsRepository.updateLocalChat(newChats[chatIndex]).ignore();
    _data = _data.copyWith(
      chats: newChats,
      totalUnreadCount: newChats.fold(0, (a, b) => a + b.unreadCount),
    );
    emit(ChatsStateBase(data: _data));
  }

  void _onNewMessage(ChatsEventNewMessage event, Emitter<ChatsState> emit) async {
    final chatId = event.message.chatId;
    final chatIndex = _data.chats.indexWhere((e) => e.id == chatId);
    if (chatIndex == -1) {
      /// get new chat
      try {
        final newChat = await _chatsRepository.getChatWithId(event.message.chatId);
        _data = _data.copyWith(
          chats: [newChat!, ..._data.chats],
          totalUnreadCount:
              _data.totalUnreadCount + (event.message.user.isCurrent ? 0 : 1),
        );
      } catch (e, st) {
        emit(ChatsStateError(message: e.userErrorMessage));
        logger.e(e, stackTrace: st);
        return;
      }
    } else {
      final newList = _data.chats.toList();
      Chat chat = newList.removeAt(chatIndex);
      chat = chat.copyWith(
        lastMessage: event.message,
        unreadCount: event.message.user.isCurrent ? 0 : chat.unreadCount + 1,
      );
      _chatsRepository.updateLocalChat(chat).ignore();
      _data = _data.copyWith(
        chats: [chat, ...newList],
        totalUnreadCount:
            _data.totalUnreadCount + (event.message.user.isCurrent ? 0 : 1),
      );
    }
    emit(ChatsStateBase(data: _data));
  }

  @override
  Future<void> close() {
    _subMessages.cancel();
    _subReadMessages.cancel();
    _subConnectionState.cancel();
    return super.close();
  }
}

///events
abstract class ChatsEvent {}

class ChatsEventLoad implements ChatsEvent {
  const ChatsEventLoad();
}

/// call it on initState. Load will be called on ws connected
class ChatsEventLoadCache implements ChatsEvent {
  const ChatsEventLoadCache();
}

class ChatsEventReconnect implements ChatsEvent {
  const ChatsEventReconnect();
}

class ChatsEventConnectingChanged implements ChatsEvent {
  final bool isConnected;

  const ChatsEventConnectingChanged(this.isConnected);
}

class ChatsEventNewMessage implements ChatsEvent {
  final Message message;

  const ChatsEventNewMessage({required this.message});
}

class ChatsEventReadMessages implements ChatsEvent {
  final ReadMessagesUpdate updates;

  const ChatsEventReadMessages({required this.updates});
}
