import 'package:flutter/material.dart';

class AppBarLoadingAction extends StatelessWidget {
  const AppBarLoadingAction({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 16),
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}
