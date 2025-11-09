import 'package:flutter/material.dart';

extension GetTextTheme on BuildContext {
  TextTheme get textTheme => themeData.textTheme;
}

extension GetThemeData on BuildContext {
  ThemeData get themeData => Theme.of(this);
}

extension GetScreenSize on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
}

extension ShowSnackBar on BuildContext {
  void showSnackBar({required String text, Color? color, Duration duration = const Duration(seconds: 6)}) => ScaffoldMessenger.of(this).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.fixed,
      backgroundColor: color,
      content: Text(text),
      duration: duration,
    ),
  );
}