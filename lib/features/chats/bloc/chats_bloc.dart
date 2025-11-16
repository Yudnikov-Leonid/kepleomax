import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/models/message.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:kepleomax/main.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final ChatsRepository _chatsRepository;
  final MessagesRepository _messagesRepository;
  late ChatsData _data = ChatsData.initial();
  late StreamSubscription _subMessages;
  late StreamSubscription _subReadMessages;
  final int _userId;

  ChatsBloc({
    required ChatsRepository chatsRepository,
    required MessagesRepository messagesRepository,
    required int userId,
  }) : _chatsRepository = chatsRepository,
       _messagesRepository = messagesRepository,
       _userId = userId,
       super(ChatsStateBase.initial()) {
    on<ChatsEventLoad>(_onLoad);
    on<ChatsEventNewMessage>(_onNewMessage);
    on<ChatsEventReadMessages>(_onReadMessages);

    _subMessages = _messagesRepository.messagesStream.listen((newMessage) {
      add(ChatsEventNewMessage(message: newMessage));
    });
    _subReadMessages = _messagesRepository.readMessagesStream.listen((data) {
      add(ChatsEventReadMessages(updates: data));
    });
  }

  void _onReadMessages(
    ChatsEventReadMessages event,
    Emitter<ChatsState> emit,
  ) async {
    final chatIndex = _data.chats.indexWhere(
      (chat) => chat.id == event.updates.chatId,
    );
    if (chatIndex == -1 ||
        event.updates.senderId == _userId ||
        event.updates.messagesIds.isEmpty) {
      return;
    }
    final newChats = _data.chats.toList();
    newChats[chatIndex] = newChats[chatIndex].copyWith(
      unreadCount:
          (newChats[chatIndex].unreadCount - event.updates.messagesIds.length).clamp(
            0,
            999,
          ),
    );
    _data = _data.copyWith(chats: newChats);
    emit(ChatsStateBase(data: _data));
  }

  void _onNewMessage(ChatsEventNewMessage event, Emitter<ChatsState> emit) async {
    final chatId = event.message.chatId;
    final chatIndex = _data.chats.indexWhere((e) => e.id == chatId);
    if (chatIndex == -1) {
      /// get new chat
      try {
        final newChat = await _chatsRepository.getChatWithId(event.message.chatId);
        _data = _data.copyWith(chats: [newChat!, ..._data.chats]);
      } catch (e, st) {
        logger.e(e, stackTrace: st);
      }
    } else {
      final newList = _data.chats.toList();
      newList[chatIndex] = newList[chatIndex].copyWith(
        lastMessage: event.message,
        unreadCount: event.message.user.isCurrent
            ? 0
            : _data.chats[chatIndex].unreadCount + 1,
      );
      _data = _data.copyWith(chats: newList);
    }
    emit(ChatsStateBase(data: _data));
  }

  void _onLoad(ChatsEventLoad event, Emitter<ChatsState> emit) async {
    _data = _data.copyWith(isLoading: true);
    emit(ChatsStateBase(data: _data));

    try {
      final chats = await _chatsRepository.getChats();

      _data = _data.copyWith(chats: chats, isLoading: false);
      emit(ChatsStateBase(data: _data));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(ChatsStateError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subMessages.cancel();
    _subReadMessages.cancel();
    return super.close();
  }
}

///events
abstract class ChatsEvent {}

class ChatsEventLoad implements ChatsEvent {
  const ChatsEventLoad();
}

class ChatsEventNewMessage implements ChatsEvent {
  final Message message;

  const ChatsEventNewMessage({required this.message});
}

class ChatsEventReadMessages implements ChatsEvent {
  final ReadMessagesUpdate updates;

  const ChatsEventReadMessages({required this.updates});
}
