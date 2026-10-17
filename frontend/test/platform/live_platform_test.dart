// Contract test against a running Shiksha Tantra platform: the real server and
// this app agree on pairing, the feed and revocation. Skipped unless
// PLATFORM_URL (…/v1) and PLATFORM_TOKEN (an office_staff API token) are set:
//   PLATFORM_URL=http://localhost:3000/v1 PLATFORM_TOKEN=st_… flutter test test/platform/live_platform_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:digiboard_app/platform/display_controller.dart';
import 'package:digiboard_app/platform/display_store.dart';
import 'package:digiboard_app/platform/platform_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  final url = Platform.environment['PLATFORM_URL'];
  final token = Platform.environment['PLATFORM_TOKEN'];
  final roomName = Platform.environment['PLATFORM_ROOM'] ?? 'Room 101';
  final skip = url == null || token == null
      ? 'Set PLATFORM_URL and PLATFORM_TOKEN to run against a live platform'
      : null;

  Map<String, String> staff() => {
    'authorization': 'Bearer $token',
    'content-type': 'application/json',
  };

  test(
    'pair, read the feed, and stop when revoked, against the real server',
    () async {
      final rooms =
          json.decode(
                (await http.get(
                  Uri.parse('$url/rooms'),
                  headers: staff(),
                )).body,
              )['items']
              as List;
      final room = rooms.firstWhere((r) => r['name'] == roomName);

      final store = MemoryDisplayStore();
      final controller = DisplayController(
        client: PlatformClient(url!),
        store: store,
      );
      addTearDown(controller.dispose);
      await controller.start();
      expect(controller.status, DisplayStatus.pairing);
      final code = controller.pairing!.code;

      final claim = await http.post(
        Uri.parse('$url/devices/claim'),
        headers: staff(),
        body: json.encode({
          'code': code,
          'name': 'Contract test screen',
          'roomId': room['id'],
        }),
      );
      expect(claim.statusCode, 201, reason: claim.body);
      final deviceId = json.decode(claim.body)['id'];

      await controller.pollPairing();
      expect(controller.status, DisplayStatus.live);

      final day = json.decode(
        (await http.get(
          Uri.parse('$url/schedule/day?roomId=${room['id']}'),
          headers: staff(),
        )).body,
      );
      final expected = (day['entries'] as List)
          .map((e) => e['subject']['name'])
          .toList();
      expect(controller.lectures.map((l) => l.subject).toList(), expected);
      expect(controller.lectures.every((l) => l.classroom == roomName), isTrue);

      final revoke = await http.post(
        Uri.parse('$url/devices/$deviceId/revoke'),
        headers: staff(),
        body: '{}',
      );
      expect(revoke.statusCode, 204);
      await controller.refresh();
      expect(controller.wasRevoked, isTrue);
      expect(controller.lectures, isEmpty);
      expect(await store.read(DisplayController.tokenKey), isNull);
    },
    skip: skip,
  );
}
