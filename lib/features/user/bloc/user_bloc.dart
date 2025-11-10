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
    on<UserEventUpdateProfile>(_onUpdateProfile);
  }

  late UserData _userData = UserData.initial();

  void _onLoad(UserEventLoad event, Emitter<UserState> emit) async {
    _userData = _userData.copyWith(isLoading: true);
    emit(UserStateBase(userData: _userData));

    final userId = event.userId;

    UserProfile? profile;

    try {
      profile = await _userRepository.getUserProfile(userId);
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(UserStateError(message: e.toString()));
    } finally {
      _userData = _userData.copyWith(profile: profile, isLoading: false);
      emit(UserStateBase(userData: _userData));
    }
  }

  void _onUpdateProfile(UserEventUpdateProfile event,
      Emitter<UserState> emit,) async {
    if (event.newProfile == _userData.profile) {
      return;
    }

    _userData = _userData.copyWith(isLoading: true);
    emit(UserStateBase(userData: _userData));

    try {
      final newProfile = await _userRepository.updateProfile(
        event.newProfile,
        updateImage: _userData.profile!.user.profileImage !=
            event.newProfile.user.profileImage,
      );

      _userData = _userData.copyWith(profile: newProfile);
      emit(UserStateUpdateUser(user: newProfile.user));
      emit(UserStateMessage(message: 'Changes saved'));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(UserStateError(message: e.toString()));
    } finally {
      _userData = _userData.copyWith(isLoading: false);
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

class UserEventUpdateProfile implements UserEvent {
  final UserProfile newProfile;

  UserEventUpdateProfile({required this.newProfile});
}
