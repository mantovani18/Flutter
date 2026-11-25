import 'package:flutter/material.dart';

import 'models/recipe.dart';
import 'services/recipe_api.dart';

const _portugueseRecipeNames = <int, String>{
  1: 'Pizza margherita clássica',
  2: 'Salteado vegetariano',
  3: 'Biscoitos de gotas de chocolate',
  4: 'Macarrão ao molho Alfredo com frango',
  5: 'Frango com molho de manga',
  6: 'Salada de quinoa com abacate',
  7: 'Bruschetta de tomate e manjericão',
  8: 'Bife acebolado com brócolis',
  9: 'Salada caprese',
  10: 'Espaguete de camarão',
  11: 'Frango biryani',
  12: 'Frango karahi',
  13: 'Batata com carne moída',
  14: 'Hambúrguer de carne chapli',
  15: 'Espinafre com pão de milho',
  16: 'Sopa japonesa de lámen',
  17: 'Ensopado marroquino de grão-de-bico',
  18: 'Bibimbap coreano',
  19: 'Musaca grega',
  20: 'Frango ao curry de manteiga',
  21: 'Curry verde tailandês',
  22: 'Lassi de manga',
  23: 'Tiramisu italiano',
  24: 'Espetinhos turcos',
  25: 'Vitamina de mirtilo e banana',
  26: 'Milho verde mexicano',
  27: 'Sopa russa de beterraba',
  28: 'Masala dosa do sul da Índia',
  29: 'Wrap libanês de falafel',
  30: 'Caipirinha brasileira',
  31: 'Batatas bravas espanholas',
  32: 'Rolinho primavera vietnamita',
  33: 'Salada mediterrânea de quinoa',
  34: 'Sorvete de chá verde matcha',
  35: 'Brigadeiro brasileiro',
  36: 'Enchilada mexicana de frango',
  37: 'Camarão ao curry de coco',
  38: 'Spanakopita grega',
  39: 'Salada marroquina de cuscuz',
  40: 'Mojito clássico',
  41: 'Bruschetta de mussarela',
  42: 'Frango teriyaki salteado',
  43: 'Salsa de manga e abacate',
  44: 'Camarão com aspargos',
  45: 'Pizza margherita italiana',
  46: 'Pesto com tomates cereja',
  47: 'Espetinho havaiano de frango',
  48: 'Rolinhos de pepino e abacate',
  49: 'Salada mediterrânea de grão-de-bico',
  50: 'Vitamina de abacaxi e coco',
};

String portugueseRecipeName(Recipe recipe) =>
    _portugueseRecipeNames[recipe.id] ?? recipe.name;

void main() {
  runApp(const ReceitasDaCasaApp());
}

class ReceitasDaCasaApp extends StatelessWidget {
  const ReceitasDaCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFC7A94B);
    return MaterialApp(
      title: 'Receitas da Casa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1F18),
        ),
        scaffoldBackgroundColor: const Color(0xFF171914),
        appBarTheme: const AppBarTheme(
          foregroundColor: Color(0xFFF3EBDD),
          backgroundColor: Color(0xFF171914),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF24271F),
          hintStyle: const TextStyle(color: Color(0xFFAAA99F)),
          prefixIconColor: const Color(0xFFC7A94B),
          suffixIconColor: const Color(0xFFC7A94B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const RecipeHome(),
    );
  }
}

class FavoritesStore extends ChangeNotifier {
  final Map<int, Recipe> _recipes = {};

  List<Recipe> get recipes => List.unmodifiable(_recipes.values);

  bool contains(int id) => _recipes.containsKey(id);

  void toggle(Recipe recipe) {
    if (_recipes.containsKey(recipe.id)) {
      _recipes.remove(recipe.id);
    } else {
      _recipes[recipe.id] = recipe;
    }
    notifyListeners();
  }
}

class RecipeHome extends StatefulWidget {
  const RecipeHome({super.key});

  @override
  State<RecipeHome> createState() => _RecipeHomeState();
}

class _RecipeHomeState extends State<RecipeHome> {
  final RecipeApi _api = RecipeApi();
  final FavoritesStore _favorites = FavoritesStore();
  final TextEditingController _searchController = TextEditingController();

