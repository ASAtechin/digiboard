// Screen widgets, without any network: the pairing code, the revoked notice
// and the offline banner. Replaces the old test that called a live backend (F-1).
import 'package:digiboard_app/platform/display_controller.dart';
import 'package:digiboard_app/platform/display_gate.dart';
import 'package:digiboard_app/platform/display_models.dart';
import 'package:digiboard_app/platform/display_store.dart';
import 'package:digiboard_app/platform/platform_client.dart';
import 'package:digiboard_app/platform/screen_widgets.dart';
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

  /// A live screen showing a feed from the fake platform, on a fixed clock.
  DisplayController liveWith(FakePlatform server, DateTime Function() clock) {
    final c = DisplayController(
      client: PlatformClient('https://platform.test/v1', client: server.client),
      store: MemoryDisplayStore(),
      now: clock,
    );
    c.feed = DisplayFeed.fromJson(server.feed());
    c.status = DisplayStatus.live;
    c.savedAt = clock();
    return c;
  }

  testWidgets('"Updated 09:00", then "Not updated since 09:00" once the feed is no longer good', (tester) async {
    var now = DateTime(2026, 11, 2, 9, 0);
    final c = liveWith(FakePlatform(), () => now);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LastUpdatedBadge(controller: c))));
    expect(find.text('Updated 09:00'), findsOneWidget);
    now = now.add(const Duration(minutes: 3));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: [LastUpdatedBadge(controller: c), ConnectionBanner(controller: c)]))));
    expect(find.text('Not updated since 09:00'), findsOneWidget);
    expect(find.textContaining('this screen cannot confirm it is up to date'), findsOneWidget);
  });

  testWidgets('outside its hours the screen shows a clock and the school, or goes dim', (tester) async {
    final server = FakePlatform()..hours = {'rule': 'custom', 'on': '07:00:00', 'off': '18:00:00', 'offDisplay': 'clock', 'onNow': false};
    final c = liveWith(server, () => DateTime(2026, 11, 2, 19, 5));
    await tester.pumpWidget(MaterialApp(home: DisplayGate(controller: c)));
    expect(find.byKey(const ValueKey('off-hours')), findsOneWidget);
    expect(find.text('19:05'), findsOneWidget);
    expect(find.text('Green Valley School'), findsOneWidget);
    expect(find.textContaining('Mathematics'), findsNothing);

    server.hours = {'rule': 'custom', 'on': '07:00:00', 'off': '18:00:00', 'offDisplay': 'dim', 'onNow': false};
    final dim = liveWith(server, () => DateTime(2026, 11, 2, 19, 5));
    await tester.pumpWidget(MaterialApp(home: OffHoursScreen(controller: dim)));
    expect(find.text('Green Valley School'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets("the staff room lists today's substitutions with staff names, notices and events", (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = FakePlatform()
      ..mode = 'staff_room'
      ..cards = [FakePlatform.substitutionCard('Imran Khan', 'Asha Rao'), FakePlatform.eventCard('Parent-teacher meeting')]
      ..notices = [
        {'id': 'n1', 'title': 'Staff meeting', 'body': 'Library at 3', 'expiresAt': '2026-11-02T04:00:00Z'},
      ];
    final c = liveWith(server, () => DateTime(2026, 11, 2, 9, 0));
    await tester.pumpWidget(MaterialApp(home: DisplayGate(controller: c)));
    expect(find.byKey(const ValueKey('staff-room')), findsOneWidget);
    expect(find.text("Today's substitutions"), findsOneWidget);
    expect(find.text('Imran Khan'), findsOneWidget);
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Class 7 B'), findsOneWidget);
    expect(find.textContaining('Staff meeting'), findsOneWidget);
    expect(find.text('Parent-teacher meeting'), findsOneWidget);
    expect(find.text('Updated 09:00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a drill shows on a screen that is off for the night', (tester) async {
    final server = FakePlatform()
      ..mode = 'staff_room'
      ..hours = {'rule': 'school', 'on': '06:50:00', 'off': '15:30:00', 'offDisplay': 'dim', 'onNow': false};
    final c = liveWith(server, () => DateTime(2026, 11, 2, 22, 0));
    c.alerts = [ScreenAlert(id: 'i1', kind: 'drill', severity: 'warning', message: 'Night fire drill', version: 1)];
    await tester.pumpWidget(MaterialApp(home: DisplayGate(controller: c)));
    expect(find.byKey(const ValueKey('off-hours')), findsNothing);
    expect(find.text('DRILL: Night fire drill'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('cards of any type show their heading and lines; events their title', (tester) async {
    final bus = ScreenCard.fromJson({
      'id': 'transport.bus_delay:r12',
      'type': 'transport.bus_delay',
      'heading': 'Bus delays',
      'expiresAt': '2026-11-02T03:40:00Z',
      'values': {'route': '12', 'delay': 15},
      'lines': [
        {'label': 'Route', 'text': '12'},
        {'label': 'Late by', 'text': '15 min'},
      ],
    });
    final event = ScreenCard.fromJson(FakePlatform.eventCard('Annual sports day'));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CardsStrip(cards: [bus, event]))));
    expect(find.text('BUS DELAYS'), findsOneWidget);
    expect(find.text('Late by: 15 min'), findsOneWidget);
    expect(find.text('Annual sports day'), findsOneWidget);
    expect(find.text('Where: Main ground'), findsOneWidget);
  });
}

