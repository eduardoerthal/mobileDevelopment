import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../models/character_page.dart';
import '../providers/auth_provider.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../widgets/character_image.dart';
import '../widgets/error_view.dart';
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

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadInitialPage();
  }

  @override
  void dispose() {
    _apiService.dispose();
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
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initialLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Ocorreu um erro inesperado. Tente novamente.';
            return ErrorView(message: message, onRetry: _retryInitialLoad);
          }

          if (_characters.isEmpty) {
            return const Center(
              child: Text('Nenhum personagem encontrado.'),
            );
          }

          return _buildGrid();
        },
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
              (context, index) => _CharacterCard(character: _characters[index]),
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
            Text(
              _loadMoreError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          if (_isLoadingMore)
            const CircularProgressIndicator()
          else if (hasNextPage)
            ElevatedButton(
              onPressed: _loadMore,
              child: const Text('Carregar Mais'),
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

/// One character tile: image (or placeholder) above the name. Tapping it
/// opens [DetailScreen] for this character's id.
class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(characterId: character.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: CharacterImage(imageUrl: character.image)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                character.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
