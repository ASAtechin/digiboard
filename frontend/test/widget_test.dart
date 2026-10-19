// Screen widgets, without any network: the pairing code, the revoked notice
// and the offline banner. Replaces the old test that called a live backend (F-1).
import 'package:digiboard_app/platform/display_controller.dart';
import 'package:digiboard_app/platform/display_gate.dart';
import 'package:digiboard_app/platform/display_models.dart';
import 'package:digiboard_app/platform/display_store.dart';
import 'package:digiboard_app/platform/platform_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'platform/fake_platform.dart';

void main() {
  DisplayController controllerIn(DisplayStatus status) {
    final c = DisplayController(
      client: PlatformClient(
        'https://platform.test/v1',
        client: FakePlatform().client,
      ),
      store: MemoryDisplayStore(),
    );
    c.status = status;
    return c;
  }

  testWidgets('the pairing screen shows the code and what to do with it', (
    tester,
  ) async {
    final c = controllerIn(DisplayStatus.pairing)
      ..pairing = PairingRequest('K7QM-4PXA', 'pp_x', DateTime(2099), 3);
    await tester.pumpWidget(MaterialApp(home: DisplayGate(controller: c)));
    expect(find.text('K7QM-4PXA'), findsOneWidget);
    expect(
      find.textContaining('open Screens, choose Add screen'),
      findsOneWidget,
    );
    expect(find.textContaining('removed by the school'), findsNothing);
  });

  testWidgets('a revoked screen says so on the pairing screen', (tester) async {
    final c = controllerIn(DisplayStatus.pairing)
      ..pairing = PairingRequest('K7QM-4PXA', 'pp_x', DateTime(2099), 3)
      ..wasRevoked = true;
    await tester.pumpWidget(MaterialApp(home: DisplayGate(controller: c)));
    expect(find.textContaining('removed by the school'), findsOneWidget);
  });

  testWidgets('the offline banner says the timetable is saved, and from when', (
    tester,
  ) async {
    final c = controllerIn(DisplayStatus.offlineCached)
      ..savedAt = DateTime(2026, 11, 2, 8, 5);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ConnectionBanner(controller: c)),
      ),
    );
    expect(
      find.textContaining(
        "Offline: showing today's saved timetable (saved 08:05)",
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'with nothing saved for today, the banner says the timetable is unavailable',
    (tester) async {
      final c = controllerIn(DisplayStatus.unavailable);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ConnectionBanner(controller: c)),
        ),
      );
      expect(find.textContaining('Timetable unavailable'), findsOneWidget);
    },
  );

  testWidgets('a screen whose school has no screens in its plan says so', (tester) async {
    final c = controllerIn(DisplayStatus.notActive);
    await tester.pumpWidget(MaterialApp(home: DisplayGate(controller: c)));
    expect(find.textContaining('DigiBoard is not active for this school'), findsOneWidget);
  });

  testWidgets('notices appear in the bar, coloured by the school, and the brand strip names the school', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const BrandStrip(branding: ScreenBranding(schoolName: 'Green Valley School', tagline: 'Learning together')),
              NoticeBar(notices: [ScreenNotice('Sports day', 'Friday, house colours')], colour: const Color(0xFF0F766E)),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Green Valley School'), findsOneWidget);
    expect(find.text('Learning together'), findsOneWidget);
    expect(find.textContaining('Sports day'), findsOneWidget);
  });
}
