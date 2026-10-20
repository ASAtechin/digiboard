// W4: a screen never shows stale content without saying so. "Last updated",
// the stale state, expiry per kind of content, on and off hours, screen
// modes, and the heartbeat that tells the office what the screen shows.
import 'dart:convert';
import 'package:digiboard_app/platform/display_controller.dart';
import 'package:digiboard_app/platform/display_models.dart';
import 'package:digiboard_app/platform/display_store.dart';
import 'package:digiboard_app/platform/platform_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fake_platform.dart';

void main() {
  late FakePlatform server;
  var clock = DateTime(2026, 11, 2, 9, 0);

  Future<DisplayController> paired() async {
    final c = DisplayController(
      client: PlatformClient('https://platform.test/v1', client: server.client),
      store: MemoryDisplayStore(),
      now: () => clock,
    );
    addTearDown(c.dispose);
    await c.start();
    server.claimed = true;
    await c.pollPairing();
    await Future<void>.delayed(Duration.zero);
    return c;
  }

  void later(Duration d) => clock = clock.add(d);

  setUp(() {
    server = FakePlatform();
    clock = DateTime(2026, 11, 2, 9, 0);
  });

  test('live: "Updated 09:00"; after the time the feed is good for, the screen says it is not up to date', () async {
    final c = await paired();
    expect(c.lastUpdated, DateTime(2026, 11, 2, 9, 0));
    expect(c.isStale, isFalse);
    expect(c.shownState, 'live');
    later(const Duration(minutes: 2));
    expect(c.isStale, isFalse, reason: 'two refreshes and 30 s: 150 s');
    later(const Duration(seconds: 31));
    expect(c.isStale, isTrue);
    expect(c.shownState, 'stale');
    expect(c.shownSummary, contains('not updated since 09:00'));
    // A fresh feed makes it current again.
    await c.refresh();
    expect(c.isStale, isFalse);
  });

  test('offline: the timetable stays for the day, notices go after 30 minutes, events after four hours', () async {
    server.notices = [
      {'id': 'n1', 'title': 'Sports day', 'body': 'Friday', 'expiresAt': '2026-11-02T04:00:00Z'},
    ];
    server.cards = [FakePlatform.eventCard('Annual sports day')];
    final c = await paired();
    expect(c.notices, hasLength(1));
    expect(c.cards.single.text('title'), 'Annual sports day');

    server.feedMode = FeedMode.offline;
    later(const Duration(minutes: 10));
    await c.refresh();
    expect(c.status, DisplayStatus.offlineCached);
    expect(c.isStale, isTrue);
    expect(c.shownState, 'offline_cached');
    expect(c.notices, hasLength(1), reason: 'still within 30 minutes');

    later(const Duration(minutes: 21));
    expect(c.notices, isEmpty, reason: 'a notice could have been withdrawn: it leaves');
    expect(c.cards, hasLength(1));
    expect(c.lectures, hasLength(2), reason: "today's timetable stays, with the offline banner");
    expect(c.shownSummary, contains('expired notices or cards taken off'));

    later(const Duration(hours: 4));
    expect(c.cards, isEmpty);

    // Next morning, still offline: nothing from yesterday.
    clock = DateTime(2026, 11, 3, 7, 30);
    await c.refresh();
    expect(c.status, DisplayStatus.unavailable);
    expect(c.lectures, isEmpty);
    expect(c.notices, isEmpty);
  });

  test("a notice ending soon leaves at its own end, even offline", () async {
    server.notices = [
      {'id': 'n1', 'title': 'Short', 'body': 'Ends at 09:10', 'expiresAt': '2026-11-02T03:40:00Z'},
    ];
    final c = await paired();
    server.feedMode = FeedMode.offline;
    later(const Duration(minutes: 9));
    await c.refresh();
    expect(c.notices, hasLength(1));
    later(const Duration(minutes: 2));
    expect(c.notices, isEmpty);
  });

  test('the screen measures expiry on its own clock from when the feed arrived, whatever its date says', () async {
    // The screen's clock is 3 hours fast; the feed is still good for 150 s from arrival.
    clock = DateTime(2026, 11, 2, 12, 0);
    final c = await paired();
    expect(c.isStale, isFalse);
    later(const Duration(seconds: 151));
    expect(c.isStale, isTrue);
  });

  test('on and off hours are decided on the screen, so it goes dark on time even offline', () async {
    server.hours = {'rule': 'custom', 'on': '07:00:00', 'off': '18:00:00', 'offDisplay': 'dim', 'onNow': true};
    final c = await paired();
    expect(c.onHours, isTrue);
    server.feedMode = FeedMode.offline;
    clock = DateTime(2026, 11, 2, 18, 0);
    expect(c.onHours, isFalse);
    expect(c.shownState, 'off_hours');
    expect(c.shownSummary, 'Off hours: dimmed');
  });

  test('always on; and an older platform without hours keeps the screen on', () async {
    server.hours = {'rule': 'always', 'on': null, 'off': null, 'offDisplay': 'clock', 'onNow': true};
    final c = await paired();
    clock = DateTime(2026, 11, 2, 23, 30);
    expect(c.onHours, isTrue);
    server.hours = null;
    await c.refresh();
    expect(c.onHours, isTrue);
    // School hours with no lessons today: off all day.
    server.hours = {'rule': 'school', 'on': null, 'off': null, 'offDisplay': 'clock', 'onNow': false};
    clock = DateTime(2026, 11, 2, 9, 0);
    await c.refresh();
    expect(c.onHours, isFalse);
  });

  test('the mode comes from the feed; older platforms: a room means a classroom screen', () async {
    server.mode = 'staff_room';
    expect((await paired()).mode, ScreenMode.staffRoom);
    final old = FakePlatform().feed()..remove('mode');
    expect(DisplayFeed.fromJson(old).mode, ScreenMode.classroom);
    final lobby = FakePlatform().feed()
      ..remove('mode')
      ..['device'] = {'id': 'd', 'name': 'Lobby', 'room': null};
    expect(DisplayFeed.fromJson(lobby).mode, ScreenMode.lobby);
  });

  test('staff-room substitutions and other cards expire on their own', () async {
    server.mode = 'staff_room';
    server.cards = [FakePlatform.substitutionCard('Imran Khan', 'Asha Rao'), FakePlatform.eventCard('PTM')];
    final c = await paired();
    expect(c.cards.map((x) => x.type), ['timetable.substitution', 'screens.event']);
    server.feedMode = FeedMode.offline;
    later(const Duration(minutes: 31));
    await c.refresh();
    expect(c.cards.map((x) => x.type), ['screens.event'], reason: 'substitutions are good for 30 minutes');
  });

  test('the heartbeat tells the office what the screen shows', () async {
    clock = DateTime(2026, 11, 2, 9, 0, 20);
    final c = await paired();
    final beat = json.decode(server.heartbeats.single) as Map<String, dynamic>;
    expect(beat, containsPair('appVersion', DisplayController.appVersion));
    expect(DisplayController.appVersion, '2.2.0');
    expect(beat, containsPair('status', 'live'));
    expect(beat, containsPair('state', 'live'));
    expect(beat, containsPair('mode', 'classroom'));
    expect(beat, containsPair('contentHash', 'abc123def456'));
    expect(beat['summary'], 'Now: Period 2 English (Class 6 A)');
    expect(DateTime.parse(beat['startedAt'] as String), c.startedAt.toUtc());
    expect(DateTime.parse(beat['screenTime'] as String), clock.toUtc());
  });

  test('a screen whose school has no screens in its plan says so in its heartbeat', () async {
    final c = await paired();
    server.feedMode = FeedMode.notInPlan;
    await c.refresh();
    await Future<void>.delayed(Duration.zero);
    final beat = json.decode(server.heartbeats.last) as Map<String, dynamic>;
    expect(beat, containsPair('state', 'not_active'));
  });

  test('a platform from before 2.2 gets the short heartbeat it understands', () async {
    server.oldHeartbeat = true;
    await paired();
    final beat = json.decode(server.heartbeats.single) as Map<String, dynamic>;
    expect(beat, {'status': 'live', 'appVersion': '2.2.0'});
  });
}
