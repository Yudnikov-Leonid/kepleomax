import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/main.dart' as app;

/// flutter build apk -t lib/main_develop_public.dart

void main() {
  Flavor.setFlavor(Flavor.devPublic());
  app.main();
}
