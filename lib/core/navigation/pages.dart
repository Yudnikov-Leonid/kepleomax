import 'package:flutter/material.dart';

import '../../features/main/main_screen.dart';

sealed class AppPage extends MaterialPage<void> {
  const AppPage({
    required String super.name,
    required super.child,
    required LocalKey super.key,
  }) : super();

  @override
  String get name => super.name ?? "Unknown Page";

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppPage && key == other.key;
}

final class MainPage extends AppPage {
  const MainPage()
    : super(
        name: "main",
        child: const MainScreen(),
        key: const ValueKey("main"),
      );
}
