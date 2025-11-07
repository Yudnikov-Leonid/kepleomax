import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/network/token_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dependencies {
  late AuthController authController;
  late TokenProvider tokenProvider;
  late SharedPreferences sharedPreferences;
  late FlutterSecureStorage secureStorage;
  late Dio dio;

  Widget inject({required Widget child}) =>
      InheritedDependencies(dependencies: this, child: child);

  static Dependencies of(BuildContext context) => context
      .getInheritedWidgetOfExactType<InheritedDependencies>()!
      .dependencies;
}

class InheritedDependencies extends InheritedWidget {
  const InheritedDependencies({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
