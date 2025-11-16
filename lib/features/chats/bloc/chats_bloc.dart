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
  late StreamSubscription _sub;

  ChatsBloc({
    required ChatsRepository chatsRepository,
    required MessagesRepository messagesRepository,
  }) : _chatsRepository = chatsRepository,
       _messagesRepository = messagesRepository,
       super(ChatsStateBase.initial()) {
    on<ChatsEventLoad>(_onLoad);
    on<ChatsEventNewMessage>(_onNewMessage);

    _sub = _messagesRepository.messagesStream.listen((newMessage) {
      print('event in chats bloc: $newMessage');
      add(ChatsEventNewMessage(message: newMessage));
    });
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
      newList[chatIndex] = newList[chatIndex].copyWith(lastMessage: event.message);
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
    _sub.cancel();
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
