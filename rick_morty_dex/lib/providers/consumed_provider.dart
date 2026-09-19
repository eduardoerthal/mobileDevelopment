import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

/// Tracks which characters the user has marked as "visualizado" (viewed),
/// persisted locally via [SharedPreferences] (the full [Character] is
/// stored as JSON, so the list survives closing and reopening the app).
class ConsumedProvider extends ChangeNotifier {
  static const _prefsKey = 'consumed_characters';

  /// Keyed by character id for O(1) lookups; a [Map] preserves insertion
  /// order, so [consumed] naturally lists items in the order they were
  /// marked.
  final Map<int, Character> _consumedById = {};

  /// Characters marked as viewed, in the order they were marked.
  List<Character> get consumed => List.unmodifiable(_consumedById.values);

  bool isConsumed(int characterId) => _consumedById.containsKey(characterId);

  /// Loads previously persisted "viewed" characters. Call once, before
  /// the first build — e.g. in `main()` before `runApp` — so the UI
  /// never flashes an empty list on startup.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final item in decoded) {
        final character = Character.fromJson(item as Map<String, dynamic>);
        _consumedById[character.id] = character;
      }
      notifyListeners();
    } catch (error) {
      // Corrupted/incompatible persisted data shouldn't crash startup —
      // just start with an empty consumed list.
      debugPrint('ConsumedProvider: failed to load persisted data: $error');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _consumedById.values.map((character) => character.toJson()).toList(),
      );
      await prefs.setString(_prefsKey, encoded);
    } catch (error) {
      debugPrint('ConsumedProvider: failed to persist consumed list: $error');
    }
  }

  Future<void> add(Character character) async {
    if (_consumedById.containsKey(character.id)) return;
    _consumedById[character.id] = character;
    notifyListeners();
    await _persist();
  }

  Future<void> remove(int characterId) async {
    if (_consumedById.remove(characterId) != null) {
      notifyListeners();
      await _persist();
    }
  }

  /// Marks [character] as viewed if it isn't already, unmarks it
  /// otherwise.
  Future<void> toggle(Character character) {
    if (isConsumed(character.id)) {
      return remove(character.id);
    }
    return add(character);
  }
}
