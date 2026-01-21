import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kepleomax/core/di/dependencies.dart';
import 'package:kepleomax/core/presentation/klm_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlmAppBar(context, 'Settings', leading: const KlmBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await Dependencies.of(context).localDatabase.reset();
                  Fluttertoast.showToast(msg: 'The database is reset');
                },
                style: TextButton.styleFrom(shape: const LinearBorder()),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reset local database',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
