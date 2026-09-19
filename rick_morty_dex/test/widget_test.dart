// Basic smoke test: with no session persisted, the app should land on
// the login screen after AuthProvider finishes restoring its state.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rick_morty_dex/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Shows the login screen when there is no active session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RickMortyDexApp());
    await tester.pumpAndSettle();

    expect(find.text('Entre para continuar'), findsOneWidget);
  });
}
