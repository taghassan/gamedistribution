class Game {
  final String objectID;
  final String title;
  final String? company;
  final String? mobileMode;
  final String? category;
  final String? slug;
  final List<String> assets;

  Game({
    required this.objectID,
    required this.title,
    this.company,
    this.mobileMode,
    this.category,
    this.slug,
    required this.assets,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      objectID: json['objectID'],
      title: json['title'],
      mobileMode: json['mobileMode'], // Landscape or Portrait
      company: json['company'],
      category: json['category'],
      slug: (json['slugs'] as List?)?.isNotEmpty == true
          ? json['slugs'][0]['name']
          : null,
      assets: (json['assets'] as List?)
          ?.map((e) => e['name'] as String)
          .toList() ??
          [],
    );
  }
}