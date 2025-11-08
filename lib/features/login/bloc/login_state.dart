import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

abstract class LoginState {}

@freezed
abstract class LoginStateBase with _$LoginStateBase implements LoginState {
  const factory LoginStateBase({required LoginData loginData}) = _LoginStateBase;

  factory LoginStateBase.initial() => LoginStateBase(
    loginData: LoginData.initial(),
  );
}

@freezed
abstract class LoginStateError with _$LoginStateError implements LoginState {
  const factory LoginStateError({required String message}) = _LoginStateError;
}

@freezed
abstract class LoginData with _$LoginData {
  const factory LoginData({
    required String email,
    required String password,
    required bool isButtonPressed,
    required bool isLoading,
  }) = _LoginData;

  factory LoginData.initial() => LoginData(
    email: '',
    password: '',
    isButtonPressed: false,
    isLoading: false,
  );
}