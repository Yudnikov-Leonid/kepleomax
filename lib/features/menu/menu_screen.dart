import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';

import 'menu_navigator.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlmAppBar(context, 'Menu'),
      body: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        children: [
          _MenuItem(title: 'People', onTap: () {
            AppNavigator.push(context, PeoplePage());
          }),
          _MenuItem(title: 'Music', onTap: () {
            AppNavigator.withKeyOf(context, mainNavigatorKey)?.push(MusicPage());
          }),
          _MenuItem(
            title: 'Settings',
            onTap: () {
              AppNavigator.push(context, SettingsPage());
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          Container(color: Colors.grey, height: 65, width: 65),
          const SizedBox(height: 6),
          Text(title, style: context.textTheme.bodyLarge?.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
