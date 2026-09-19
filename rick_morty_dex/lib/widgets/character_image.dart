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
  });

  final String imageUrl;
  final BoxFit fit;
  final double placeholderIconSize;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _Placeholder(iconSize: placeholderIconSize);
    }

    return Image.network(
      imageUrl,
      fit: fit,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _Placeholder(iconSize: placeholderIconSize),
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
