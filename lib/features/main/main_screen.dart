import 'package:flutter/material.dart';

import '../../core/scopes/auth_scope.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Main screen: ${AuthScope.userOr(context)?.username}'),
            TextButton(
              onPressed: () {
                AuthScope.logout(context);
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
