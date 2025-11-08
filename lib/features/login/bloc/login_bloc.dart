import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/presentation/validators.dart';
import 'package:kepleomax/main.dart';

import 'login_state.dart';

const minPasswordLength = 6;

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthController _authController;

  LoginBloc({required AuthController authController})
    : _authController = authController,
      super(LoginStateBase.initial()) {
    _loginData = LoginData.initial();

    on<LoginEventLogin>(_onLogin);
    on<LoginEventEditEmail>(_onEditEmail);
    on<LoginEventEditPassword>(_onEditPassword);
  }

  late LoginData _loginData;

  void _onLogin(LoginEventLogin event, Emitter<LoginState> emit) async {
    _loginData = _loginData.copyWith(isButtonPressed: true);
    emit(LoginStateBase(loginData: _loginData));

    // TODO made it better, now validators also are used in login_screen
    if (UiValidator.emailValidator(_loginData.email) != null ||
        UiValidator.createLengthValidator(
              minPasswordLength,
            ).call(_loginData.password) !=
            null) {
      logger.e('Validation fields error, _loginData: $_loginData');
      return;
    }

    try {
      _loginData = _loginData.copyWith(isLoading: true);
      emit(LoginStateBase(loginData: _loginData));

      await Future.delayed(const Duration(seconds: 5), () {});

      await _authController.login(
        email: _loginData.email,
        password: _loginData.password,
      );
      _loginData = LoginData.initial();
      emit(LoginStateBase(loginData: _loginData));
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(LoginStateError(message: e.toString()));
    } finally {
      _loginData = _loginData.copyWith(isLoading: false);
      emit(LoginStateBase(loginData: _loginData));
    }
  }

  void _onEditEmail(LoginEventEditEmail event, Emitter<LoginState> emit) {
    _loginData = _loginData.copyWith(email: event.email);
    emit(LoginStateBase(loginData: _loginData));
  }

  void _onEditPassword(LoginEventEditPassword event, Emitter<LoginState> emit) {
    _loginData = _loginData.copyWith(password: event.password);
    emit(LoginStateBase(loginData: _loginData));
  }
}

/// events
abstract class LoginEvent {}

class LoginEventLogin implements LoginEvent {
  const LoginEventLogin();
}

class LoginEventEditEmail implements LoginEvent {
  final String email;
  LoginEventEditEmail({required this.email});
}

class LoginEventEditPassword implements LoginEvent {
  final String password;
  LoginEventEditPassword({required this.password});
}