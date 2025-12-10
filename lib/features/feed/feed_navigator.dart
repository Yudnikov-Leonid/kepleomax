import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/navigation/pages.dart';
import 'package:kepleomax/features/feed/feed_screen.dart';

const feedNavigatorKey = 'FeedNavigator';
final feedNavigatorGlobalKey = GlobalKey();

class FeedNavigator extends StatefulWidget {
  const FeedNavigator({super.key});

  @override
  State<FeedNavigator> createState() => _FeedNavigatorState();
}

class _FeedNavigatorState extends State<FeedNavigator>
    with AutomaticKeepAliveClientMixin<FeedNavigator> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
