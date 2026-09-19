// Verifies FavoritesProvider persists via shared_preferences: data added
// in one provider instance must be loaded back by a brand-new instance's
// initialize() — simulating the app being closed and reopened.

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_dex/models/character.dart';
import 'package:rick_morty_dex/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _rick = Character(
  id: 1,
  name: 'Rick Sanchez',
  status: 'Alive',
  species: 'Human',
  type: '',
  gender: 'Male',
  origin: LocationReference(name: 'Earth (C-137)', url: ''),
  location: LocationReference(name: 'Citadel of Ricks', url: ''),
  image: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
);

const _morty = Character(
  id: 2,
  name: 'Morty Smith',
  status: 'Alive',
  species: 'Human',
  type: '',
  gender: 'Male',
  origin: LocationReference(name: 'Earth (C-137)', url: ''),
  location: LocationReference(name: 'Citadel of Ricks', url: ''),
  image: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('a new app session loads favorites added in a previous one', () async {
    // "First launch": no persisted data yet.
    final firstSession = FavoritesProvider();
    await firstSession.initialize();
    expect(firstSession.favorites, isEmpty);

    await firstSession.add(_rick);
    await firstSession.add(_morty);

    // "App reopened": a fresh provider, backed by the same
    // SharedPreferences store, should restore both favorites.
    final secondSession = FavoritesProvider();
    await secondSession.initialize();

    expect(secondSession.favorites, hasLength(2));
    expect(secondSession.isFavorite(_rick.id), isTrue);
    expect(secondSession.isFavorite(_morty.id), isTrue);
    expect(
      secondSession.favorites.map((c) => c.name),
      containsAll(<String>['Rick Sanchez', 'Morty Smith']),
    );
  });

  test('removing a favorite persists across sessions too', () async {
    final firstSession = FavoritesProvider();
    await firstSession.initialize();
    await firstSession.add(_rick);
    await firstSession.add(_morty);
    await firstSession.remove(_rick.id);

    final secondSession = FavoritesProvider();
    await secondSession.initialize();

    expect(secondSession.favorites, hasLength(1));
    expect(secondSession.isFavorite(_rick.id), isFalse);
    expect(secondSession.isFavorite(_morty.id), isTrue);
  });

  test('toggle() both favorites and unfavorites, persisting either way', () async {
    final firstSession = FavoritesProvider();
    await firstSession.initialize();

    await firstSession.toggle(_rick);
    expect(firstSession.isFavorite(_rick.id), isTrue);

    await firstSession.toggle(_rick);
    expect(firstSession.isFavorite(_rick.id), isFalse);

    final secondSession = FavoritesProvider();
    await secondSession.initialize();
    expect(secondSession.favorites, isEmpty);
  });
}
