import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/features/feed/feed_screen.dart';

const feedNavigatorKey = 'FeedNavigator';
final feedNavigatorGlobalKey = GlobalKey();

class FeedNavigator extends StatelessWidget {
  const FeedNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigator(
      initialState: [const FeedPage()],
      navigatorKey: feedNavigatorKey,
      key: feedNavigatorGlobalKey,
    );
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
