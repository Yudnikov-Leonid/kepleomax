import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/features/menu/menu_screen.dart';
import 'package:kepleomax/features/settings/settings_screen.dart';

const menuNavigatorKey = 'MenuNavigator';
final menuNavigatorGlobalKey = GlobalKey();

class MenuNavigator extends StatelessWidget {
  const MenuNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigator(
      initialState: [MenuPage()],
      navigatorKey: menuNavigatorKey,
      key: menuNavigatorGlobalKey,
    );
  }
}

/// pages
final class MenuPage extends AppPage {
  const MenuPage()
    : super(
        name: "menu_screen",
        child: const MenuScreen(),
        key: const ValueKey("menu_screen"),
      );
}

final class SettingsPage extends AppPage {
  const SettingsPage()
    : super(
        name: "settings_page",
        child: const SettingsScreen(),
        key: const ValueKey("settings_page"),
      );
}
