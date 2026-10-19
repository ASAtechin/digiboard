// The screen feed from the Shiksha Tantra platform (GET /v1/display/feed),
// and its conversion to the Lecture objects the existing screens draw.
import 'package:flutter/painting.dart' show Color;
import '../models/lecture.dart';
import '../models/teacher.dart';

class FeedEntry {
  final String sectionLabel;
  final int periodNumber;
  final String label;
  final String startsAt; // HH:MM:SS, school time
  final String endsAt;
  final String subject;
  final String? teacherId;
  final String teacherName;
  final String roomName;
  final bool substituted;

  FeedEntry({
    required this.sectionLabel,
    required this.periodNumber,
    required this.label,
    required this.startsAt,
    required this.endsAt,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.roomName,
    required this.substituted,
  });

  factory FeedEntry.fromJson(Map<String, dynamic> json) {
    final section = (json['section'] as Map?) ?? const {};
    final subject = (json['subject'] as Map?) ?? const {};
    final teacher = json['teacher'] as Map?;
    final room = json['room'] as Map?;
    return FeedEntry(
      sectionLabel: '${section['className'] ?? ''} ${section['name'] ?? ''}'
          .trim(),
      periodNumber: (json['periodNumber'] as num?)?.toInt() ?? 0,
      label: json['label']?.toString() ?? '',
      startsAt: json['startsAt']?.toString() ?? '00:00:00',
      endsAt: json['endsAt']?.toString() ?? '00:00:00',
      subject: subject['name']?.toString() ?? '',
      teacherId: teacher?['id']?.toString(),
      teacherName: teacher?['name']?.toString() ?? '',
      roomName: room?['name']?.toString() ?? '',
      substituted: json['substitution'] != null,
    );
  }
}

class DisplayFeed {
  /// The school-local date the feed is for, YYYY-MM-DD.
  final String date;
  final String schoolName;
  final String deviceName;
  final String? roomName;
  final int refreshAfterSeconds;
  final List<FeedEntry> entries;
  final Map<String, dynamic> raw;

  DisplayFeed({
    required this.date,
    required this.schoolName,
    required this.deviceName,
    required this.roomName,
    required this.refreshAfterSeconds,
    required this.entries,
    required this.raw,
  });

  factory DisplayFeed.fromJson(Map<String, dynamic> json) {
    final school = (json['school'] as Map?) ?? const {};
    final device = (json['device'] as Map?) ?? const {};
    final room = device['room'] as Map?;
    final entries = (json['entries'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FeedEntry.fromJson)
        .toList();
    return DisplayFeed(
      date: json['date']?.toString() ?? '',
      schoolName: school['name']?.toString() ?? '',
      deviceName: device['name']?.toString() ?? '',
      roomName: room?['name']?.toString(),
      refreshAfterSeconds: (json['refreshAfterSeconds'] as num?)?.toInt() ?? 60,
      entries: entries,
      raw: json,
    );
  }

  /// Lessons for the existing timetable screens. Times are placed on the feed's
  /// date in the screen's local time; screens are expected to run in the school's time zone.
  List<Lecture> toLectures() {
    final day = DateTime.parse(date);
    DateTime at(String hhmmss) {
      final parts = hhmmss.split(':').map(int.parse).toList();
      return DateTime(
        day.year,
        day.month,
        day.day,
        parts[0],
        parts[1],
        parts.length > 2 ? parts[2] : 0,
      );
    }

    final lectures = entries
        .map(
          (e) => Lecture(
            id: '${e.sectionLabel}-${e.periodNumber}',
            subject: e.subject,
            // Names only: the platform never sends staff contact details to screens.
            teacher: Teacher(
              id: e.teacherId ?? '',
              name: e.teacherName,
              email: '',
              department: '',
            ),
            classroom: e.roomName,
            startTime: at(e.startsAt),
            endTime: at(e.endsAt),
            dayOfWeek: _weekdayName(day.weekday),
            lectureType: e.substituted ? 'Substitution' : 'Lecture',
            description: e.substituted ? 'Substitute arranged' : null,
            semester: '',
            course: e.sectionLabel,
          ),
        )
        .toList();
    lectures.sort((a, b) => a.startTime.compareTo(b.startTime));
    return lectures;
  }
}

String _weekdayName(int weekday) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][weekday - 1];

