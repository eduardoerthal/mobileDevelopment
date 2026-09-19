import 'package:flutter/material.dart';

import '../models/character.dart';
import 'character_image.dart';

/// One character tile for the catalog grid: image (or placeholder) above
/// the name, tappable via [onTap]. Extracted as its own public widget so
/// it can be tested in isolation (see character_grid_tile_test.dart) —
/// in particular, that it doesn't overflow at a large text scale.
class CharacterGridTile extends StatelessWidget {
  const CharacterGridTile({
    super.key,
    required this.character,
    required this.onTap,
  });

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        // One merged, descriptive stop for the whole card instead of
        // separate (and for the image, unlabeled) announcements for
        // the image and the name text.
        button: true,
        label: 'Ver detalhes de ${character.name}',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: CharacterImage(imageUrl: character.image)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Text(
                  character.name,
                  // Two lines (not one) of headroom before ellipsizing,
                  // so a larger accessibility text scale has room to
                  // grow without immediately truncating the name — the
                  // Expanded image above simply yields the space, it
                  // never gets pushed into negative/overflow territory
                  // for any realistic OS text-scale setting.
                  maxLines: 2,
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
      ),
    );
  }
}
