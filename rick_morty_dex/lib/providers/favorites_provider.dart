import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

/// Tracks which characters the user has favorited, persisted locally via
/// [SharedPreferences] (the full [Character] is stored as JSON, so the
/// list survives closing and reopening the app).
class FavoritesProvider extends ChangeNotifier {
  static const _prefsKey = 'favorites_characters';

  /// Keyed by character id for O(1) lookups; a [Map] preserves insertion
  /// order, so [favorites] naturally lists items in the order they were
  /// added.
  final Map<int, Character> _favoritesById = {};

  /// Favorited characters, in the order they were added.
  List<Character> get favorites => List.unmodifiable(_favoritesById.values);

  bool isFavorite(int characterId) => _favoritesById.containsKey(characterId);

  /// Loads previously persisted favorites. Call once, before the first
  /// build — e.g. in `main()` before `runApp` — so the UI never flashes
  /// an empty list on startup.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final item in decoded) {
        final character = Character.fromJson(item as Map<String, dynamic>);
        _favoritesById[character.id] = character;
      }
      notifyListeners();
    } catch (error) {
      // Corrupted/incompatible persisted data shouldn't crash startup —
      // just start with an empty favorites list.
      debugPrint('FavoritesProvider: failed to load persisted data: $error');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _favoritesById.values.map((character) => character.toJson()).toList(),
      );
      await prefs.setString(_prefsKey, encoded);
    } catch (error) {
      debugPrint('FavoritesProvider: failed to persist favorites: $error');
    }
  }

  Future<void> add(Character character) async {
    if (_favoritesById.containsKey(character.id)) return;
    _favoritesById[character.id] = character;
    notifyListeners();
    await _persist();
  }

  Future<void> remove(int characterId) async {
    if (_favoritesById.remove(characterId) != null) {
      notifyListeners();
      await _persist();
    }
  }

  /// Adds [character] to the favorites if it isn't already there,
  /// removes it otherwise.
  Future<void> toggle(Character character) {
    if (isFavorite(character.id)) {
      return remove(character.id);
    }
    return add(character);
  }
}
