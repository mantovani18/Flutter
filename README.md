# Receitas da Casa

Projeto Flutter que eu desenvolvi para listar, pesquisar e salvar receitas
da API pública DummyJSON Recipes. Os nomes das receitas foram adaptados para
português brasileiro.

## O que o app faz

- Carrega uma lista de receitas ao abrir.
- Busca receitas pelo nome.
- Mostra uma imagem, ingredientes e modo de preparo.
- Guarda favoritos enquanto o app estiver aberto.
- Mostra mensagens quando a internet falha, não encontra receitas ou não existem favoritos.

## Como está dividido

- `lib/main.dart` tem as telas e a navegação.
- `lib/models/recipe.dart` organiza os dados recebidos pela API.
- `lib/services/recipe_api.dart` faz as chamadas HTTP.
- `test/` contém testes do modelo e dos favoritos.
- `android/`, `ios/` e `web/` têm os arquivos das plataformas.

Para os detalhes, eu reaproveito o mesmo objeto recebido na lista ou na
busca. Assim não é necessário fazer uma nova requisição ao abrir uma receita.

## Rodando o projeto

É preciso ter o Flutter instalado.

```bash
cd saia_da_5_serie
flutter pub get
flutter run
```

No Chrome:

```bash
flutter run -d chrome
```

## Tecnologias

- Flutter 3.44.0
- Dart 3.12.0
- Pacote `http`
- API DummyJSON Recipes

## Testes

```bash
dart analyze
flutter test
```
