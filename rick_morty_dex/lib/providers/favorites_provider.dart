import 'package:flutter/foundation.dart';

import '../models/character.dart';

/// Tracks which characters the user has favorited, for the current app
/// session.
///
/// NOTE: kept in memory only for now — not yet persisted across app
/// restarts. That's tracked as a follow-up (persisting via
/// shared_preferences, mirroring [AuthProvider]'s approach).
class FavoritesProvider extends ChangeNotifier {
  /// Keyed by character id for O(1) lookups; a [Map] preserves insertion
  /// order, so [favorites] naturally lists items in the order they were
  /// added.
  final Map<int, Character> _favoritesById = {};

  /// Favorited characters, in the order they were added.
  List<Character> get favorites => List.unmodifiable(_favoritesById.values);

  bool isFavorite(int characterId) => _favoritesById.containsKey(characterId);

  void add(Character character) {
    if (_favoritesById.containsKey(character.id)) return;
    _favoritesById[character.id] = character;
    notifyListeners();
  }

  void remove(int characterId) {
    if (_favoritesById.remove(characterId) != null) {
      notifyListeners();
    }
  }

  /// Adds [character] to the favorites if it isn't already there,
  /// removes it otherwise.
  void toggle(Character character) {
    if (isFavorite(character.id)) {
      remove(character.id);
    } else {
      add(character);
    }
  }
}
