import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kepleomax/core/auth/user_provider.dart';
import 'package:kepleomax/core/data/auth_repository.dart';
import 'package:kepleomax/core/data/user_repository.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:kepleomax/main.dart';

import '../models/user.dart';

class AuthController {
  final IAuthRepository _authRepository;
  final IUserRepository _userRepository;
  final TokenProvider _tokenProvider;
  final UserProvider _userProvider;
  User? _user;

  User? get user => _user;

  final List<VoidCallback> _listeners = [];

  AuthController({
    required IAuthRepository authRepository,
    required IUserRepository userRepository,
    required TokenProvider tokenProvider,
    required UserProvider userProvider,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _tokenProvider = tokenProvider,
       _userProvider = userProvider;

  Future<void> registerUser({required String email, required String password}) =>
      _authRepository.register(email: email, password: password);

  Future<void> login({required String email, required String password}) async {
    final res = await _authRepository.login(email: email, password: password);

    await _tokenProvider.saveAccessToken(res.accessToken);
    await _tokenProvider.saveRefreshToken(res.refreshToken);
    await updateUser(User.fromDto(res.user));
  }

  Future<void> logout() async {
    try {
      await updateUser(null);
      final refreshToken = await _tokenProvider.getRefreshToken();
      if (refreshToken != null) {
        try {
          _authRepository.logout(refreshToken: refreshToken);
        } catch (e, st) {
          logger.e(e, stackTrace: st);
        }
      }
    } catch (e, st) {
      logger.e(e, stackTrace: st);
    } finally {
      await _tokenProvider.clearAll();
    }
  }

  Future<void> init() async {
    final user = await _userProvider.getSavedUser();
    _user = user;

    if (_user == null) return;

    Future(() async {
      try {
        final user = await _userRepository.getUser(userId: _user!.id);
        updateUser(user);
      } catch (e, st) {
        logger.e(e, stackTrace: st);
      }
    });
  }

  Future<void> updateUser(User? newUser) async {
    _user = newUser;
    _userProvider.setNewUser(newUser);
    for (final listener in _listeners) {
      listener();
    }

    if (newUser != null) {
      await _checkToken();
    } else {
      await _deleteToken();
    }
  }

  Future<void> _checkToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    // TODO not always do this
    await _userRepository
        .addFCMToken(token: token)
        .then((result) {
          if (result) {
            /// token successfully stored on the server
          }
        })
        .onError((e, st) {
          logger.e('failed to set fcm token: $e', stackTrace: st);
        });
  }

  Future<void> _deleteToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    FirebaseMessaging.instance.deleteToken();

    await _userRepository.deleteFCMToken(token: token).onError((e, st) {
      logger.e('failed to delete fcm token: $e', stackTrace: st);
    });
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeAllListeners() {
    _listeners.clear();
  }
}
