import 'package:kepleomax/main.dart' as app;

import 'flavor.dart';

void main() => app.main(
  flavor: const Flavor(
    baseUrl: 'http://192.168.0.106:13000',
    imageUrl: 'http://192.168.0.106:13000/api/files/',
    type: FlavorType.develop,
  ),
);
