import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/user/bloc/user_states.dart';
import 'package:kepleomax/main.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final int _userId;
  late UserData _userData = UserData.initial();

  UserBloc({required UserRepository userRepository, required int userId})
    : _userRepository = userRepository,
      _userId = userId,
      super(UserStateBase.initial()) {
    on<UserEvent>(
      (event, emit) => switch (event) {
        UserEventLoad event => _onLoad(event, emit),
        UserEventUpdateProfile event => _onUpdateProfile(event, emit),
        _ => () {},
      },
      transformer: sequential(),
    );
  }

  void _onLoad(UserEventLoad event, Emitter<UserState> emit) async {
    _userData = _userData.copyWith(isLoading: true, profile: null);
    emit(UserStateBase(data: _userData));

    UserProfile? profile;

    try {
      profile = await _userRepository.getUserProfile(_userId);
    } catch (e, st) {
      logger.e(e, stackTrace: st);

      emit(UserStateMessage(message: e.userErrorMessage, isError: true));
    } finally {
      _userData = _userData.copyWith(profile: profile, isLoading: false);
      emit(UserStateBase(data: _userData));
    }
  }

  void _onUpdateProfile(
    UserEventUpdateProfile event,
    Emitter<UserState> emit,
  ) async {
    if (event.newProfile == _userData.profile) {
      return;
    }

    _userData = _userData.copyWith(isLoading: true);
    emit(UserStateBase(data: _userData));

    try {
      final newProfile = await _userRepository.updateProfile(
        event.newProfile,
        updateImage:
            _userData.profile!.user.profileImage !=
            event.newProfile.user.profileImage,
      );

      _userData = _userData.copyWith(profile: newProfile);
      emit(UserStateUpdateUser(user: newProfile.user));
      emit(const UserStateMessage(message: 'Changes saved'));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(UserStateMessage(message: e.userErrorMessage, isError: true));
    } finally {
      _userData = _userData.copyWith(isLoading: false);
      emit(UserStateBase(data: _userData));
    }
  }
}

/// Events
abstract class UserEvent {}

class UserEventLoad implements UserEvent {
  const UserEventLoad();
}

class UserEventUpdateProfile implements UserEvent {
  final UserProfile newProfile;

  const UserEventUpdateProfile({required this.newProfile});
}
