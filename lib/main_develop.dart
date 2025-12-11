import 'package:kepleomax/main.dart' as app;

import 'core/flavor/flavor.dart';

/// flutter build apk -t lib/main_develop.dart

void main() => app.main(
  fv: Flavor.devPublic(),
);
