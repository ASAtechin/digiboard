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

  /// When the notice must leave the screen if nothing newer arrives, or null (older platforms).
  final DateTime? expiresAt;
  ScreenNotice(this.title, this.body, [this.expiresAt]);
}

extension FeedNotices on DisplayFeed {
  List<ScreenNotice> get notices => (raw['notices'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(
        (n) => ScreenNotice(
          n['title']?.toString() ?? '',
          n['body']?.toString() ?? '',
          _time(n['expiresAt']),
        ),
      )
      .toList();
}

DateTime? _time(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// What a screen shows: its room's day, the whole school, or the staff room.
enum ScreenMode { classroom, lobby, staffRoom }

ScreenMode _modeOf(Object? v, {required bool hasRoom}) => switch (v) {
  'classroom' => ScreenMode.classroom,
  'lobby' => ScreenMode.lobby,
  'staff_room' => ScreenMode.staffRoom,
  // Platforms before modes: a room makes it a classroom screen.
  _ => hasRoom ? ScreenMode.classroom : ScreenMode.lobby,
};

String modeName(ScreenMode m) => switch (m) {
  ScreenMode.classroom => 'classroom',
  ScreenMode.lobby => 'lobby',
  ScreenMode.staffRoom => 'staff_room',
};

/// When the screen is on today. Times are school-local HH:MM:SS; the screen
/// runs in the school's time zone (kiosk guide), so it decides on its own
/// clock, even offline.
class ScreenHours {
  final String rule; // school | custom | always
  final String? on;
  final String? off;

  /// 'clock': a clock and the school's name; 'dim': almost nothing.
  final String offDisplay;

  const ScreenHours({required this.rule, this.on, this.off, this.offDisplay = 'clock'});

  /// Older platforms send no hours: always on, as before.
  static const always = ScreenHours(rule: 'always');

  factory ScreenHours.fromJson(Object? json) {
    if (json is! Map) return always;
    return ScreenHours(
      rule: json['rule']?.toString() ?? 'always',
      on: json['on']?.toString(),
      off: json['off']?.toString(),
      offDisplay: json['offDisplay'] == 'dim' ? 'dim' : 'clock',
    );
  }

  bool isOn(DateTime now) {
    if (rule == 'always') return true;
    if (on == null || off == null) return false;
    final t = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return on!.compareTo(t) <= 0 && t.compareTo(off!) < 0;
  }
}

/// A card from an event or another module. Every card carries labelled lines,
/// so a screen can show card types it does not know yet.
class ScreenCard {
  final String id;
  final String type;
  final String heading;
  final DateTime? expiresAt;
  final Map<String, dynamic> values;
  final List<({String label, String text})> lines;

  ScreenCard({required this.id, required this.type, required this.heading, required this.expiresAt, required this.values, required this.lines});

  factory ScreenCard.fromJson(Map<String, dynamic> json) => ScreenCard(
    id: json['id']?.toString() ?? '',
    type: json['type']?.toString() ?? '',
    heading: json['heading']?.toString() ?? '',
    expiresAt: _time(json['expiresAt']),
    values: (json['values'] as Map?)?.cast<String, dynamic>() ?? const {},
    lines: (json['lines'] as List? ?? const [])
        .whereType<Map>()
        .map((l) => (label: l['label']?.toString() ?? '', text: l['text']?.toString() ?? ''))
        .toList(),
  );

  String? text(String key) => values[key]?.toString();
}

/// Freshness and expiry: how long each part of a feed may stay on screen.
/// Durations are measured from when the platform made the feed, and applied
/// on the screen's own clock from when it arrived, so a wrong clock on the
/// screen does not keep content on longer.
extension FeedFreshness on DisplayFeed {
  DateTime? get generatedAt => _time(raw['generatedAt']);
  DateTime? get validUntil => _time(raw['validUntil']);
  String? get contentHash => raw['contentHash']?.toString();
  String? get summary => raw['summary']?.toString();

  ScreenMode get mode => _modeOf(raw['mode'] ?? (raw['device'] as Map?)?['mode'], hasRoom: roomName != null);
  ScreenHours get hours => ScreenHours.fromJson(raw['hours']);

  List<ScreenCard> get cards => (raw['cards'] as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(ScreenCard.fromJson)
      .toList();

  /// Up to date for this long; after it, the screen says when it last updated.
  Duration get freshFor {
    final made = generatedAt, until = validUntil;
    if (made != null && until != null) return until.difference(made);
    return Duration(seconds: refreshAfterSeconds * 2 + 30);
  }

  /// How long content that ends at [at] may stay; null: no limit beyond today.
  Duration? lifetimeUntil(DateTime? at) {
    final made = generatedAt;
    if (made == null || at == null) return null;
    return at.difference(made);
  }

  /// How long a kind of content may stay without a newer feed ('notices', a card type).
  Duration? lifetimeOf(String kind) => lifetimeUntil(_time((raw['content'] as Map?)?[kind]?['expiresAt']));
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
