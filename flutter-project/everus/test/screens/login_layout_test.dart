import 'package:everus/screens/login/widgets/google_sign_in_button.dart';
import 'package:everus/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

/// Pumps [child] on a phone-sized screen, optionally with a large system text size.
Future<void> pumpOnPhone(WidgetTester tester, Widget child, {Size size = const Size(320, 640), double textScale = 1.0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery.withClampedTextScaling(
      minScaleFactor: textScale,
      maxScaleFactor: textScale,
      child: child,
    ),
  ));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetAppState());

  testWidgets('Google sign-in button fits a narrow button without overflowing', (tester) async {
    await pumpOnPhone(
      tester,
      Scaffold(body: Center(child: SizedBox(width: 200, child: GoogleSignInButton(onPressed: () {})))),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
  });

  for (final size in const [Size(320, 640), Size(375, 667), Size(800, 600)]) {
    testWidgets('onboarding login screen has no overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      await pumpOnPhone(tester, LoginScreen(isOnboardingMode: true, onContinueAsGuest: () {}), size: size);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('onboarding login screen has no overflow with large system text', (tester) async {
    await pumpOnPhone(tester, LoginScreen(isOnboardingMode: true, onContinueAsGuest: () {}),
        size: const Size(375, 667), textScale: 1.5);
    expect(tester.takeException(), isNull);
  });
}
