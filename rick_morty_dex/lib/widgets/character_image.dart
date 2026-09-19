import 'package:flutter/material.dart';

/// A character's avatar, falling back to a placeholder icon when
/// [imageUrl] is empty or fails to load — never lets a broken image
/// crash or blank out the layout. Used by both the catalog grid and
/// the detail screen.
class CharacterImage extends StatelessWidget {
  const CharacterImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholderIconSize = 40,
    this.semanticLabel,
  });

  final String imageUrl;
  final BoxFit fit;
  final double placeholderIconSize;

  /// Accessible description announced by screen readers for this image
  /// (e.g. "Foto de Rick Sanchez").
  ///
  /// Pass `null` when the character's name is already conveyed by
  /// nearby text that a screen reader will read anyway (e.g. a grid
  /// card's own merged "Ver detalhes de {nome}" label, or a list
  /// tile's title) — the image is then excluded from the accessibility
  /// tree entirely, instead of announcing a redundant, unlabeled
  /// "image" stop.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = imageUrl.isEmpty
        ? _Placeholder(iconSize: placeholderIconSize)
        : Image.network(
            imageUrl,
            fit: fit,
            width: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  semanticsLabel: 'Carregando imagem',
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                _Placeholder(iconSize: placeholderIconSize),
          );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: content);
    }

    // A single merged node covering whichever visual state is showing
    // (loaded photo, loading spinner or placeholder) so screen readers
    // announce one consistent description rather than 2-3 separate,
    // confusing stops as the image loads.
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: content,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline,
        size: iconSize,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
