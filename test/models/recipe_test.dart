import 'package:flutter_test/flutter_test.dart';
import 'package:saia_da_5_serie/models/recipe.dart';

void main() {
  group('Recipe.fromJson', () {
    test('preserves ordered lists and accepts numeric API values', () {
      final recipe = Recipe.fromJson({
        'id': 42,
        'name': 'Soup',
        'ingredients': ['Water', 'Salt'],
        'instructions': ['Heat water', 'Add salt'],
        'prepTimeMinutes': 5,
        'cookTimeMinutes': 12.5,
        'servings': 2,
        'rating': 4,
        'mealType': ['Lunch', 'Dinner'],
      });

      expect(recipe.id, 42);
      expect(recipe.ingredients, ['Water', 'Salt']);
      expect(recipe.instructions, ['Heat water', 'Add salt']);
      expect(recipe.prepTimeMinutes, 5);
      expect(recipe.cookTimeMinutes, 12.5);
      expect(recipe.servings, 2);
      expect(recipe.rating, 4.0);
      expect(recipe.mealTypes, ['Lunch', 'Dinner']);
    });

    test('uses safe defaults for missing optional values', () {
      final recipe = Recipe.fromJson({'id': 7});

      expect(recipe.name, 'Receita sem nome');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
      expect(recipe.image, isNull);
      expect(recipe.prepTimeMinutes, isNull);
      expect(recipe.cookTimeMinutes, isNull);
      expect(recipe.servings, isNull);
      expect(recipe.rating, isNull);
      expect(recipe.mealTypes, isEmpty);
    });

    test('rejects recipes without a stable integer ID', () {
      expect(
        () => Recipe.fromJson({'id': '42'}),
        throwsFormatException,
      );
    });
  });
}
