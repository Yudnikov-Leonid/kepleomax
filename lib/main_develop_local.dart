import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/main.dart' as app;

/// flutter build apk -t lib/main_develop_local.dart

void main() {
  Flavor.setFlavor(Flavor.devLocal());
  app.main();
}
