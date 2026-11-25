import 'package:flutter_test/flutter_test.dart';
import 'package:saia_da_5_serie/main.dart';
import 'package:saia_da_5_serie/models/recipe.dart';

void main() {
  test('a recipe can be added and removed by its stable ID', () {
    final favorites = FavoritesStore();
    const first =
        Recipe(id: 1, name: 'Pizza', ingredients: [], instructions: []);

    favorites.toggle(first);
    expect(favorites.contains(first.id), isTrue);
    expect(favorites.recipes, [first]);
    favorites.toggle(first);
    expect(favorites.contains(first.id), isFalse);
    expect(favorites.recipes, isEmpty);

    favorites.dispose();
  });
}
