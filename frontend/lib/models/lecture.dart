import 'teacher.dart';

class Lecture {
  final String id;
  final String subject;
  final Teacher teacher;
  final String classroom;
  final DateTime startTime;
  final DateTime endTime;
  final String dayOfWeek;
  final String lectureType;
  final String? chapter;
  final String? description;
  final bool isActive;
  final String semester;
  final String course;

  Lecture({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.classroom,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    this.lectureType = 'Lecture',
    this.chapter,
    this.description,
    this.isActive = true,
    required this.semester,
    required this.course,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['_id'] ?? '',
      subject: json['subject'] ?? '',
      teacher: Teacher.fromJson(json['teacher'] ?? {}),
      classroom: json['classroom'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      dayOfWeek: json['dayOfWeek'] ?? '',
      lectureType: json['lectureType'] ?? 'Lecture',
      chapter: json['chapter'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      semester: json['semester'] ?? '',
      course: json['course'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'subject': subject,
      'teacher': teacher.toJson(),
      'classroom': classroom,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'lectureType': lectureType,
      'chapter': chapter,
      'description': description,
      'isActive': isActive,
      'semester': semester,
      'course': course,
    };
  }

  String get timeRange {
    final startStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }
}
