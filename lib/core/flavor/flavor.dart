class Flavor {
  final String baseUrl;
  final String imageUrl;
  final FlavorType type;

  bool get isDevelop => type == FlavorType.develop;

  bool get isRelease => type == FlavorType.release;

  const Flavor({required this.baseUrl, required this.imageUrl, required this.type});

  factory Flavor.dev() => const Flavor(
    baseUrl: 'http://192.168.0.106:13000',
    imageUrl: 'http://192.168.0.106:13000/api/files/',
    type: FlavorType.develop,
  );

  factory Flavor.release() => const Flavor(
    baseUrl: 'http://127.0.0.1:13000',
    imageUrl: 'http://10.0.2.2:13000/api/files/',
    type: FlavorType.release,
  );
}

enum FlavorType { develop, release }
