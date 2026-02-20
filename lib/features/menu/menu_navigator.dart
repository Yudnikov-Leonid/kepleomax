import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/features/menu/menu_screen.dart';
import 'package:kepleomax/features/settings/settings_screen.dart';

const menuNavigatorKey = 'MenuNavigator';
final menuNavigatorGlobalKey = GlobalKey();

class MenuNavigator extends StatefulWidget {
  const MenuNavigator({super.key});

  @override
  State<MenuNavigator> createState() => _MenuNavigatorState();
}

class _MenuNavigatorState extends State<MenuNavigator>
    with AutomaticKeepAliveClientMixin<MenuNavigator> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AppNavigator(
      initialState: [const MenuPage()],
      navigatorKey: menuNavigatorKey,
      key: menuNavigatorGlobalKey,
    );
  }
}

/// pages
final class MenuPage extends AppPage {
  const MenuPage()
    : super(
        name: 'menu_screen',
        child: const MenuScreen(),
        key: const ValueKey('menu_screen'),
      );
}

final class SettingsPage extends AppPage {
  const SettingsPage()
    : super(
        name: 'settings_page',
        child: const SettingsScreen(),
        key: const ValueKey('settings_page'),
      );
}
