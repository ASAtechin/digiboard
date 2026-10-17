// The screen feed from the Shiksha Tantra platform (GET /v1/display/feed),
// and its conversion to the Lecture objects the existing screens draw.
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
