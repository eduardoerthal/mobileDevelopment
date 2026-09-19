import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/consumed_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // Needed before doing any async/plugin work (shared_preferences here)
  // ahead of runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted favorites/consumed lists before the first frame, so
  // the UI never flashes an empty list on startup. AuthProvider restores
  // its own session lazily instead (see its isInitializing flag), since
  // showing a brief spinner there is fine.
  final favoritesProvider = FavoritesProvider();
  final consumedProvider = ConsumedProvider();
  await Future.wait([
    favoritesProvider.initialize(),
    consumedProvider.initialize(),
  ]);

  runApp(
    RickMortyDexApp(
      favoritesProvider: favoritesProvider,
      consumedProvider: consumedProvider,
    ),
  );
}

class RickMortyDexApp extends StatelessWidget {
  const RickMortyDexApp({
    super.key,
    required this.favoritesProvider,
    required this.consumedProvider,
  });

  final FavoritesProvider favoritesProvider;
  final ConsumedProvider consumedProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: consumedProvider),
      ],
      child: MaterialApp(
        title: 'Rick and Morty Dex',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Chooses between [LoginScreen] and [CatalogScreen] (the app's main
/// screen once logged in) based on the current session state, reacting
/// automatically to [AuthProvider] changes.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return auth.isAuthenticated ? const CatalogScreen() : const LoginScreen();
  }
}
