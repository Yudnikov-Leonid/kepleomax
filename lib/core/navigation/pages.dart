import 'package:flutter/material.dart';
import 'package:kepleomax/features/login/login_screen.dart';
import 'package:kepleomax/features/music/music_screen.dart';
import 'package:kepleomax/features/post/post_editor_screen.dart';
import 'package:kepleomax/features/user/user_screen.dart';

import '../../features/main/main_screen.dart';

class AppPage extends MaterialPage<void> {
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

final class LoginPage extends AppPage {
  const LoginPage()
      : super(
    name: "login",
    child: const LoginScreen(),
    key: const ValueKey("login"),
  );
}

final class UserPage extends AppPage {
  UserPage({required int userId})
      : super(
    name: "user_page_$userId",
    child: UserScreen(userId: userId),
    key: ValueKey("user_page_$userId"),
  );
}

final class MainPage extends AppPage {
  const MainPage()
    : super(
        name: "main",
        child: const MainScreen(),
        key: const ValueKey("main"),
      );
}

final class MusicPage extends AppPage {
  const MusicPage()
      : super(
    name: "music",
    child: const MusicScreen(),
    key: const ValueKey("music"),
  );
}

final class PostEditorPage extends AppPage {
  const PostEditorPage()
      : super(
    name: "post_editor",
    child: const PostEditorScreen(),
    key: const ValueKey("post_editor"),
  );
}