import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kepleomax/core/error_app.dart';
import 'package:logger/logger.dart';

import 'core/app.dart';
import 'core/di/initialize_dependencies.dart';
import 'core/flavor/flavor.dart';

/// flutter build apk -t lib/core/flavor/main_develop.dart

late Logger logger;

late Flavor flavor;

void main({Flavor? flavor}) {
  bool isAppRunning = false;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();

      logger = Logger();

      flavor = flavor!;

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
