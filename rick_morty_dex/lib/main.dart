import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RickMortyDexApp());
}

class RickMortyDexApp extends StatelessWidget {
  const RickMortyDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
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
