import 'package:kepleomax/core/flavor.dart';
import 'package:kepleomax/main.dart' as app;

void main() {
  Flavor.setFlavor(Flavor.release());
  app.main();
}
