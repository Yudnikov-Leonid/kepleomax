import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kepleomax/core/error_app.dart';
import 'package:kepleomax/core/flavor.dart';

import 'core/app.dart';
import 'core/di/initialize_dependencies.dart';
import 'core/logger.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();

      final dependencies = await initializeDependencies(useMocks: flavor.isTesting);

      WidgetsFlutterBinding.ensureInitialized().allowFirstFrame();

      runApp(dependencies.inject(child: const App()));
    },
    (e, st) {
      logger.e('runZonedGuardedError: $e', stackTrace: st);

      if (flavor.isTesting) throw e;

      if (!WidgetsBinding.instance.sendFramesToEngine) {
        /// init was unsuccessful
        WidgetsFlutterBinding.ensureInitialized().allowFirstFrame();
        runApp(ErrorApp(error: e));
      }
    },
  );
}
