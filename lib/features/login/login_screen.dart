import 'package:flutter/material.dart';
import 'package:kepleomax/core/scopes/auth_scope.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login screen'),
            TextButton(
              onPressed: () {
                AuthScope.login(context, email: 'email', password: 'password');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
