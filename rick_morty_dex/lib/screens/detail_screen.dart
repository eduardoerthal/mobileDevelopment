import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../widgets/character_image.dart';
import '../widgets/error_view.dart';

/// Full details of a single character, fetched by id via
/// [ApiService.fetchCharacterById]. Reached by tapping a card in
/// [CatalogScreen].
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.characterId});

  final int characterId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Character> _characterFuture;

  @override
  void initState() {
    super.initState();
    _characterFuture = _apiService.fetchCharacterById(widget.characterId);
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _characterFuture = _apiService.fetchCharacterById(widget.characterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: FutureBuilder<Character>(
        future: _characterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Ocorreu um erro inesperado. Tente novamente.';
            return ErrorView(message: message, onRetry: _retry);
          }

          return _DetailBody(character: snapshot.data!);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CharacterImage(
              imageUrl: character.image,
              placeholderIconSize: 96,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(character.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 20),
                _AttributeRow(
                  icon: Icons.favorite_outline,
                  label: 'Status',
                  value: character.status,
                  valueColor: _statusColor(character.status, theme),
                ),
                _AttributeRow(
                  icon: Icons.pets_outlined,
                  label: 'Espécie',
                  value: character.species,
                ),
                if (character.type.isNotEmpty)
                  _AttributeRow(
                    icon: Icons.category_outlined,
                    label: 'Tipo',
                    value: character.type,
                  ),
                _AttributeRow(
                  icon: Icons.wc_outlined,
                  label: 'Gênero',
                  value: character.gender,
                ),
                _AttributeRow(
                  icon: Icons.location_on_outlined,
                  label: 'Localização atual',
                  value: character.location.name,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}

/// One labeled attribute row (icon + label + value), used to lay out
/// status/species/type/gender/location consistently.
class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value.isEmpty ? 'Desconhecido' : value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
