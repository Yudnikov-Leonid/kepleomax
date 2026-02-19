import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/data/messenger/messenger_repository.dart';
import 'package:kepleomax/core/data/models/chats_collection.dart';
import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
import 'package:kepleomax/core/logger.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final MessengerRepository _messengerRepository;
  final ConnectionRepository _connectionRepository;
  late ChatsData _data = ChatsData.initial();
  StreamSubscription? _chatsUpdatesSub;
  late StreamSubscription _subConnectionState;

  /// fot testing
  final Duration callsTimeout;

  ChatsBloc({
    required MessengerRepository messengerRepository,
    required ConnectionRepository connectionRepository,
    this.callsTimeout = const Duration(milliseconds: 500),
  }) : _messengerRepository = messengerRepository,
       _connectionRepository = connectionRepository,
       super(ChatsStateBase.initial()) {
    _subConnectionState = _connectionRepository.connectionStateStream.listen(
      (isConnected) => add(_ChatsEventConnectingChanged(isConnected)),
    );
    _chatsUpdatesSub = _chatsUpdatesSub = _messengerRepository.chatsUpdatesStream
        .listen(
          (newList) {
            add(_ChatsEventEmitChatsList(data: newList));
          },
          onError: (e, st) {
            add(_ChatsEventEmitError(error: e, stackTrace: st));
          },
        );

    on<ChatsEvent>(
      (event, emit) => switch (event) {
        ChatsEventLoadCache event => _onLoadCache(event, emit),
        ChatsEventLoad event => _onLoad(event, emit),
        ChatsEvent _ => () {},
      },
      transformer: sequential(),
    );
    on<ChatsEventReconnect>(_onReconnect);

    /// local events
    on<_ChatsEventConnectingChanged>(_onConnectingChanged);
    on<_ChatsEventEmitChatsList>(_onEmitChatsList);
    on<_ChatsEventEmitError>(_onEmitError);
  }

  void _onLoadCache(ChatsEventLoadCache event, Emitter<ChatsState> emit) async {
    try {
      await _messengerRepository.loadChatsFromCache();
    } catch (e, st) {
      add(_ChatsEventEmitError(error: e, stackTrace: st));
    }
  }

  int _lastTimeLoadWasCalled = 0;

  void _onLoad(ChatsEventLoad event, Emitter<ChatsState> emit) async {
    /// TODO make this with bloc_concurrency, make isTesting better
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastTimeLoadWasCalled + 1000 > now && !flavor.isTesting) {
      return;
    }
    _lastTimeLoadWasCalled = now;

    _data = _data.copyWith(isLoading: true);
    emit(ChatsStateBase(data: _data));

    try {
      await _messengerRepository.loadChats();
    } catch (e, st) {
      /// TODO ?
      add(_ChatsEventEmitError(error: e, stackTrace: st));
    }
  }

  void _onEmitChatsList(
    _ChatsEventEmitChatsList event,
    Emitter<ChatsState> emit,
  ) async {
    final data = event.data;
    _data = _data.copyWith(
      chats: data.chats.toList(growable: false), // TODO
      totalUnreadCount: data.chats.fold(0, (a, b) => a + b.unreadCount),
      isLoading: data.fromCache,
    );
    emit(ChatsStateBase(data: _data));
  }

  void _onEmitError(_ChatsEventEmitError event, Emitter<ChatsState> emit) {
    logger.e(event.error, stackTrace: event.stackTrace);
    emit(ChatsStateMessage(message: event.error.userErrorMessage, isError: true));
    emit(ChatsStateBase(data: _data));
  }

  void _onReconnect(ChatsEventReconnect event, Emitter<ChatsState> emit) {
    _connectionRepository.reconnect(onlyIfDisconnected: event.onlyIfNot);
  }

  void _onConnectingChanged(
    _ChatsEventConnectingChanged event,
    Emitter<ChatsState> emit,
  ) {
    _data = _data.copyWith(isConnected: event.isConnected);
    if (event.isConnected) {
      add(const ChatsEventLoad());
    } else {
      emit(ChatsStateBase(data: _data));
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

/// call it on initState. Load will be called on ws connected
class ChatsEventLoadCache implements ChatsEvent {
  const ChatsEventLoadCache();
}

class ChatsEventLoad implements ChatsEvent {
  const ChatsEventLoad();
}

class ChatsEventReconnect implements ChatsEvent {
  final bool onlyIfNot;

  const ChatsEventReconnect({this.onlyIfNot = false});
}

class _ChatsEventConnectingChanged implements ChatsEvent {
  final bool isConnected;

  const _ChatsEventConnectingChanged(this.isConnected);
}

class _ChatsEventEmitChatsList implements ChatsEvent {
  final ChatsCollection data;

  const _ChatsEventEmitChatsList({required this.data});
}

class _ChatsEventEmitError implements ChatsEvent {
  final Object error;
  final StackTrace stackTrace;

  const _ChatsEventEmitError({required this.error, required this.stackTrace});
}
