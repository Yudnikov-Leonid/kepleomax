import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/models/chat.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/core/network/websockets/messages_web_socket.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:kepleomax/main.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatsRepository _chatsRepository;
  final MessagesRepository _messagesRepository;
  late ChatsData _data = ChatsData.initial();
  late StreamSubscription _subMessages;
  late StreamSubscription _subReadMessages;
  late StreamSubscription _subConnectionState;
  final int _userId;

  ChatsBloc({
    required ChatsRepository chatsRepository,
    required MessagesRepository messagesRepository,
    required int userId,
  }) : _chatsRepository = chatsRepository,
       _messagesRepository = messagesRepository,
       _userId = userId,
       super(ChatsStateBase.initial()) {
    print('chatsBlocInit: $_userId');
    on<ChatsEventLoad>(_onLoad);
    on<ChatsEventNewMessage>(_onNewMessage);
    on<ChatsEventReadMessages>(_onReadMessages);
    on<ChatsEventLoading>(_onLoading);

    _subMessages = _messagesRepository.messagesStream.listen((newMessage) {
      add(ChatsEventNewMessage(message: newMessage));
    });
    _subReadMessages = _messagesRepository.readMessagesStream.listen((data) {
      add(ChatsEventReadMessages(updates: data));
    });
    _subConnectionState = _messagesRepository.connectionStateStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        add(const ChatsEventLoad());
      } else {
        add(const ChatsEventLoading());
      }
    });
  }

  void _onLoading(ChatsEventLoading event, Emitter<ChatsState> emit) {
    _data = _data.copyWith(isLoading: true);
    emit(ChatsStateBase(data: _data));
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
      /// my message have was read
      if (event.updates.messagesIds.contains(
        _data.chats[chatIndex].lastMessage!.id,
      )) {
        newChats[chatIndex] = newChats[chatIndex].copyWith(
          lastMessage: newChats[chatIndex].lastMessage!.copyWith(isRead: true),
        );
        _data = _data.copyWith(
          chats: newChats,
        );
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
          totalUnreadCount: _data.totalUnreadCount +
              (event.message.user.isCurrent ? 0 : 1),
        );
      } catch (e, st) {
        emit(ChatsStateError(message: e.toString()));
        logger.e(e, stackTrace: st);
      }
    } else {
      final newList = _data.chats.toList();
      Chat chat = newList.removeAt(chatIndex);
      chat = chat.copyWith(
        lastMessage: event.message,
        unreadCount: event.message.user.isCurrent ? 0 : chat.unreadCount + 1,
      );
      _data = _data.copyWith(
        chats: [chat, ...newList],
        totalUnreadCount:
            _data.totalUnreadCount +
            (event.message.user.isCurrent ? 0 : 1),
      );
    }
    emit(ChatsStateBase(data: _data));
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
        isLoading: false,
      );
      emit(ChatsStateBase(data: _data));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatsStateError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    print('chatBlocClose');
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

class ChatsEventLoading implements ChatsEvent {
  const ChatsEventLoading();
}

class ChatsEventNewMessage implements ChatsEvent {
  final Message message;

  const ChatsEventNewMessage({required this.message});
}

class ChatsEventReadMessages implements ChatsEvent {
  final ReadMessagesUpdate updates;

  const ChatsEventReadMessages({required this.updates});
}
