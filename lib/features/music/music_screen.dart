import 'package:flutter/material.dart';
import 'package:kepleomax/core/navigation/app_navigator.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlmAppBar(
        context,
        'Music',
        leading: BackButton(
          onPressed: () {
            AppNavigator.withKeyOf(context, mainNavigatorKey)?.pop();
          },
        ),
      ),
      body: const Center(child: Text('Music screen (test navigator features)')),
    );
  }
}
