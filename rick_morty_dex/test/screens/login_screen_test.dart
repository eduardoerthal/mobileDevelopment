// Verifies LoginScreen: (1) survives a large accessibility text scale
// without overflowing, and (2) meets Flutter's official text-contrast,
// tap-target-size and labeled-tap-target guidelines. No SharedPreferences
// mocking or Provider ancestor is needed here — LoginScreen only reads
// AuthProvider from inside its submit handler, never during build.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_dex/screens/login_screen.dart';

Widget _wrap({double textScale = 1.0}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: const LoginScreen(),
    ),
  );
}

void main() {
  testWidgets(
    'does not overflow at a large accessibility text scale',
    (tester) async {
      await tester.pumpWidget(_wrap(textScale: 3.0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'meets text contrast, tap target size and labeled tap target guidelines',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap());

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    },
  );
}
