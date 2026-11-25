import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class RecipeApiException implements Exception {
  const RecipeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RecipeApi {
  static const _baseUrl = 'https://dummyjson.com/recipes';
  static const _timeout = Duration(seconds: 15);

  Future<List<Recipe>> getRecipes({int limit = 30}) async {
    final json = await _getJson(Uri.parse('$_baseUrl?limit=$limit'));
    return _parseRecipeList(json['recipes']);
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {'q': query},
    );
    final json = await _getJson(uri);
    return _parseRecipeList(json['recipes']);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const RecipeApiException(
        'A conexão demorou demais. Verifique sua internet e tente novamente.',
      );
    } on Exception {
      throw const RecipeApiException(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RecipeApiException(
        'O servidor respondeu com erro (${response.statusCode}). Tente novamente.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const RecipeApiException(
        'O servidor enviou uma resposta inválida. Tente novamente.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const RecipeApiException(
        'O servidor enviou dados em um formato inesperado. Tente novamente.',
      );
    }
    return decoded;
  }

  List<Recipe> _parseRecipeList(Object? value) {
    if (value is! List) {
      throw const RecipeApiException(
        'Não foi possível interpretar as receitas recebidas. Tente novamente.',
      );
    }

    try {
      return value.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Item de receita inválido.');
        }
        return Recipe.fromJson(item);
      }).toList(growable: false);
    } on FormatException {
      throw const RecipeApiException(
        'Uma receita veio em formato inválido. Tente novamente.',
      );
    }
  }
}
