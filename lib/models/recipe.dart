class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.image,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.rating,
    this.mealTypes = const [],
    this.cuisine,
    this.difficulty,
  });

  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final String? image;
  final num? prepTimeMinutes;
  final num? cookTimeMinutes;
  final num? servings;
  final double? rating;
  final List<String> mealTypes;
  final String? cuisine;
  final String? difficulty;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! num || id % 1 != 0) {
      throw const FormatException('A receita não possui um ID válido.');
    }

    return Recipe(
      id: id.toInt(),
      name: json['name'] is String && (json['name'] as String).trim().isNotEmpty
          ? json['name'] as String
          : 'Receita sem nome',
      ingredients: _stringList(json['ingredients']),
      instructions: _stringList(json['instructions']),
      image: _optionalString(json['image']),
      prepTimeMinutes: _optionalNumber(json['prepTimeMinutes']),
      cookTimeMinutes: _optionalNumber(json['cookTimeMinutes']),
      servings: _optionalNumber(json['servings']),
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : null,
      mealTypes: _stringList(json['mealType']),
      cuisine: _optionalString(json['cuisine']),
      difficulty: _optionalString(json['difficulty']),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  static String? _optionalString(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }

  static num? _optionalNumber(Object? value) => value is num ? value : null;
}
