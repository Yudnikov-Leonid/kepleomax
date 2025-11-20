import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/features/people/bloc/people_state.dart';
import 'package:kepleomax/main.dart';

const _pagingLimit = 12;

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  final UserRepository _userRepository;

  late PeopleData _data = PeopleData.initial();

  PeopleBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(PeopleStateBase.initial()) {
    on<PeopleEventEditSearch>(_onEditSearch);
    on<PeopleEventLoad>(_onLoad);
    on<PeopleEventLoadMore>(_onLoadMore);
  }

  int _requestLastTimeCalled = 0;
  bool _isLoadingMore = false;

  void _onLoadMore(PeopleEventLoadMore event, Emitter<PeopleState> emit) async {
    if (_data.isLoading || _data.isAllUsersLoaded || _isLoadingMore) return;
    _isLoadingMore = true;

    final now = DateTime.now().millisecondsSinceEpoch;
    _requestLastTimeCalled = now;

    try {
      final newUsers = await _userRepository.search(
        search: _data.searchText,
        limit: _pagingLimit,
        offset: _data.users.length,
      );

      if (_requestLastTimeCalled != now) {
        _isLoadingMore = false;
        return;
      }

      _data = _data.copyWith(
        users: [..._data.users, ...newUsers],
        isAllUsersLoaded: newUsers.length < _pagingLimit,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PeopleStateError(message: e.toString()));
    } finally {
      _isLoadingMore = false;
      emit(PeopleStateBase(data: _data));
    }
  }

  void _onLoad(PeopleEventLoad event, Emitter<PeopleState> emit) async {
    _data = _data.copyWith(isLoading: true);
    emit(PeopleStateBase(data: _data));

    final now = DateTime.now().millisecondsSinceEpoch;
    _requestLastTimeCalled = now;
    try {
      final newUsers = await _userRepository.search(
        search: '',
        limit: _pagingLimit,
        offset: 0,
      );

      if (_requestLastTimeCalled != now) {
        /// other event to fetch users was called, don't need to handle this and stop loading animation
        return;
      }
      _data = _data.copyWith(
        users: newUsers,
        isAllUsersLoaded: newUsers.length < _pagingLimit,
        isLoading: false
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PeopleStateError(message: e.toString()));
      _data = _data.copyWith(isLoading: false, isAllUsersLoaded: true);
    } finally {
      emit(PeopleStateBase(data: _data));
    }
  }

  void _onEditSearch(PeopleEventEditSearch event, Emitter<PeopleState> emit) async {
    _data = _data.copyWith(searchText: event.text);
    emit(PeopleStateBase(data: _data));

    final now = DateTime.now().millisecondsSinceEpoch;
    _requestLastTimeCalled = now;

    if (_requestLastTimeCalled != now) {
      /// other event was called, isLoading: false will call there
      return;
    }

    _data = _data.copyWith(isLoading: true);
    emit(PeopleStateBase(data: _data));

    try {
      final newUsers = await _userRepository.search(
        search: _data.searchText,
        limit: _pagingLimit,
        offset: 0,
      );

      if (_requestLastTimeCalled != now) {
        return;
      }

      _data = _data.copyWith(
        users: newUsers,
        isAllUsersLoaded: newUsers.length < _pagingLimit,
        isLoading: false,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PeopleStateError(message: e.toString()));
      _data = _data.copyWith(isLoading: false, isAllUsersLoaded: true);
    } finally {
      emit(PeopleStateBase(data: _data));
    }
  }
}

/// events
abstract class PeopleEvent {}

class PeopleEventEditSearch implements PeopleEvent {
  final String text;

  const PeopleEventEditSearch({required this.text});
}

class PeopleEventLoad implements PeopleEvent {
  const PeopleEventLoad();
}

class PeopleEventLoadMore implements PeopleEvent {
  const PeopleEventLoadMore();
}
