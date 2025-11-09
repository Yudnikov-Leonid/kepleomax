import 'package:flutter/cupertino.dart';
import 'package:kepleomax/core/auth/auth_controller.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/models/user.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';

import '../navigation/pages.dart';

final loginNavigatorKey = 'LoginNavigator';

class AuthScope extends StatefulWidget {
  const AuthScope({required this.child, super.key});

  final Widget child;

  static AuthController controllerOf(BuildContext context) =>
      _InheritedAuth.maybeOf(context)!.controller;

  static User? userOr(BuildContext context) => controllerOf(context).user;
  static User userOf(BuildContext context) => controllerOf(context).user!;

  static Future<void> logout(BuildContext context) =>
      controllerOf(context).logout();

  static Future<void> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async => controllerOf(context).login(email: email, password: password);

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope> {
  late AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Dependencies.of(context).authController;
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedAuth(
      key: ValueKey(_controller.user?.id ?? -1),
      controller: _controller,
      child: _controller.user == null ? AppNavigator(initialState: [LoginPage()], navigatorKey: loginNavigatorKey) : widget.child,
    );
  }
}

class _InheritedAuth extends InheritedWidget {
  const _InheritedAuth({
    required super.child,
    required this.controller,
    super.key,
  });

  final AuthController controller;

  static _InheritedAuth? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_InheritedAuth>();

  @override
  bool updateShouldNotify(covariant _InheritedAuth oldWidget) =>
      oldWidget.controller.user != controller.user;
}
