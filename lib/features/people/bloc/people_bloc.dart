import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/people/bloc/people_state.dart';
import 'package:kepleomax/main.dart';
import 'package:rxdart/rxdart.dart';

const _pagingLimit = 12;

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  final UserRepository _userRepository;

  late PeopleData _data = PeopleData.initial();

  PeopleBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(PeopleStateBase.initial()) {
    on<PeopleEventLoad>(
      _onLoad,
      transformer: (events, mapper) => Rx.merge([
        events
            .throttleTime(const Duration(seconds: 3)),
        events
            .debounceTime(const Duration(milliseconds: 900))
            .throttleTime(const Duration(milliseconds: 750)),
      ]).flatMap(mapper),
    );
    on<PeopleEventInitialLoad>(_onInitialLoad);
    on<PeopleEventLoadMore>(_onLoadMore);
    on<PeopleEventEditSearch>(_onEditSearch);
  }

  void _onInitialLoad(
      PeopleEventInitialLoad event,
      Emitter<PeopleState> emit,
      ) async {
    _data = _data.copyWith(isLoading: true);
    emit(PeopleStateBase(data: _data));

    try {
      final newUsers = await _userRepository.search(
        search: '',
        limit: _pagingLimit,
        offset: 0,
      );

      _data = _data.copyWith(
        users: newUsers,
        isAllUsersLoaded: newUsers.length < _pagingLimit,
        isLoading: false,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PeopleStateError(message: e.userErrorMessage));
      _data = _data.copyWith(isLoading: false, isAllUsersLoaded: true);
    } finally {
      emit(PeopleStateBase(data: _data));
    }
  }

  void _onLoad(PeopleEventLoad event, Emitter<PeopleState> emit) async {
    _data = _data.copyWith(isLoading: true);
    emit(PeopleStateBase(data: _data));

    print('searchEvent: ${_data.searchText}');
    try {
      final newUsers = await _userRepository.search(
        search: _data.searchText,
        limit: _pagingLimit,
        offset: 0,
      );

      _data = _data.copyWith(
        users: newUsers,
        isAllUsersLoaded: newUsers.length < _pagingLimit,
        isLoading: false,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PeopleStateError(message: e.userErrorMessage));
      _data = _data.copyWith(isLoading: false, isAllUsersLoaded: true);
    } finally {
      emit(PeopleStateBase(data: _data));
    }
  }

  void _onLoadMore(PeopleEventLoadMore event, Emitter<PeopleState> emit) async {
    if (_data.isLoading || _data.isAllUsersLoaded) return;

    try {
      final newUsers = await _userRepository.search(
        search: _data.searchText,
        limit: _pagingLimit,
        offset: _data.users.length,
      );
      _data = _data.copyWith(
        /// todo make paging better as on posts page
        users: {..._data.users, ...newUsers}.toList(),
        isAllUsersLoaded: newUsers.length < _pagingLimit,
      );
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(PeopleStateError(message: e.userErrorMessage));
    } finally {
      emit(PeopleStateBase(data: _data));
    }
  }

  void _onEditSearch(PeopleEventEditSearch event, Emitter<PeopleState> emit) async {
    _data = _data.copyWith(searchText: event.text);
    emit(PeopleStateBase(data: _data));
    add(const PeopleEventLoad());
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

/// used when needs to call load without debounce
class PeopleEventInitialLoad implements PeopleEvent {
  const PeopleEventInitialLoad();
}

class PeopleEventLoadMore implements PeopleEvent {
  const PeopleEventLoadMore();
}
