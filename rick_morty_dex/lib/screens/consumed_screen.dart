import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/character.dart';
import '../providers/consumed_provider.dart';
import '../widgets/character_image.dart';
import 'detail_screen.dart';

/// Lists characters marked as "visualizado". Rebuilds automatically
/// whenever [ConsumedProvider] changes — including when an item is
/// unmarked from this very screen's action button. Mirrors
/// [FavoritesScreen]'s layout.
class ConsumedScreen extends StatelessWidget {
  const ConsumedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final consumed = context.watch<ConsumedProvider>().consumed;

    return Scaffold(
      appBar: AppBar(title: const Text('Visualizados')),
      body: consumed.isEmpty
          ? const _EmptyConsumed()
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: consumed.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _ConsumedTile(character: consumed[index]),
            ),
    );
  }
}

class _ConsumedTile extends StatelessWidget {
  const _ConsumedTile({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8, right: 4),
        leading: SizedBox(
          width: 56,
          height: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CharacterImage(
              imageUrl: character.image,
              placeholderIconSize: 24,
            ),
          ),
        ),
        title: Text(character.name),
        subtitle: Text('${character.species} • ${character.status}'),
        trailing: IconButton(
          icon: const Icon(Icons.visibility),
          // Names the character explicitly — this button repeats once
          // per row, so a bare "Remover dos visualizados" would be
          // ambiguous to someone navigating the list with a screen
          // reader.
          tooltip: 'Remover ${character.name} dos visualizados',
          onPressed: () =>
              context.read<ConsumedProvider>().remove(character.id),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(characterId: character.id),
          ),
        ),
      ),
    );
  }
}

class _EmptyConsumed extends StatelessWidget {
  const _EmptyConsumed();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Você ainda não visualizou nenhum personagem.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
