class Flavor {
  final String baseUrl;
  final FlavorType type;

  const Flavor({required this.baseUrl, required this.type});
}

enum FlavorType { develop, release }
