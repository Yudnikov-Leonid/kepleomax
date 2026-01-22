import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/data/messenger_repository.dart';
import 'package:kepleomax/core/data/models/chats_collection.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:kepleomax/main.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final IMessengerRepository _messengerRepository;
  final IConnectionRepository _connectionRepository;
  late ChatsData _data = ChatsData.initial();
  StreamSubscription? _chatsUpdatesSub;
  late StreamSubscription _subConnectionState;

  /// fot testing
  final Duration callsTimeout;

  ChatsBloc({
    required IMessengerRepository messengerRepository,
    required IConnectionRepository connectionRepository,
    this.callsTimeout = const Duration(milliseconds: 500),
  })
      : _messengerRepository = messengerRepository,
        _connectionRepository = connectionRepository,
        super(ChatsStateBase.initial()) {
    _subConnectionState = _connectionRepository.connectionStateStream.listen(
          (isConnected) => add(ChatsEventConnectingChanged(isConnected)),
      cancelOnError: false,
    );
    _chatsUpdatesSub = _chatsUpdatesSub = _messengerRepository.chatsUpdatesStream
        .listen(
          (newList) {
        add(ChatsEventEmitChatsList(data: newList));
      },
      onError: (e, st) {
        add(ChatsEventEmitError(error: e, stackTrace: st));
      },
      cancelOnError: false,
    );

    on<ChatsEvent>(
          (event, emit) =>
      switch (event) {
        ChatsEventLoad event => _onLoad(event, emit),
        ChatsEvent _ => () {},
      },
      transformer: sequential(),
    );
    on<ChatsEventReconnect>(_onReconnect);
    on<ChatsEventConnectingChanged>(_onConnectingChanged);
    on<ChatsEventEmitChatsList>(_onEmitChatsList);
    on<ChatsEventEmitError>(_onEmitError);
  }

  int _lastTimeLoadWasCalled = 0;

  void _onLoad(ChatsEventLoad event, Emitter<ChatsState> emit) async {
    /// TODO make this with bloc_concurrency
    final now = DateTime
        .now()
        .millisecondsSinceEpoch;
    if (_lastTimeLoadWasCalled + 1000 > now) {
      return;
    }
    _lastTimeLoadWasCalled = now;

    _data = _data.copyWith(isLoading: true);
    emit(ChatsStateBase(data: _data));

    try {
      await _messengerRepository.loadChats(withCache: event.withCache);
    } catch (e, st) {
      /// TODO
      add(ChatsEventEmitError(error: e, stackTrace: st));
    }
  }

  void _onEmitChatsList(ChatsEventEmitChatsList event,
      Emitter<ChatsState> emit,) async {
    _data = _data.copyWith(
      chats: event.data.chats.toList(growable: false), // TODO
      totalUnreadCount: event.data.chats.fold(0, (a, b) => a + b.unreadCount),
      isLoading: event.data.fromCache,
    );
    emit(ChatsStateBase(data: _data));
  }

  void _onEmitError(ChatsEventEmitError event, Emitter<ChatsState> emit) {
    logger.e(event.error, stackTrace: event.stackTrace);
    emit(ChatsStateMessage(message: event.error.userErrorMessage, isError: true));
    emit(ChatsStateBase(data: _data));
  }

  void _onReconnect(ChatsEventReconnect event, Emitter<ChatsState> emit) {
    _connectionRepository.reconnect(onlyIfNot: event.onlyIfNot);
  }

  void _onConnectingChanged(ChatsEventConnectingChanged event,
      Emitter<ChatsState> emit,) {
    _data = _data.copyWith(isConnected: event.isConnected);
    emit(ChatsStateBase(data: _data));
    if (event.isConnected) {
      add(const ChatsEventLoad(withCache: false));
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

/// call it on initState. Load also will be called on ws connected
class ChatsEventLoad implements ChatsEvent {
  final bool withCache;

  const ChatsEventLoad({this.withCache = true});
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

class ChatsEventEmitError implements ChatsEvent {
  final Object error;
  final StackTrace stackTrace;

  const ChatsEventEmitError({required this.error, required this.stackTrace});
}
