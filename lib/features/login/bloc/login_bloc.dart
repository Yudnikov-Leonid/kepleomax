import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/presentation/validators.dart';
import 'package:kepleomax/main.dart';

import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthController _authController;

  LoginBloc({required AuthController authController})
    : _authController = authController,
      super(LoginStateBase.initial()) {
    _loginData = LoginData.initial();

    on<LoginEventLogin>(_onLogin);
    on<LoginEventRegister>(_onRegister);
    on<LoginEventEditEmail>(_onEditEmail);
    on<LoginEventEditPassword>(_onEditPassword);
    on<LoginEventEditConfirmPassword>(_onEditConfirmPassword);
    on<LoginEventChangeScreenState>(_onChangeScreenState);
  }

  late LoginData _loginData;

  bool _validateFields({required bool needConfirm}) {
    // TODO made it better, now validators also are used in login_screen
    if (UiValidator.emailValidator(_loginData.email) != null ||
        UiValidator.passwordValidator(_loginData.password) != null) {
      return false;
    } else if (needConfirm &&
        UiValidator.confirmPasswordValidator(
              password: _loginData.password,
              confirmPassword: _loginData.confirmPassword,
            ) !=
            null) {
      return false;
    }

    return true;
  }

  void _onLogin(LoginEventLogin event, Emitter<LoginState> emit) async {
    _loginData = _loginData.copyWith(isButtonPressed: true);
    emit(LoginStateBase(loginData: _loginData));

    if (!_validateFields(needConfirm: false)) {
      logger.d('Validation fields error, _loginData: $_loginData');
      return;
    }

    try {
      _loginData = _loginData.copyWith(isLoading: true);
      emit(LoginStateBase(loginData: _loginData));

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

  void _onRegister(LoginEventRegister event, Emitter<LoginState> emit) async {
    _loginData = _loginData.copyWith(isButtonPressed: true);
    emit(LoginStateBase(loginData: _loginData));

    if (!_validateFields(needConfirm: true)) {
      logger.e('Validation fields error, _loginData: $_loginData');
      return;
    }

    try {
      _loginData = _loginData.copyWith(isLoading: true);
      emit(LoginStateBase(loginData: _loginData));

      await _authController.registerUser(
        email: _loginData.email,
        password: _loginData.password,
      );

      try {
        await _authController.login(
          email: _loginData.email,
          password: _loginData.password,
        );
      } catch (e, st) {
        logger.e(e, stackTrace: st);
        _loginData = _loginData.copyWith(
          screenState: LoginScreenState.login(),
          confirmPassword: '',
        );

        throw Exception(
          'The user is created, but an error occurred while login. Try to login again. Error: ${e}',
        );
      }

      _loginData = LoginData.initial();
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      emit(LoginStateError(message: e.toString()));
    } finally {
      _loginData = _loginData.copyWith(isLoading: false);
      emit(
        LoginStateBase(
          loginData: _loginData,
          updateControllers: _loginData.confirmPassword.isEmpty,
        ),
      );
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

  void _onEditConfirmPassword(
    LoginEventEditConfirmPassword event,
    Emitter<LoginState> emit,
  ) {
    _loginData = _loginData.copyWith(confirmPassword: event.confirmPassword);
    emit(LoginStateBase(loginData: _loginData));
  }

  void _onChangeScreenState(
    LoginEventChangeScreenState event,
    Emitter<LoginState> emit,
  ) {
    _loginData = _loginData.copyWith(
      screenState: event.state,
      isButtonPressed: false,
    );
    emit(LoginStateBase(loginData: _loginData));
  }
}

/// events
abstract class LoginEvent {}

class LoginEventLogin implements LoginEvent {
  const LoginEventLogin();
}

class LoginEventRegister implements LoginEvent {
  const LoginEventRegister();
}

class LoginEventChangeScreenState implements LoginEvent {
  final LoginScreenState state;

  const LoginEventChangeScreenState(this.state);
}

class LoginEventEditEmail implements LoginEvent {
  final String email;

  LoginEventEditEmail({required this.email});
}

class LoginEventEditPassword implements LoginEvent {
  final String password;

  LoginEventEditPassword({required this.password});
}

class LoginEventEditConfirmPassword implements LoginEvent {
  final String confirmPassword;

  LoginEventEditConfirmPassword({required this.confirmPassword});
}
