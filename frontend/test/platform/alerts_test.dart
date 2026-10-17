// Week 6, screen side: a drill shows on the screen labelled as a drill; when
// the alert status cannot be confirmed for 45 s the screen says so; silence
// is never treated as an all-clear (COM-F04).
import 'package:digiboard_app/platform/display_controller.dart';
import 'package:digiboard_app/platform/display_store.dart';
import 'package:digiboard_app/platform/platform_client.dart';
import 'package:digiboard_app/platform/platform_display.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fake_platform.dart';

void main() {
  late FakePlatform server;
  var clock = DateTime(2026, 11, 2, 9, 0);

  Future<DisplayController> pairedScreen() async {
    final c = DisplayController(
      client: PlatformClient('https://platform.test/v1', client: server.client),
      store: MemoryDisplayStore(),
      now: () => clock,
    );
    addTearDown(c.dispose);
    await c.start();
    server.claimed = true;
    await c.pollPairing();
    return c;
  }

  setUp(() {
    server = FakePlatform();
    clock = DateTime(2026, 11, 2, 9, 0);
  });

  test('no drill: the status is confirmed and shows no alert', () async {
    final c = await pairedScreen();
    expect(c.alertStatusUnknown, isFalse);
    expect(platformAlertStatus(c), {'active': false, 'alerts': []});
  });

  test('a drill appears on the next poll, labelled as a drill', () async {
    final c = await pairedScreen();
    server.alerts = [
      {
        'id': 'i1',
        'kind': 'drill',
        'severity': 'emergency',
        'message': 'Leave by the nearest exit',
        'version': 1,
      },
    ];
    await c.pollAlerts();
    final status = platformAlertStatus(c);
    expect(status['active'], isTrue);
    expect(status['type'], 'emergency');
    expect(status['message'], 'DRILL: Leave by the nearest exit');
  });

  test(
    'network lost: the last alert stays, and after 45 s the status is unavailable, not all-clear',
    () async {
      final c = await pairedScreen();
      server.alerts = [
        {
          'id': 'i1',
          'kind': 'drill',
          'severity': 'emergency',
          'message': 'Leave by the nearest exit',
          'version': 1,
        },
      ];
      await c.pollAlerts();
      server.feedMode = FeedMode.offline;
      clock = clock.add(const Duration(seconds: 20));
      await c.pollAlerts();
      expect(
        c.alertStatusUnknown,
        isFalse,
        reason: 'still within the 45 s the last answer is valid for',
      );
      expect(c.alerts.single.message, 'Leave by the nearest exit');

      clock = clock.add(const Duration(seconds: 30));
      await c.pollAlerts();
      expect(c.alertStatusUnknown, isTrue);
      expect(() => platformAlertStatus(c), throwsException);
      expect(
        c.alerts,
        isNotEmpty,
        reason: 'the last confirmed alert is kept on screen',
      );
    },
  );

  test('all-clear: the alert goes on the next poll', () async {
    final c = await pairedScreen();
    server.alerts = [
      {
        'id': 'i1',
        'kind': 'drill',
        'severity': 'warning',
        'message': 'Lockdown drill',
        'version': 2,
      },
    ];
    await c.pollAlerts();
    server.alerts = [];
    await c.pollAlerts();
    expect(platformAlertStatus(c)['active'], isFalse);
  });

  test('a revoked screen drops alerts with everything else', () async {
    final c = await pairedScreen();
    server.feedMode = FeedMode.revoked;
    await c.pollAlerts();
    expect(c.wasRevoked, isTrue);
    expect(c.alerts, isEmpty);
    expect(c.alertStatusUnknown, isTrue);
  });

  test('notices from the feed are available to show', () async {
    server.notices = [
      {
        'id': 'n1',
        'title': 'Sports day',
        'body': 'Friday. Wear house colours.',
      },
    ];
    final c = await pairedScreen();
    expect(c.notices.single.title, 'Sports day');
  });
}
