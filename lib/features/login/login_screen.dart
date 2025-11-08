import 'package:flutter/material.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
              Text('Login screen'),
              TextField(controller: _emailController, decoration: InputDecoration(hintText: 'Email')),
              TextField(controller: _passwordController, decoration: InputDecoration(hintText: 'Password')),
              TextButton(
                onPressed: () {
                  AuthScope.login(context, email: _emailController.text, password: _passwordController.text);
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
