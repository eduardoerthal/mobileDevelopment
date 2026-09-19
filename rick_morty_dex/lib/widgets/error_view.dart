import 'package:flutter/material.dart';

/// Full-screen error state — message plus a retry button — for screens
/// that load their data through a single [Future] (catalog, character
/// detail).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            // liveRegion: a screen reader announces this automatically
            // as soon as it appears, since it replaces prior content
            // asynchronously — the user shouldn't have to go looking
            // for it.
            Semantics(
              liveRegion: true,
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
