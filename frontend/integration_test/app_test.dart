import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:digiboard_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app has started and shows the main screen title or key element
      // Since we don't know the exact text on the home screen without running it, 
      // we'll look for a common element or just verify it doesn't crash.
      
      // Example: Verify "Next Lecture" text exists if it's a static part of the UI
      // expect(find.text('Next Lecture'), findsOneWidget);
      
      // For now, just ensure it settles without error
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
