import 'package:flutter/material.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_button.dart';
import 'package:kepleomax/core/presentation/klm_textfield.dart';
import 'package:kepleomax/core/presentation/validators.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                onChanged: (text) {},
                label: 'Email',
                showErrors: _showErrors,
              ),
              const SizedBox(height: 20),
              KlmTextField(
                controller: _passwordController,
                validators: [UiValidator.createLengthValidator(6)],
                onChanged: (text) {},
                label: 'Password',
                showErrors: _showErrors,
              ),
              const SizedBox(height: 40),
              KlmButton(
                onPressed: () {
                  setState(() {
                    _showErrors = true;
                  });

                  AuthScope.login(
                    context,
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                },
                text: 'Login',
                width: 200,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  overlayColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'or register a new account',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
