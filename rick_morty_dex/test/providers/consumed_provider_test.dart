// Verifies ConsumedProvider persists via shared_preferences: data added
// in one provider instance must be loaded back by a brand-new instance's
// initialize() — simulating the app being closed and reopened.
// Mirrors favorites_provider_test.dart.

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_dex/models/character.dart';
import 'package:rick_morty_dex/providers/consumed_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _summerSmith = Character(
  id: 3,
  name: 'Summer Smith',
  status: 'Alive',
  species: 'Human',
  type: '',
  gender: 'Female',
  origin: LocationReference(name: 'Earth (Replacement Dimension)', url: ''),
  location: LocationReference(name: 'Earth (Replacement Dimension)', url: ''),
  image: 'https://rickandmortyapi.com/api/character/avatar/3.jpeg',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('a new app session loads the consumed list from a previous one', () async {
    final firstSession = ConsumedProvider();
    await firstSession.initialize();
    expect(firstSession.consumed, isEmpty);

    await firstSession.add(_summerSmith);

    final secondSession = ConsumedProvider();
    await secondSession.initialize();

    expect(secondSession.consumed, hasLength(1));
    expect(secondSession.isConsumed(_summerSmith.id), isTrue);
    expect(secondSession.consumed.first.name, 'Summer Smith');
  });

  test('unmarking a consumed character persists across sessions too', () async {
    final firstSession = ConsumedProvider();
    await firstSession.initialize();
    await firstSession.add(_summerSmith);
    await firstSession.remove(_summerSmith.id);

    final secondSession = ConsumedProvider();
    await secondSession.initialize();

    expect(secondSession.consumed, isEmpty);
    expect(secondSession.isConsumed(_summerSmith.id), isFalse);
  });
}
