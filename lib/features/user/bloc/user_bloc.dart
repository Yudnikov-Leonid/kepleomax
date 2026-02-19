import 'dart:async';

import 'package:kepleomax/core/data/connection_repository.dart';
import 'package:kepleomax/core/logger.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/models/user_profile.dart';
import 'package:kepleomax/core/network/websockets/models/online_status_update.dart';
import 'package:kepleomax/core/presentation/user_error_message.dart';
import 'package:kepleomax/features/user/bloc/user_states.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final ConnectionRepository _connectionRepository;

  final int _userId;
  late UserData _data = UserData.initial();
  late final StreamSubscription _onlineUpdatesSub;

  UserBloc({
    required UserRepository userRepository,
    required ConnectionRepository connectionRepository,
    required int userId,
  }) : _userRepository = userRepository,
       _connectionRepository = connectionRepository,
       _userId = userId,
       super(UserStateBase.initial()) {
    on<UserEvent>(
      (event, emit) => switch (event) {
        UserEventLoad event => _onLoad(event, emit),
        UserEventUpdateProfile event => _onUpdateProfile(event, emit),
        _UserEventUpdateOnlineStatus event => _onUpdateOnlineStatus(event, emit),
        _ => () {},
      },
      transformer: sequential(),
    );
    _connectionRepository.listenOnlineStatusUpdates(usersIds: [_userId]);
    _onlineUpdatesSub = _connectionRepository.onlineUpdatesStream.listen((update) {
      if (update.userId == userId) {
        add(_UserEventUpdateOnlineStatus(update));
      }
    });
  }

  void _onLoad(UserEventLoad event, Emitter<UserState> emit) async {
    _data = _data.copyWith(isLoading: true, profile: null);
    emit(UserStateBase(data: _data));

    UserProfile? profile;

    try {
      profile = await _userRepository.getUserProfile(_userId);
    } catch (e, st) {
      logger.e(e, stackTrace: st);

      emit(UserStateMessage(message: e.userErrorMessage, isError: true));
    } finally {
      _data = _data.copyWith(profile: profile, isLoading: false);
      emit(UserStateBase(data: _data));
    }
  }

  void _onUpdateProfile(
    UserEventUpdateProfile event,
    Emitter<UserState> emit,
  ) async {
    if (event.newProfile == _data.profile) {
      return;
    }

    _data = _data.copyWith(isLoading: true);
    emit(UserStateBase(data: _data));

    try {
      final newProfile = await _userRepository.updateProfile(
        event.newProfile,
        updateImage:
            _data.profile!.user.profileImage != event.newProfile.user.profileImage,
      );

      _data = _data.copyWith(profile: newProfile);
      emit(UserStateUpdateUser(user: newProfile.user));
      emit(const UserStateMessage(message: 'Changes saved'));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(UserStateMessage(message: e.userErrorMessage, isError: true));
    } finally {
      _data = _data.copyWith(isLoading: false);
      emit(UserStateBase(data: _data));
    }
  }

  void _onUpdateOnlineStatus(
    _UserEventUpdateOnlineStatus event,
    Emitter<UserState> emit,
  ) {
    _data = _data.copyWith(
      profile: _data.profile?.copyWith(
        user: _data.profile!.user.copyWith(
          isOnline: event.update.isOnline,
          lastActivityTime: event.update.lastActivityTime,
        ),
      ),
    );
    emit(UserStateBase(data: _data));
  }

  @override
  Future<void> close() {
    _onlineUpdatesSub.cancel();
    return super.close();
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

class _UserEventUpdateOnlineStatus implements UserEvent {
  final OnlineStatusUpdate update;

  _UserEventUpdateOnlineStatus(this.update);
}
