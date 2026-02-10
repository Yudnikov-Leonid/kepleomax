import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kepleomax/core/error_app.dart';

import 'core/app.dart';
import 'core/di/initialize_dependencies.dart';
import 'core/logger.dart';

void main() {
  bool isAppRunning = false;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();

      final dependencies = await initializeDependencies();

      WidgetsFlutterBinding.ensureInitialized().allowFirstFrame();

      isAppRunning = true;
      runApp(dependencies.inject(child: const App()));
    },
    (err, st) {
      logger.e(err, stackTrace: st);
      if (!isAppRunning) {
        WidgetsFlutterBinding.ensureInitialized().allowFirstFrame();
        runApp(ErrorApp(error: err));
      }
    },
  );
}
