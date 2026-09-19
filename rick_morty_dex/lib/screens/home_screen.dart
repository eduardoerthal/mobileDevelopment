import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// Placeholder main screen shown once a session is active.
///
/// The character list/detail UI will be built here in a later step;
/// for now it just confirms the logged-in session and offers logout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rick and Morty Dex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Text('Bem-vindo, ${auth.currentUsername ?? ''}!'),
      ),
    );
  }
}
