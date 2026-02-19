import 'package:kepleomax/core/app_constants.dart';

Flavor? _flavor;

Flavor get flavor => _flavor ?? Flavor.devLocal();

class Flavor {
  final String baseUrl;
  final String imageUrl;
  final FlavorType type;

  bool get isDevelop => type == FlavorType.develop;

  bool get isRelease => type == FlavorType.release;

  bool get isTesting => type == FlavorType.testing;

  Flavor({
    required this.baseUrl,
    required this.imageUrl,
    required this.type,
  }) : assert(baseUrl.isNotEmpty, "baseUrl can't be empty"),
       assert(imageUrl.isNotEmpty, "imageUrl can't be empty");

  /// name for the argument shouldn't be flavor, cause IDE automatically will
  /// write setFlavor(flavor);
  /// this won't have errors cause flavor - will be taken from this file (flavor.dart)
  /// it may create some room for mistakes
  static void setFlavor(Flavor fv) => _flavor = fv;

  factory Flavor.testing() => Flavor(
    baseUrl: '_no_urls_in_tests_',
    imageUrl: '_no_urls_in_tests_',
    type: FlavorType.testing,
  );

  factory Flavor.devLocal() => Flavor(
    baseUrl: 'http://192.168.0.106:13000',
    imageUrl: 'http://192.168.0.106:13000/api/files/',
    type: FlavorType.develop,
  );

  factory Flavor.devPublic() => Flavor(
    baseUrl: 'http://34.118.78.192:13000',
    imageUrl: 'http://34.118.78.192:13000/api/files/',
    type: FlavorType.develop,
  );

  factory Flavor.release() => Flavor(
    baseUrl: 'http://127.0.0.1:13000',
    imageUrl: 'http://10.0.2.2:13000/api/files/',
    type: FlavorType.release,
  );
}

enum FlavorType { develop, release, testing }
