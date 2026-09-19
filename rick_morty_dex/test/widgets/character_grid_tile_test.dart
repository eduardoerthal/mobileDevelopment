// Verifies the catalog grid tile: (1) survives a large accessibility
// text scale without overflowing, (2) exposes one merged, descriptive
// semantics label instead of separate/unlabeled stops, and (3) meets
// Flutter's official tap-target-size and labeled-tap-target guidelines.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_dex/models/character.dart';
import 'package:rick_morty_dex/widgets/character_grid_tile.dart';

const _rick = Character(
  id: 1,
  name: 'Rick Sanchez',
  status: 'Alive',
  species: 'Human',
  type: '',
  gender: 'Male',
  origin: LocationReference(name: 'Earth (C-137)', url: ''),
  location: LocationReference(name: 'Citadel of Ricks', url: ''),
  // Empty on purpose: renders the placeholder, no network needed here.
  image: '',
);

Widget _wrap(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            // Matches CatalogScreen's 2-column grid cell shape
            // (childAspectRatio: 0.7) at a plausible phone width.
            width: 170,
            height: 170 / 0.7,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'does not overflow at a large accessibility text scale',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          CharacterGridTile(character: _rick, onTap: () {}),
          textScale: 3.0,
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('exposes one merged, descriptive semantics label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(CharacterGridTile(character: _rick, onTap: () {})),
    );

    expect(find.bySemanticsLabel('Ver detalhes de Rick Sanchez'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('meets tap target size and labeled tap target guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(CharacterGridTile(character: _rick, onTap: () {})),
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  });
}
