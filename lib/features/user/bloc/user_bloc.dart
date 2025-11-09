import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/features/user/bloc/user_states.dart';
import 'package:kepleomax/main.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(UserStateBase.initial()) {
    on<UserEventLoad>(_onLoad);
  }

  late UserData _userData = UserData.initial();

  void _onLoad(UserEventLoad event, Emitter<UserState> emit) async {
    _userData = _userData.copyWith(isLoading: true, isError: false);

    final userId = event.userId;

    UserProfile? profile;

    try {
      profile = await _userRepository.getUserProfile(userId);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      _userData = _userData.copyWith(
        isError: true,
      );
      emit(UserStateError(message: e.toString()));
    } finally {
      _userData = _userData.copyWith(user: profile?.user, profile: profile, isLoading: false);
      emit(UserStateBase(userData: _userData));
    }
  }
}

/// Events
abstract class UserEvent {}

class UserEventLoad implements UserEvent {
  final int userId;

  UserEventLoad({required this.userId});
}
