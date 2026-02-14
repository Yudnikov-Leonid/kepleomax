import 'package:kepleomax/main.dart' as app;

import 'core/flavor.dart';

/// flutter build apk -t lib/main_develop_local.dart

void main() {
  Flavor.setFlavor(Flavor.devLocal());
  app.main();
}
