import 'package:kepleomax/main.dart' as app;

import 'flavor.dart';

void main() => app.main(
  flavor: const Flavor(
    baseUrl: 'http://localhost:13000/',
    type: FlavorType.develop,
  ),
);
