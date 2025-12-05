import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kepleomax/features/login/bloc/login_bloc.dart';

part 'login_state.freezed.dart';

/// states
abstract class LoginState {}

@freezed
abstract class LoginStateBase with _$LoginStateBase implements LoginState {
  const factory LoginStateBase({required LoginData data, @Default(false) bool updateControllers}) = _LoginStateBase;

  factory LoginStateBase.initial() => LoginStateBase(
    data: LoginData.initial(),
  );
}

@freezed
abstract class LoginStateError with _$LoginStateError implements LoginState {
  const factory LoginStateError({required String message}) = _LoginStateError;
}


/// data
@freezed
abstract class LoginData with _$LoginData {
  const factory LoginData({
    required String email,
    required String password,
    required String confirmPassword,
    required bool isButtonPressed,
    required bool isLoading,
    required LoginScreenState screenState,
  }) = _LoginData;

  factory LoginData.initial() => LoginData(
    email: '',
    password: '',
    confirmPassword: '',
    isButtonPressed: false,
    isLoading: false,
    screenState: LoginScreenState.login(),
  );
}

/// state object
abstract class LoginScreenState {
  LoginEvent event();
  LoginScreenState subButtonNextState();
  String buttonText();
  String subButtonText();

  static LoginScreenLogin login() => LoginScreenLogin();
  static LoginScreenRegister register() => LoginScreenRegister();
}

class LoginScreenLogin implements LoginScreenState {
  LoginScreenLogin._internal();
  static final LoginScreenLogin _singleton = LoginScreenLogin._internal();
  factory LoginScreenLogin() {
    return _singleton;
  }

  @override
  LoginEvent event() => const LoginEventLogin();

  @override
  String buttonText() => 'Login';

  @override
  String subButtonText() => 'or register a new account';

  @override
  LoginScreenState subButtonNextState() => LoginScreenState.register();
}

class LoginScreenRegister implements LoginScreenState {
  LoginScreenRegister._internal();
  static final LoginScreenRegister _singleton = LoginScreenRegister._internal();
  factory LoginScreenRegister() {
    return _singleton;
  }

  @override
  LoginEvent event() => const LoginEventRegister();

  @override
  String buttonText() => 'Register';

  @override
  String subButtonText() => 'or login into existing account';

  @override
  LoginScreenState subButtonNextState() => LoginScreenState.login();
}