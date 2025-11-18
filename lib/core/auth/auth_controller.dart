import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kepleomax/core/auth/user_provider.dart';
import 'package:kepleomax/core/network/apis/auth/auth_api.dart';
import 'package:kepleomax/core/network/apis/auth/login_dtos.dart';
import 'package:kepleomax/core/network/apis/auth/logout_dtos.dart';
import 'package:kepleomax/core/network/apis/user/get_user_dtos.dart';
import 'package:kepleomax/core/network/apis/user/user_api.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';

import '../models/user.dart';

class AuthController {
  final AuthApi _authApi;
  final UserApi _userApi;
  final TokenProvider _tokenProvider;
  final UserProvider _userProvider;
  User? _user;

  User? get user => _user;

  final List<VoidCallback> _listeners = [];

  AuthController({
    required AuthApi authApi,
    required UserApi userApi,
    required TokenProvider tokenProvider,
    required UserProvider userProvider,
  }) : _authApi = authApi,
       _userApi = userApi,
       _tokenProvider = tokenProvider,
       _userProvider = userProvider;

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {
    final res = await _authApi.register(
      data: LoginRequestDto(email: email, password: password),
    );

    if (res.response.statusCode != 201 && res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to register a user: ${res.response.statusCode}',
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    final res = await _authApi.login(
      data: LoginRequestDto(email: email, password: password),
    );

    if (res.response.statusCode != 200) {
      throw Exception(
        res.data.message ?? 'Failed to logout: ${res.response.statusCode}',
      );
    }

    _tokenProvider.saveAccessToken(res.data.data!.accessToken);
    _tokenProvider.saveRefreshToken(res.data.data!.refreshToken);
    updateUser(User.fromDto(res.data.data!.user));
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenProvider.getRefreshToken();
      if (refreshToken != null) {
        try {
          _authApi.logout(data: LogoutRequestDto(refreshToken: refreshToken));
        } catch (e, st) {
          logger.e(e, stackTrace: st);
        }
      }
    } catch (e, st) {
      logger.e(e, stackTrace: st);
    } finally {
      updateUser(null);
      await _tokenProvider.clearAll();
    }
  }

  Future<void> init() async {
    final user = await _userProvider.getSavedUser();
    _user = user;

    if (_user == null) return;

    Future(() async {
      try {
        final res = await _userApi.getUser(userId: _user!.id);
        if (res.response.statusCode != 200) {
          throw Exception(
            res.data.message ?? 'Failed to get user: ${res.response.statusCode}',
          );
        }
        updateUser(User.fromDto(res.data.data!));
      } catch (e, st) {
        logger.e(e, stackTrace: st);
      }
    });
  }

  void updateUser(User? newUser) {
    _user = newUser;
    _userProvider.setNewUser(newUser);
    for (final listener in _listeners) {
      listener();
    }

    if (newUser != null) {
      _checkToken();
    } else {
      _deleteToken();
    }
  }

  Future<void> _checkToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    if (_user?.fcmTokens == null || !_user!.fcmTokens!.contains(token)) {
      _userApi.addFCMToken(body: FCMTokenRequestDto(token: token));
    }
  }

  Future<void> _deleteToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    _userApi.addFCMToken(body: FCMTokenRequestDto(token: token));
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeAllListeners() {
    _listeners.clear();
  }
}