/// YYYY-MM-DD for a local date.
String localDateString(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

class ScreenAlert {
  final String id;
  final String kind; // drill
  final String severity; // emergency | warning | info
  final String message;
  final int version;

  ScreenAlert({
    required this.id,
    required this.kind,
    required this.severity,
    required this.message,
    required this.version,
  });

  factory ScreenAlert.fromJson(Map<String, dynamic> json) => ScreenAlert(
    id: json['id']?.toString() ?? '',
    kind: json['kind']?.toString() ?? 'drill',
    severity: json['severity']?.toString() ?? 'info',
    message: json['message']?.toString() ?? '',
    version: (json['version'] as num?)?.toInt() ?? 1,
  );

  /// What the screen shows: drills are always labelled as drills.
  String get displayMessage => kind == 'drill' ? 'DRILL: $message' : message;
}

/// One answer from the alert poll. It is trustworthy only until [validUntil].
class AlertStatus {
  final DateTime serverTime;
  final DateTime validUntil;
  final int pollAfterSeconds;
  final List<ScreenAlert> alerts;

  AlertStatus({
    required this.serverTime,
    required this.validUntil,
    required this.pollAfterSeconds,
    required this.alerts,
  });

  factory AlertStatus.fromJson(Map<String, dynamic> json) {
    final serverTime = DateTime.parse(json['serverTime'] as String);
    final validUntil = DateTime.parse(json['validUntil'] as String);
    return AlertStatus(
      serverTime: serverTime,
      validUntil: validUntil,
      pollAfterSeconds: (json['pollAfterSeconds'] as num?)?.toInt() ?? 10,
      alerts: (json['alerts'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ScreenAlert.fromJson)
          .toList(),
    );
  }

  /// How long this answer stays valid, measured on the screen's own clock, so a
  /// screen whose clock is wrong still times out correctly.
  Duration get lifetime => validUntil.difference(serverTime);
}

class ScreenNotice {
  final String title;
  final String body;
  ScreenNotice(this.title, this.body);
}

extension FeedNotices on DisplayFeed {
  List<ScreenNotice> get notices => (raw['notices'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(
        (n) => ScreenNotice(
          n['title']?.toString() ?? '',
          n['body']?.toString() ?? '',
        ),
      )
      .toList();
}

/// How the school looks on its screens: set by its admins in the admin.
class ScreenBranding {
  final String schoolName;
  final String? shortName;
  final String? tagline;
  final Color? primaryColor;
  final String? logoVersion;

  const ScreenBranding({
    required this.schoolName,
    this.shortName,
    this.tagline,
    this.primaryColor,
    this.logoVersion,
  });

  static Color? _colour(Object? hex) {
    final m = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(hex?.toString() ?? '');
    return m == null ? null : Color(0xFF000000 | int.parse(m.group(1)!, radix: 16));
  }

  factory ScreenBranding.fromFeed(Map<String, dynamic> raw) {
    final b = (raw['branding'] as Map?) ?? const {};
    final school = (raw['school'] as Map?) ?? const {};
    String? text(Object? v) => (v is String && v.trim().isNotEmpty) ? v.trim() : null;
    return ScreenBranding(
      schoolName: school['name']?.toString() ?? '',
      shortName: text(b['shortName']),
      tagline: text(b['tagline']),
      primaryColor: _colour(b['primaryColor']),
      logoVersion: text(b['logoVersion']),
    );
  }
}

extension FeedPlan on DisplayFeed {
  ScreenBranding get branding => ScreenBranding.fromFeed(raw);

  /// Modules in the school's plan; older platforms that do not send them include everything.
  List<String> get modules => (raw['modules'] as List?)?.map((m) => m.toString()).toList() ??
      const ['timetable', 'screens', 'notices', 'drills'];
}
