// Contract test against a running Shiksha Tantra platform: the real server and
// this app agree on pairing, the feed and revocation. Skipped unless
// PLATFORM_URL (…/v1) and PLATFORM_TOKEN (an office_staff API token) are set:
//   PLATFORM_URL=http://localhost:3000/v1 PLATFORM_TOKEN=st_… flutter test test/platform/live_platform_test.dart
// With PLATFORM_SCHOOL, PLATFORM_EMAIL and PLATFORM_PASSWORD (office staff without
// MFA) it also runs a drill end to end.
import 'dart:convert';
import 'dart:io';
import 'package:digiboard_app/platform/display_controller.dart';
import 'package:digiboard_app/platform/display_store.dart';
import 'package:digiboard_app/platform/platform_client.dart';
import 'package:digiboard_app/platform/platform_display.dart';
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

      final school = Platform.environment['PLATFORM_SCHOOL'];
      final email = Platform.environment['PLATFORM_EMAIL'];
      final password = Platform.environment['PLATFORM_PASSWORD'];
      if (school != null && email != null && password != null) {
        final login = json.decode(
          (await http.post(
            Uri.parse('$url/auth/login'),
            headers: {'content-type': 'application/json'},
            body: json.encode({
              'school': school,
              'email': email,
              'password': password,
            }),
          )).body,
        );
        final session = {
          'authorization': 'Bearer ${login['token']}',
          'content-type': 'application/json',
        };
        final preview = json.decode(
          (await http.post(
            Uri.parse('$url/alerts/preview'),
            headers: session,
            body: json.encode({
              'scope': 'rooms',
              'roomIds': [room['id']],
            }),
          )).body,
        );
        final drill = await http.post(
          Uri.parse('$url/alerts'),
          headers: {
            ...session,
            'idempotency-key':
                'contract-${DateTime.now().microsecondsSinceEpoch}',
          },
          body: json.encode({
            'kind': 'drill',
            'severity': 'emergency',
            'message': 'Contract test drill',
            'scope': 'rooms',
            'roomIds': [room['id']],
            'scopeHash': preview['scopeHash'],
            'password': password,
          }),
        );
        expect(drill.statusCode, 201, reason: drill.body);
        await controller.pollAlerts();
        expect(
          platformAlertStatus(controller)['message'],
          'DRILL: Contract test drill',
        );

        final incidentId = json.decode(drill.body)['id'];
        await http.post(
          Uri.parse('$url/alerts/$incidentId/clear'),
          headers: session,
          body: '{}',
        );
        await controller.pollAlerts();
        expect(platformAlertStatus(controller)['active'], isFalse);
        final detail = json.decode(
          (await http.get(
            Uri.parse('$url/alerts/$incidentId'),
            headers: session,
          )).body,
        );
        expect(
          detail['summary']['confirmed'],
          1,
          reason: 'the screen confirmed the all-clear',
        );
      }

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
