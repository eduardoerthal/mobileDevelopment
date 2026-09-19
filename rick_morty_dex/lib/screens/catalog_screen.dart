import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../models/character_page.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../widgets/character_grid_tile.dart';
import '../widgets/error_view.dart';
import 'consumed_screen.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

/// Character catalog — the app's main screen once logged in. A 2-column
/// grid loaded from [ApiService], with a "Carregar Mais" button that
/// fetches and appends the next page.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _apiService = ApiService();

  /// Drives the initial-load spinner/error via [FutureBuilder]. Later
  /// pages are appended imperatively (see [_loadMore]), since a single
  /// Future can't represent an accumulating list.
  late Future<void> _initialLoadFuture;

  final List<Character> _characters = [];
  PageInfo? _pageInfo;

  bool _isLoadingMore = false;
  String? _loadMoreError;

  final _searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadInitialPage();
  }

  @override
  void dispose() {
    _apiService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPage() async {
    final page = await _apiService.fetchCharacters(1);
    _characters.addAll(page.results);
    _pageInfo = page.info;
  }

  void _retryInitialLoad() {
    setState(() {
      _characters.clear();
      _pageInfo = null;
      _initialLoadFuture = _loadInitialPage();
    });
  }

  Future<void> _loadMore() async {
    final nextPage = _pageInfo?.nextPage;
    if (nextPage == null || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      final page = await _apiService.fetchCharacters(nextPage);
      setState(() {
        _characters.addAll(page.results);
        _pageInfo = page.info;
      });
    } on ApiException catch (e) {
      setState(() => _loadMoreError = e.message);
    } catch (_) {
      setState(
        () => _loadMoreError = 'Ocorreu um erro inesperado. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  /// Searches by name via [ApiService.searchCharacters] and, on a match,
  /// navigates straight to that character's [DetailScreen] — no
  /// intermediate results list.
  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchError = 'Digite um nome para buscar.');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await _apiService.searchCharacters(query);
      if (!mounted) return;

      if (results.isEmpty) {
        setState(() {
          _searchError =
              'Nenhum personagem encontrado com o nome "$query".';
        });
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(characterId: results.first.id),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _searchError = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _searchError = 'Ocorreu um erro inesperado. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personagens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: 'Favoritos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Visualizados',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsumedScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<void>(
              future: _initialLoadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Carregando personagens',
                    ),
                  );
                }

                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Ocorreu um erro inesperado. Tente novamente.';
                  return ErrorView(
                    message: message,
                    onRetry: _retryInitialLoad,
                  );
                }

                if (_characters.isEmpty) {
                  return const Center(
                    child: Text('Nenhum personagem encontrado.'),
                  );
                }

                return _buildGrid();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  enabled: !_isSearching,
                  decoration: const InputDecoration(
                    hintText: 'Buscar personagem pelo nome',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSearching ? null : _search,
                child: _isSearching
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: 'Buscando personagem',
                        ),
                      )
                    : const Text('Buscar'),
              ),
            ],
          ),
          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _searchError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => CharacterGridTile(
                character: _characters[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetailScreen(characterId: _characters[index].id),
                  ),
                ),
              ),
              childCount: _characters.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildFooter()),
      ],
    );
  }

  Widget _buildFooter() {
    final hasNextPage = _pageInfo?.hasNextPage ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          if (_loadMoreError != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                _loadMoreError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_isLoadingMore)
            const CircularProgressIndicator(
              semanticsLabel: 'Carregando mais personagens',
            )
          else if (hasNextPage)
            ElevatedButton(
              onPressed: _loadMore,
              child: Text(
                _loadMoreError != null ? 'Tentar novamente' : 'Carregar Mais',
              ),
            )
          else
            Text(
              'Você chegou ao fim da lista.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
