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