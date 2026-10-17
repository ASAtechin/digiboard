// Week 5 exit test, screen half: a paired screen keeps today's timetable when
// the network drops, never shows another day's, and stops when revoked.
import 'package:digiboard_app/platform/display_controller.dart';
import 'package:digiboard_app/platform/display_store.dart';
import 'package:digiboard_app/platform/platform_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fake_platform.dart';

void main() {
  late FakePlatform server;
  late MemoryDisplayStore store;
  var clock = DateTime(2026, 11, 2, 9, 0);

  DisplayController controller() {
    final c = DisplayController(
      client: PlatformClient('https://platform.test/v1', client: server.client),
      store: store,
      now: () => clock,
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<DisplayController> paired() async {
    final c = controller();
    await c.start();
    server.claimed = true;
    await c.pollPairing();
    return c;
  }

  setUp(() {
    server = FakePlatform();
    store = MemoryDisplayStore();
    clock = DateTime(2026, 11, 2, 9, 0);
  });

  test(
    'an unpaired screen shows a code, then goes live once staff claim it',
    () async {
      final c = controller();
      await c.start();
      expect(c.status, DisplayStatus.pairing);
      expect(c.pairing!.code, 'ABCD-EF01');

      await c.pollPairing();
      expect(
        c.status,
        DisplayStatus.pairing,
        reason: 'still waiting for staff',
      );

      server.claimed = true;
      await c.pollPairing();
      expect(c.status, DisplayStatus.live);
      expect(await store.read(DisplayController.tokenKey), 'sd_screen_token');
      expect(c.lectures.map((l) => l.subject), ['Mathematics', 'English']);
    },
  );

  test(
    'network drops: the screen keeps showing today\'s timetable and says it is offline',
    () async {
      final c = await paired();
      server.feedMode = FeedMode.offline;
      await c.refresh();
      expect(c.status, DisplayStatus.offlineCached);
      expect(c.lectures, hasLength(2));
      expect(c.savedAt, isNotNull);
    },
  );

  test('restarted while offline: today\'s saved timetable is used', () async {
    await paired();
    server.feedMode = FeedMode.offline;
    final restarted = controller();
    await restarted.start();
    expect(restarted.status, DisplayStatus.offlineCached);
    expect(restarted.lectures.first.teacher.name, 'Asha Rao');
  });

  test('offline on a new day: yesterday\'s timetable is never shown', () async {
    await paired();
    server.feedMode = FeedMode.offline;
    clock = DateTime(2026, 11, 3, 8, 0);
    final nextDay = controller();
    await nextDay.start();
    expect(nextDay.status, DisplayStatus.unavailable);
    expect(nextDay.lectures, isEmpty);
  });

  test('a server error is treated as offline, not as revocation', () async {
    final c = await paired();
    server.feedMode = FeedMode.serverError;
    await c.refresh();
    expect(c.status, DisplayStatus.offlineCached);
    expect(await store.read(DisplayController.tokenKey), 'sd_screen_token');
  });

  test(
    'revoked: the credential and saved timetable are wiped and the screen asks to be paired again',
    () async {
      final c = await paired();
      server.feedMode = FeedMode.revoked;
      await c.refresh();
      expect(c.status, DisplayStatus.pairing);
      expect(c.wasRevoked, isTrue);
      expect(c.lectures, isEmpty);
      expect(await store.read(DisplayController.tokenKey), isNull);
      expect(await store.read(DisplayController.feedKey), isNull);
      expect(c.pairing!.code, 'ABCD-EF02', reason: 'a fresh code');
    },
  );

  test('a live screen sends a heartbeat with its status and version', () async {
    await paired();
    await Future<void>.delayed(Duration.zero);
    expect(server.heartbeats.single, contains('"status":"live"'));
    expect(server.heartbeats.single, contains(DisplayController.appVersion));
  });

  test('lessons carry names only and the substitution is marked', () async {
    final c = await paired();
    final english = c.lectures[1];
    expect(english.teacher.email, isEmpty);
    expect(english.lectureType, 'Substitution');
    expect(english.startTime, DateTime(2026, 11, 2, 8, 50));
    expect(english.course, 'Class 6 A');
  });
}
