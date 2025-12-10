import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/presentation/colors.dart';
import 'package:kepleomax/core/presentation/context_wrapper.dart';
import 'package:kepleomax/features/chats/bloc/chats_bloc.dart';
import 'package:kepleomax/features/chats/bloc/chats_state.dart';
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
  final _pageController = PageController(initialPage: 1);
  int _currentIndex = 1;


  final _globalKeys = [
    feedNavigatorGlobalKey,
    chatsNavigatorGlobalKey,
    menuNavigatorGlobalKey,
  ];

  final _pages = [
    const FeedNavigator(key: Key('feed_navigator')),
    const ChatsNavigator(key: Key('chats_navigator')),
    const MenuNavigator(key: Key('menu_navigator')),
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
          child: BlocBuilder<ChatsBloc, ChatsState>(
            buildWhen: (oldState, newState) {
              if (oldState is! ChatsStateBase) return true;

              if (newState is! ChatsStateBase) return false;

              return oldState.data.totalUnreadCount !=
                  newState.data.totalUnreadCount;
            },
            builder: (context, state) {
              int? unreadCount = state is ChatsStateBase
                  ? state.data.totalUnreadCount
                  : null;

              return BottomNavigationBar(
                currentIndex: _currentIndex,
                key: const Key('main_bottom_navigation_bar'),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedFontSize: 0,
                onTap: (index) {
                  if (_currentIndex == index) {
                    (_globalKeys[_currentIndex].currentState as AppNavigatorState)
                        .popAll();
                  }
                  setState(() {
                    _currentIndex = index;
                    _pageController.jumpToPage(index);
                  });
                },
                selectedItemColor: KlmColors.primaryColor,
                unselectedItemColor: KlmColors.inactiveColor,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Feed',
                  ),
                  BottomNavigationBarItem(
                    key: Key('messages_navigation_item_$unreadCount'),
                    icon: SizedBox(
                      height: 50,
                      width: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline),
                          if (unreadCount != null && unreadCount > 0)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  unreadCount.toString(),
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
              );
            },
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ) //_pages[_currentIndex] // IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}
