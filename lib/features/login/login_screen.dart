import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_button.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/validators.dart';

import 'bloc/login_bloc.dart';
import 'bloc/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateControllers(LoginData state) {
    _emailController.text = state.email;
    _passwordController.text = state.password;
    _confirmPasswordController.text = state.confirmPassword;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) =>
          LoginBloc(authController: Dependencies.of(context).authController),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginStateError) {
            context.showSnackBar(text: state.message, color: KlmColors.errorRed);
          }

          if (state is LoginStateBase && state.updateControllers) {
            _updateControllers(state.loginData);
          }
        },
        builder: (context, state) {
          if (state is! LoginStateBase) return SizedBox();

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'KepLeoMax',
                      style: context.textTheme.bodyMedium?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 52),
                    KlmTextField(
                      controller: _emailController,
                      validators: [UiValidator.emailValidator],
                      onChanged: (text) {
                        context.read<LoginBloc>().add(
                          LoginEventEditEmail(email: text),
                        );
                      },
                      label: 'Email',
                      showErrors: state.loginData.isButtonPressed,
                      readOnly: state.loginData.isLoading,
                    ),
                    const SizedBox(height: 20),
                    KlmTextField(
                      controller: _passwordController,
                      validators: [UiValidator.passwordValidator],
                      onChanged: (text) {
                        context.read<LoginBloc>().add(
                          LoginEventEditPassword(password: text),
                        );
                      },
                      label: 'Password',
                      showErrors: state.loginData.isButtonPressed,
                      readOnly: state.loginData.isLoading,
                    ),
                    const SizedBox(height: 20),
                    if (state.loginData.screenState is LoginScreenRegister)
                      KlmTextField(
                        controller: _confirmPasswordController,
                        validators: [
                          UiValidator.createConfirmPasswordValidator(
                            _passwordController,
                          ),
                        ],
                        onChanged: (text) {
                          context.read<LoginBloc>().add(
                            LoginEventEditConfirmPassword(confirmPassword: text),
                          );
                        },
                        label: 'Confirm password',
                        showErrors: state.loginData.isButtonPressed,
                        readOnly: state.loginData.isLoading,
                      ),
                    const SizedBox(height: 40),
                    KlmButton(
                      onPressed: () {
                        context.read<LoginBloc>().add(
                          state.loginData.screenState.event(),
                        );
                      },
                      text: state.loginData.screenState.buttonText(),
                      width: 200,
                      isLoading: state.loginData.isLoading,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: state.loginData.isLoading
                          ? null
                          : () {
                              context.read<LoginBloc>().add(
                                LoginEventChangeScreenState(
                                  state.loginData.screenState.subButtonNextState(),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        overlayColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.all(8),
                        minimumSize: Size.zero,
                      ),
                      child: Text(
                        state.loginData.screenState.subButtonText(),
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: state.loginData.isLoading
                              ? Colors.grey.shade600
                              : Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
