import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/chats_repository.dart';
import 'package:kepleomax/core/data/messages_repository.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:kepleomax/main.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final IChatsRepository _chatsRepository;
  final IMessagesRepository _messagesRepository;
  late ChatsData _data = ChatsData.initial();
  StreamSubscription? _chatsUpdatesSub;
  late StreamSubscription _subConnectionState;
  final int _userId;

  /// fot testing
  final Duration callsTimeout;

  ChatsBloc({
    required IChatsRepository chatsRepository,
    required IMessagesRepository messagesRepository,
    required int userId,
    this.callsTimeout = const Duration(milliseconds: 500),
  }) : _chatsRepository = chatsRepository,
       _messagesRepository = messagesRepository,
       _userId = userId,
       super(ChatsStateBase.initial()) {
    _subConnectionState = _messagesRepository.connectionStateStream.listen(
      (isConnected) => add(ChatsEventConnectingChanged(isConnected)),
      cancelOnError: false,
    );

    on<ChatsEvent>(
      (event, emit) => switch (event) {
        ChatsEventLoad event => _onLoad(event, emit),
        ChatsEvent _ => () {},
      },
      transformer: sequential(),
    );
    on<ChatsEventLoadCache>(_onLoadCache);
    on<ChatsEventReconnect>(_onReconnect);
    on<ChatsEventConnectingChanged>(_onConnectingChanged);
    on<ChatsEventEmitChatsList>(_onEmitChatsList);
  }

  int _lastTimeLoadWasCalled = 0;

  void _onLoad(ChatsEventLoad event, Emitter<ChatsState> emit) async {
    print('MyLog2 onLoad');
    _data = _data.copyWith(isLoading: true);
    emit(ChatsStateBase(data: _data));

    _chatsUpdatesSub?.cancel();
    _chatsUpdatesSub = _chatsRepository
        .getChats2(withCache: event.withCache)
        .listen(
          (newList) {
            add(ChatsEventEmitChatsList(data: newList));
          },
          onError: (e, st) {
            logger.e(e, stackTrace: st);
            emit(ChatsStateMessage(message: e.userErrorMessage, isError: true));
            emit(ChatsStateBase(data: _data));
          },
          cancelOnError: false,
        );
  }

  @Deprecated('use _onLoad instead')
  void _onLoadOld(ChatsEventLoad event, Emitter<ChatsState> emit) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - callsTimeout.inMilliseconds < _lastTimeLoadWasCalled) {
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

  @Deprecated('this logic is moved to _onLoad2')
  void _onLoadCache(ChatsEventLoadCache event, Emitter<ChatsState> emit) async {
    // try {
    //   final cache = await _chatsRepository.getChatsFromCache();
    //   _data = _data.copyWith(
    //     chats: cache,
    //     totalUnreadCount: cache.fold(0, (a, b) => a + b.unreadCount),
    //   );
    //   emit(ChatsStateBase(data: _data));
    // } catch (e, st) {
    //   logger.e(e, stackTrace: st);
    //   emit(ChatsStateError(message: e.userErrorMessage));
    // }
  }

  void _onEmitChatsList(
    ChatsEventEmitChatsList event,
    Emitter<ChatsState> emit,
  ) async {
    print('MyLog ChatsRepository emitChatsList');
    _data = _data.copyWith(
      chats: event.data.chats,
      totalUnreadCount: event.data.chats.fold(0, (a, b) => a + b.unreadCount),
      isLoading: event.data.fromCache,
    );
    emit(ChatsStateBase(data: _data));
  }

  void _onReconnect(ChatsEventReconnect event, Emitter<ChatsState> emit) {
    _messagesRepository.reconnect(onlyIfNot: event.onlyIfNot);
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

  @override
  Future<void> close() {
    _chatsUpdatesSub?.cancel();
    _subConnectionState.cancel();
    return super.close();
  }
}

///events
abstract class ChatsEvent {}

class ChatsEventLoad implements ChatsEvent {
  final bool withCache;

  const ChatsEventLoad({this.withCache = true});
}

/// call it on initState. Load will be called on ws connected
class ChatsEventLoadCache implements ChatsEvent {
  const ChatsEventLoadCache();
}

class ChatsEventReconnect implements ChatsEvent {
  final bool onlyIfNot;

  const ChatsEventReconnect({this.onlyIfNot = false});
}

class ChatsEventConnectingChanged implements ChatsEvent {
  final bool isConnected;

  const ChatsEventConnectingChanged(this.isConnected);
}

class ChatsEventEmitChatsList implements ChatsEvent {
  final ChatsCollection data;

  const ChatsEventEmitChatsList({required this.data});
}
