import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'core/app.dart';
import 'core/di/initialize_dependencies.dart';
import 'core/flavor/flavor.dart';

late Logger logger;

late Flavor _flavor;

void _setFlavor(Flavor flavor) => _flavor = flavor;

Flavor get flavor => _flavor;

void main({Flavor? flavor}) => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();

    logger = Logger();

    _setFlavor(flavor!);

    final dependencies = await initializeDependencies();

    WidgetsFlutterBinding.ensureInitialized().allowFirstFrame();

    runApp(dependencies.inject(child: App()));
  },
  (err, st) {
    logger.e(err, stackTrace: st);
    // TODO
  },
);
