// A fake Shiksha Tantra platform for screen tests: no real network.
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

enum FeedMode { ok, offline, serverError, revoked, notInPlan }

class FakePlatform {
  bool claimed = false;
  FeedMode feedMode = FeedMode.ok;
  String feedDate = '2026-11-02';
  int pairingRequests = 0;
  final List<String> heartbeats = [];
  List<Map<String, dynamic>> alerts = [];
  List<Map<String, dynamic>> notices = [];
  DateTime serverTime = DateTime.utc(2026, 11, 2, 3, 30);
  Map<String, dynamic> branding = {'shortName': null, 'tagline': null, 'primaryColor': null, 'accentColor': null, 'logoVersion': null};
  List<int>? logo;
  int logoRequests = 0;

  static Map<String, dynamic> entry(
    String className,
    String section,
    int period,
    String start,
    String end,
    String subject,
    String teacher,
    String room, {
    bool substituted = false,
  }) => {
    'section': {
      'id': '$className-$section',
      'name': section,
      'className': className,
    },
    'periodNumber': period,
    'label': 'Period $period',
    'startsAt': start,
    'endsAt': end,
    'subject': {
      'id': subject,
      'name': subject,
      'code': subject.substring(0, 3).toUpperCase(),
    },
    'teacher': {'id': 't-$teacher', 'name': teacher},
    'room': {'id': 'r-$room', 'name': room, 'code': null},
    'substitution': substituted ? {'id': 's1', 'reason': 'On leave'} : null,
  };

  Map<String, dynamic> feed() => {
    'date': feedDate,
    'refreshAfterSeconds': 60,
    'school': {'name': 'Green Valley School', 'timezone': 'Asia/Kolkata'},
    'device': {
      'id': 'd1',
      'name': 'Room 101 screen',
      'room': {'id': 'r-Room 101', 'name': 'Room 101'},
    },
    'notices': notices,
    'modules': ['timetable', 'screens', 'notices', 'drills'],
    'branding': branding,
    'entries': [
      entry(
        'Class 6',
        'A',
        1,
        '08:10:00',
        '08:50:00',
        'Mathematics',
        'Asha Rao',
        'Room 101',
      ),
      entry(
        'Class 6',
        'A',
        2,
        '08:50:00',
        '09:30:00',
        'English',
        'Imran Khan',
        'Room 101',
        substituted: true,
      ),
    ],
  };

  http.Client get client => MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/device/pairing')) {
      pairingRequests++;
      return http.Response(
        json.encode({
          'code': 'ABCD-EF${pairingRequests.toString().padLeft(2, '0')}',
          'pollToken': 'pp_test_token_$pairingRequests',
          'expiresAt': '2099-01-01T00:00:00Z',
          'pollIntervalSeconds': 3,
        }),
        201,
      );
    }
    if (path.endsWith('/device/pairing/poll')) {
      return claimed
          ? http.Response(
              json.encode({
                'status': 'paired',
                'deviceToken': 'sd_screen_token',
              }),
              200,
            )
          : http.Response(json.encode({'status': 'pending'}), 202);
    }
    if (path.endsWith('/display/logo')) {
      logoRequests++;
      return logo == null ? http.Response('{"error":"not_found"}', 404) : http.Response.bytes(logo!, 200, headers: {'content-type': 'image/png'});
    }
    if (feedMode == FeedMode.notInPlan && path.endsWith('/display/feed')) {
      return http.Response('{"error":"module_not_enabled","module":"screens"}', 403);
    }
    if (path.endsWith('/display/feed') ||
        path.endsWith('/display/heartbeat') ||
        path.endsWith('/display/alerts')) {
      switch (feedMode) {
        case FeedMode.offline:
          throw const SocketException('Network is unreachable');
        case FeedMode.serverError:
          return http.Response('{"error":"unavailable"}', 503);
        case FeedMode.revoked:
          return http.Response('{"error":"unauthorized"}', 401);
        case FeedMode.ok:
        case FeedMode.notInPlan:
          if (request.headers['authorization'] != 'Bearer sd_screen_token') {
            return http.Response('{}', 401);
          }
          if (path.endsWith('/alerts')) {
            return http.Response(
              json.encode({
                'serverTime': serverTime.toIso8601String(),
                'validUntil': serverTime
                    .add(const Duration(seconds: 45))
                    .toIso8601String(),
                'pollAfterSeconds': 10,
                'alerts': alerts,
              }),
              200,
            );
          }
          if (path.endsWith('/heartbeat')) {
            heartbeats.add(request.body);
            return http.Response(
              json.encode({'serverTime': '2026-11-02T03:30:00Z'}),
              200,
            );
          }
          return http.Response(json.encode(feed()), 200);
      }
    }
    return http.Response('not found', 404);
  });
}
