Rick & Morty Dex 🛸

Aplicativo mobile desenvolvido em Flutter como projeto somativo, consistindo em um catálogo interativo de personagens que consome a Rick and Morty API, aplicando os principais conceitos trabalhados em aula: construção de widgets e layouts, navegação, consumo assíncrono de APIs, gerenciamento de estado com Provider, persistência de dados e autenticação de usuário.

📖 Sobre o projeto

O Rick & Morty Dex é um catálogo de personagens do universo Rick and Morty onde o usuário pode:

Fazer login (localmente) antes de acessar o catálogo;
Visualizar uma lista paginada de personagens carregada da internet;
Buscar um personagem específico pelo nome;
Ver os detalhes completos de um personagem selecionado;
Marcar personagens como favoritos;
Marcar personagens como visualizados/consumidos;
Ter essas informações preservadas mesmo após fechar o app.
🎯 Requisitos Funcionais Implementados
RF	Descrição
RF01	Tela principal com catálogo em GridView, paginação via botão "Carregar Mais" e placeholder para itens sem imagem
RF02	Navegação para a Tela de Detalhes ao tocar em um personagem
RF03	Tela de Detalhes com imagem ampliada e atributos completos do personagem
RF04	Gerenciamento de estado dos favoritos com Provider
RF05	Tela de Favoritos, atualizada automaticamente ao desfavoritar
RF06	Persistência local dos favoritos e itens consumidos (shared_preferences)
RF07	Login local com sessão condicional e tela de itens "consumidos/visualizados"
RF08	Busca por nome via TextField + TextEditingController, navegando direto ao detalhe
RF09	Feedback de UI: CircularProgressIndicator em carregamentos e mensagens de erro amigáveis (FutureBuilder)
RF10	Acessibilidade: Semantics/semanticLabel, contraste adequado, suporte a textScaleFactor e áreas de toque mínimas
🛠️ Tecnologias e Pacotes
Framework: Flutter (Dart)
API: Rick and Morty API — listagem paginada, busca e detalhe de personagens
Pacotes principais:
http — requisições à API
provider — gerenciamento de estado (favoritos, consumidos, sessão)
shared_preferences — persistência local
Bônus (opcionais, não implementados na versão baseline)
Persistência em nuvem (Firebase ou Supabase)
Autenticação real (Firebase Auth ou Supabase Auth)
📂 Estrutura do Projeto
lib/
 ├── models/         # Modelos de dados (ex: Character)
 ├── services/        # Comunicação com a API (ApiService)
 ├── providers/        # Gerenciamento de estado (AuthProvider, FavoritesProvider, ConsumedProvider)
 ├── screens/         # Telas do app (Login, Catálogo, Detalhes, Favoritos, Consumidos)
 └── main.dart         # Ponto de entrada e configuração de navegação
🚀 Como executar
Clone este repositório.
Instale as dependências:
bash
   flutter pub get
Execute o aplicativo:
bash
   flutter run