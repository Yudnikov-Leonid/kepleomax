import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/features/feed/feed_screen.dart';

const feedNavigatorKey = 'MenuNavigator';

class FeedNavigator extends StatelessWidget {
  const FeedNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigator(initialState: [FeedPage()], navigatorKey: feedNavigatorKey);
  }
}

/// pages
final class FeedPage extends AppPage {
  const FeedPage()
      : super(
    name: "feed_screen",
    child: const FeedScreen(),
    key: const ValueKey("feed_screen"),
  );
}