  List<Recipe> _recipes = [];
  List<Recipe> _searchResults = [];
  String? _listError;
  String? _searchError;
  String _activeQuery = '';
  bool _isLoadingRecipes = true;
  bool _isSearching = false;
  bool _hasSearched = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _favorites.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    if (_isLoadingRecipes) return;
    setState(() {
      _isLoadingRecipes = true;
      _listError = null;
    });
    await _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final recipes = await _api.getRecipes();
      if (mounted) setState(() => _recipes = recipes);
    } on RecipeApiException catch (error) {
      if (mounted) setState(() => _listError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _listError =
              'Não foi possível carregar as receitas. Tente novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingRecipes = false);
    }
  }

  Future<void> _searchRecipes([String? input]) async {
    final query = (input ?? _searchController.text).trim();
    if (query.isEmpty || _isSearching) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _activeQuery = query;
      _hasSearched = true;
      _isSearching = true;
      _searchError = null;
    });
    try {
      final recipes = await _api.searchRecipes(query);
      if (mounted) setState(() => _searchResults = recipes);
    } on RecipeApiException catch (error) {
      if (mounted) setState(() => _searchError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchError =
              'Não foi possível pesquisar agora. Verifique sua internet e tente novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _clearSearch() {
    if (_isSearching) return;
    _searchController.clear();
    setState(() {
      _activeQuery = '';
      _hasSearched = false;
      _searchError = null;
      _searchResults = [];
    });
  }

  void _openRecipe(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailsPage(
          recipe: recipe,
          favorites: _favorites,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildExplorePage(),
            _buildFavoritesPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          if (_isSearching) return;
          setState(() => _selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _buildExplorePage() {
    final displayingSearch = _hasSearched;
    final recipes = displayingSearch ? _searchResults : _recipes;
    final isLoading = displayingSearch ? _isSearching : _isLoadingRecipes;
    final error = displayingSearch ? _searchError : _listError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, color: Color(0xFFC7A94B), size: 26),
                  const SizedBox(width: 8),
                  Text(
                    'Receitas da Casa',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFC7A94B),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Hoje vai sair o quê?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Escolha uma receita, confira os ingredientes e bora cozinhar.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFAAA99F),
                    ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchRecipes,
                decoration: InputDecoration(
                  hintText: 'Buscar receita pelo nome',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _hasSearched
                      ? IconButton(
                          tooltip: 'Limpar pesquisa',
                          onPressed: _isSearching ? null : _clearSearch,
                          icon: const Icon(Icons.close),
                        )
                      : IconButton(
                          tooltip: 'Pesquisar',
                          onPressed:
                              _isSearching ? null : () => _searchRecipes(),
                          icon: const Icon(Icons.arrow_forward),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                displayingSearch
                    ? 'Resultados para "$_activeQuery"'
                    : 'Ideias da cozinha',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildRecipeResults(
            recipes: recipes,
            isLoading: isLoading,
            error: error,
            displayingSearch: displayingSearch,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeResults({
    required List<Recipe> recipes,
    required bool isLoading,
    required String? error,
    required bool displayingSearch,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Carregando receitas',
        ),
      );
    }
    if (error != null) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: error,
        actionLabel: 'Tentar novamente',
        onAction: displayingSearch
            ? () => _searchRecipes(_activeQuery)
            : _loadRecipes,
      );
    }
    if (recipes.isEmpty) {
      return _MessageState(
        icon: displayingSearch ? Icons.search_off : Icons.menu_book_outlined,
        message: displayingSearch
            ? 'Nenhuma receita encontrada. Tente outro nome.'
            : 'Nenhuma receita disponível no momento.',
        actionLabel: displayingSearch ? 'Ver todas as receitas' : null,
        onAction: displayingSearch ? _clearSearch : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          favorites: _favorites,
          onTap: () => _openRecipe(recipe),
        );
      },
    );
  }

  Widget _buildFavoritesPage() {
    return AnimatedBuilder(
      animation: _favorites,
      builder: (context, _) {
        final recipes = _favorites.recipes;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFD36D5E)),
                  const SizedBox(height: 12),
                  Text(
                    'Salvas por você',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Os pratos que você separou para fazer depois.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFAAA99F),
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: recipes.isEmpty
                  ? const _MessageState(
                      icon: Icons.favorite_border,
                      message:
                          'Você ainda não salvou receitas. Toque no coração de uma receita para adicioná-la aqui.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          favorites: _favorites,
                          onTap: () => _openRecipe(recipe),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.favorites,
    required this.onTap,
  });

  final Recipe recipe;
  final FavoritesStore favorites;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final detail = [
      if (recipe.cuisine != null) recipe.cuisine!,
      if (recipe.mealTypes.isNotEmpty) recipe.mealTypes.join(' · '),
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: const Color(0xFF24271F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF34372E)),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 132,
          child: Row(
            children: [
              RecipeImage(url: recipe.image, width: 118, height: 132),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        portugueseRecipeName(recipe),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (detail.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFAAA99F),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          if (recipe.rating != null) ...[
                            const Icon(Icons.star,
                                size: 16, color: Color(0xFFE6A532)),
                            const SizedBox(width: 4),
                            Text(recipe.rating!.toStringAsFixed(1)),
                          ],
                          const Spacer(),
                          AnimatedBuilder(
                            animation: favorites,
                            builder: (context, _) {
                              final isFavorite = favorites.contains(recipe.id);
                              return IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: isFavorite
                                    ? 'Remover dos favoritos'
                                    : 'Adicionar aos favoritos',
                                onPressed: () => favorites.toggle(recipe),
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? const Color(0xFFD36D5E)
                                      : const Color(0xFFAAA99F),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  final String? url;
  final double width;
  final double height;

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: const Color(0xFF34372E),
        alignment: Alignment.center,
        child: const Icon(
          Icons.restaurant,
          size: 36,
          color: Color(0xFFC7A94B),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (url == null) return _fallback();
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class RecipeDetailsPage extends StatelessWidget {
  const RecipeDetailsPage({
    super.key,
    required this.recipe,
    required this.favorites,
  });

  final Recipe recipe;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    final mealDetails = [
      if (recipe.cuisine != null) recipe.cuisine!,
      ...recipe.mealTypes,
      if (recipe.difficulty != null) recipe.difficulty!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da receita'),
        actions: [
          AnimatedBuilder(
            animation: favorites,
            builder: (context, _) {
              final isFavorite = favorites.contains(recipe.id);
              return IconButton(
                tooltip: isFavorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                onPressed: () => favorites.toggle(recipe),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFFD36D5E) : null,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: RecipeImage(
                  url: recipe.image, width: double.infinity, height: 230),
            ),
            const SizedBox(height: 20),
            Text(
              portugueseRecipeName(recipe),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (mealDetails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mealDetails.join(' · '),
                style: const TextStyle(color: Color(0xFFAAA99F)),
              ),
            ],
            if (recipe.rating != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFE6A532), size: 19),
                  const SizedBox(width: 5),
                  Text('${recipe.rating!.toStringAsFixed(1)} de avaliação'),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (recipe.prepTimeMinutes != null)
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label:
                        'Preparo: ${_formatNumber(recipe.prepTimeMinutes!)} min',
                  ),
                if (recipe.cookTimeMinutes != null)
                  _InfoChip(
                    icon: Icons.local_fire_department_outlined,
                    label:
                        'Cozimento: ${_formatNumber(recipe.cookTimeMinutes!)} min',
                  ),
                if (recipe.servings != null)
                  _InfoChip(
                    icon: Icons.people_outline,
                    label: '${_formatNumber(recipe.servings!)} porções',
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Ingredientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            if (recipe.ingredients.isEmpty)
              const Text('Ingredientes não informados.')
            else
              ...recipe.ingredients.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: Icon(
                          Icons.circle,
                          size: 7,
                          color: Color(0xFF65836A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(ingredient)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 22),
            Text(
              'Modo de preparo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            if (recipe.instructions.isEmpty)
              const Text('Instruções não informadas.')
            else
              ...recipe.instructions.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFF34372E),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Color(0xFFC7A94B),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(num value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17, color: const Color(0xFFC7A94B)),
      label: Text(label),
      backgroundColor: const Color(0xFF34372E),
      side: BorderSide.none,
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.black45),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
