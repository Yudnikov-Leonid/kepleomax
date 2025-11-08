import 'package:kepleomax/main.dart' as app;

import 'flavor.dart';

void main() => app.main(
  flavor: const Flavor(
    baseUrl: 'http://10.0.2.2:13000',
    type: FlavorType.develop,
  ),
);
