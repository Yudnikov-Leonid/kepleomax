import 'package:flutter/material.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlmAppBar(
        context,
        'Settings',
        leading: KlmBackButton()
      ),
      body: Center(child: Text('Settings')),
    );
  }
}
