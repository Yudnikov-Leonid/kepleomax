import 'package:kepleomax/main.dart' as app;

import 'core/flavor.dart';

void main() {
  Flavor.setFlavor(Flavor.release());
  app.main();
}
