import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/models/user_profile.dart';

part 'user_states.freezed.dart';

abstract class UserState {}

@freezed
abstract class UserStateBase with _$UserStateBase implements UserState {
  const factory UserStateBase({required UserData data}) = _UserStateBase;

  factory UserStateBase.initial() => UserStateBase(data: UserData.initial());
}

@freezed
abstract class UserStateMessage with _$UserStateMessage implements UserState {
  const factory UserStateMessage({required String message, @Default(false) bool isError}) = _UserStateMessage;
}

@freezed
abstract class UserStateUpdateUser with _$UserStateUpdateUser implements UserState {
  const factory UserStateUpdateUser({required User user}) = _UserStateUpdateUser;
}

@freezed
abstract class UserData with _$UserData {
  const factory UserData({
    required UserProfile? profile,
    @Default(true) bool isLoading,
  }) = _UserData;

  factory UserData.initial() => const UserData(profile: null);
}
