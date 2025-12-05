class Flavor {
  final String baseUrl;
  final String imageUrl;
  final FlavorType type;

  bool get isDevelop => type == FlavorType.develop;

  bool get isRelease => type == FlavorType.release;

  const Flavor({required this.baseUrl, required this.imageUrl, required this.type});
}

enum FlavorType { develop, release }
