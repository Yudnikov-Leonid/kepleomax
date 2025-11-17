import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/features/chats/chats_screen_navigator.dart';
import 'package:kepleomax/features/feed/feed_navigator.dart';
import 'package:kepleomax/features/menu/menu_navigator.dart';
import 'package:kepleomax/generated/images_keys.images_keys.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final _pages = [
    FeedNavigator(key: UniqueKey()),
    ChatsNavigator(key: UniqueKey()),
    MenuNavigator(key: UniqueKey()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashFactory:
                NoSplash.splashFactory, // Recommended for complete removal
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            key: Key('main_bottom_navigation_bar'),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) {
              if (_currentIndex == index) {
                _pages
                  ..clear()
                  ..addAll([
                    FeedNavigator(key: UniqueKey()),
                    ChatsNavigator(key: UniqueKey()),
                    MenuNavigator(key: UniqueKey()),
                  ]);
              }
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: KlmColors.primaryColor,
            unselectedItemColor: KlmColors.inactiveColor,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  ImagesKeys.hub_icon_svg,
                  height: 25,
                  width: 25,
                  color: _currentIndex == 2
                      ? KlmColors.primaryColor
                      : KlmColors.inactiveColor,
                ),
                label: 'Hub',
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}
