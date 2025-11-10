import 'package:kepleomax/main.dart' as app;

import 'flavor.dart';

void main() => app.main(
  flavor: const Flavor(
    baseUrl: 'http://127.0.0.1:13000',
    imageUrl: 'http://10.0.2.2:13000/api/files/',
    type: FlavorType.release,
  ),
);
