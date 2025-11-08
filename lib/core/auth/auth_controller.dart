import 'package:flutter/material.dart';
import 'package:kepleomax/core/auth/user_provider.dart';
import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/auth/login_dtos.dart';
import 'package:kepleomax/core/network/apis/auth/logout_dtos.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';

import '../models/user.dart';

class AuthController {
  final AuthApi _api;
  final TokenProvider _tokenProvider;
  final UserProvider _userProvider;
  User? _user;

  User? get user => _user;

  final List<VoidCallback> _listeners = [];

  AuthController({
    required AuthApi api,
    required TokenProvider tokenProvider,
    required UserProvider userProvider,
  }) : _api = api,
       _tokenProvider = tokenProvider,
       _userProvider = userProvider;

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {}

  Future<void> login({required String email, required String password}) async {
    final res = await _api.login(
      data: LoginRequestDto(email: email, password: password),
    );

    if (res.response.statusCode != 200) {
      throw Exception(res.data.message ?? 'Failed to logout');
    }

    _tokenProvider.saveAccessToken(res.data.data!.accessToken);
    _tokenProvider.saveRefreshToken(res.data.data!.refreshToken);
    _updateUser(
      User(
        id: res.data.data!.user['id'],
        email: email,
        username: res.data.data!.user['username'] ?? 'No username',
      ),
    );
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenProvider.getRefreshToken();
      if (refreshToken != null) {
        try {
          _api.logout(data: LogoutRequestDto(refreshToken: refreshToken));
        } catch (e, st) {
          logger.e(e, stackTrace: st);
        }
      }
      await _tokenProvider.clearAll();
    } catch (e, st) {
      logger.e(e, stackTrace: st);
    }

    _updateUser(null);
  }

  Future<void> init() async {
    final user = await _userProvider.getSavedUser();
    _user = user;
  }

  void _updateUser(User? newUser) {
    _user = newUser;
    _userProvider.setNewUser(newUser);
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
