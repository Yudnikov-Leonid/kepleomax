import 'package:flutter/material.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlmAppBar(context, 'Feed'),
      body: Center(child: const Text('feed')),
    );
  }
}
