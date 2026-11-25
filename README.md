# Receitas da Casa

Aplicativo Flutter para descobrir receitas, pesquisar por nome e guardar
favoritas. As receitas são carregadas da API pública
[DummyJSON Recipes](https://dummyjson.com/docs/recipes).

## Funcionalidades

- Lista inicial de receitas com imagem alternativa quando a imagem não está
  disponível.
- Pesquisa remota por nome, ignorando espaços no começo e no fim; a pesquisa
  vazia não é enviada.
- Detalhes com ingredientes, instruções em ordem, tempos, porções, avaliação e
  informações de refeição disponíveis.
- Favoritos adicionados e removidos durante a sessão, acessíveis na aba
  **Favoritos**.
- Indicadores de carregamento, erros com nova tentativa, resultados vazios e
  favoritos vazios.

## Organização

- `lib/main.dart`: navegação, telas, estado da lista/pesquisa e fonte única de
  favoritos.
- `lib/models/recipe.dart`: modelo e conversão tipada da resposta da API.
- `lib/services/recipe_api.dart`: chamadas HTTP e validação de respostas.
- `android/`, `ios/` e `web/`: projetos de plataforma para execução mobile e
  navegador.

A listagem e a pesquisa usam os endpoints `/recipes?limit=30` e
`/recipes/search?q=...`. Ambos retornam os campos completos utilizados pela tela
de detalhes, então o objeto selecionado é reutilizado sem uma nova chamada por
ID. As telas compartilham um único `FavoritesStore`, mantido em memória durante
a sessão. As operações de busca e carregamento possuem estado de execução para
impedir solicitações concorrentes pela interface.

## Dependências e SDK

- Flutter SDK **3.44.0**
- Dart SDK **3.12.0**
- `http` **^1.3.0**
- `flutter_test` e `flutter_lints` para testes e análise estática

## Como executar

1. Instale o Flutter SDK e configure o `PATH`.
2. No terminal, acesse a pasta `saia_da_5_serie`.
3. Baixe as dependências e execute em um dispositivo/emulador conectado:

```bash
flutter pub get
flutter run
```

Para executar no navegador, use `flutter run -d chrome` (com suporte Web
habilitado na instalação do Flutter).

## Verificações

```bash
flutter analyze
flutter test
```
