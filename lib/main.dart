import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kepleomax/core/error_app.dart';
import 'package:logger/logger.dart';

import 'core/app.dart';
import 'core/di/initialize_dependencies.dart';
import 'core/flavor/flavor.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    noBoxingByDefault: true,
    methodCount: 10,
    errorMethodCount: 10,
  ),
);

late Flavor flavor;

void main({Flavor? fv}) {
  bool isAppRunning = false;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();

      if (fv == null) {
        logger.e('Flavor is not provided');
      }
      flavor = fv ?? Flavor.devPublic();

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
