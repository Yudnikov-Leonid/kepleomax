import 'package:flutter/material.dart';

import '../models/user.dart';

class AuthController {
  User? user;
  final List<VoidCallback> _listeners = [];

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {}

  Future<void> login({required String email, required String password}) async {
    _updateUser(User(id: 1, email: email, username: 'username'));
  }

  Future<void> logout() async {
    _updateUser(null);
  }

  void _updateUser(User? newUser) {
    user = newUser;
    for (final listener in _listeners) {
      listener();
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeAllListeners() {
    _listeners.clear();
  }
}
