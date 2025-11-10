class Flavor {
  final String baseUrl;
  final String imageUrl;
  final FlavorType type;

  const Flavor({required this.baseUrl, required this.imageUrl, required this.type});
}

enum FlavorType { develop, release }
