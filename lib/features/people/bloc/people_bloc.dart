import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:kepleomax/core/data/models/users_collection.dart';
import 'package:kepleomax/core/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/people/bloc/people_state.dart';
import 'package:rxdart/rxdart.dart';

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  final UserRepository _userRepository;
  late final StreamSubscription _usersSub;

  late PeopleData _data = PeopleData.initial();

  PeopleBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(PeopleStateBase.initial()) {
    on<_PeopleEventLoad>(
      _onLoad,
      transformer: (events, mapper) => Rx.merge([
        events.throttleTime(const Duration(seconds: 3)),
        events
            .debounceTime(const Duration(milliseconds: 900))
            .throttleTime(const Duration(milliseconds: 750)),
      ]).flatMap(mapper),
    );
    on<PeopleEventLoadMore>(_onLoadMore, transformer: sequential());
    on<PeopleEventInstantLoad>(_onInstantLoad);
    on<PeopleEventEditSearch>(_onEditSearch);
    on<_PeopleEventEmitUsers>(_onEmitUsers);

    _usersSub = _userRepository.usersStream.listen((users) {
      add(_PeopleEventEmitUsers(users));
    });
  }

  void _onInstantLoad(
    PeopleEventInstantLoad event,
    Emitter<PeopleState> emit,
  ) async {
    _data = _data.copyWith(isLoading: true);
    emit(PeopleStateBase(data: _data));

    try {
      await _userRepository.loadSearch(search: '');
    } catch (e, st) {
      _onError(e, st, emit);
    }
  }

  void _onLoad(_PeopleEventLoad event, Emitter<PeopleState> emit) async {
    _data = _data.copyWith(isLoading: true);
    emit(PeopleStateBase(data: _data));

    print('searchEvent: ${_data.searchText}');
    try {
      await _userRepository.loadSearch(search: _data.searchText);
    } catch (e, st) {
      _onError(e, st, emit);
    }
  }

  void _onLoadMore(PeopleEventLoadMore event, Emitter<PeopleState> emit) async {
    if (_data.isLoading || _data.isAllUsersLoaded) return;

    try {
      await _userRepository.loadMore();
    } catch (e, st) {
      _onError(e, st, emit);
    }
  }

  void _onEditSearch(PeopleEventEditSearch event, Emitter<PeopleState> emit) async {
    _data = _data.copyWith(searchText: event.text);
    emit(PeopleStateBase(data: _data));
    add(const _PeopleEventLoad());
  }

  void _onEmitUsers(_PeopleEventEmitUsers event, Emitter<PeopleState> emit) {
    final collection = event.collection;
    _data = _data.copyWith(users: collection.users.toList(), isLoading: false);
    if (collection.allUsersLoaded != null) {
      _data = _data.copyWith(isAllUsersLoaded: collection.allUsersLoaded!);
    }
    emit(PeopleStateBase(data: _data));
  }

  void _onError(Object e, StackTrace st, Emitter<PeopleState> emit) {
    logger.e(e, stackTrace: st);
    emit(PeopleStateError(message: e.userErrorMessage));
    _data = _data.copyWith(isLoading: false, isAllUsersLoaded: true);
    emit(PeopleStateBase(data: _data));
  }

  @override
  Future<void> close() {
    _usersSub.cancel();
    return super.close();
  }
}

/// events
abstract class PeopleEvent {}

class PeopleEventEditSearch implements PeopleEvent {
  final String text;

  const PeopleEventEditSearch({required this.text});
}

class _PeopleEventLoad implements PeopleEvent {
  const _PeopleEventLoad();
}

/// used when needs to call load without debounce
class PeopleEventInstantLoad implements PeopleEvent {
  const PeopleEventInstantLoad();
}

class PeopleEventLoadMore implements PeopleEvent {
  const PeopleEventLoadMore();
}

class _PeopleEventEmitUsers implements PeopleEvent {
  final UsersCollection collection;

  _PeopleEventEmitUsers(this.collection);
}
