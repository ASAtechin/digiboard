import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lecture.dart';
import '../models/teacher.dart';

class ApiService {
  static const String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5000/api',
  );
  
  // Schedule endpoints
  static Future<Lecture?> getNextLecture() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/next'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Lecture.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No upcoming lectures
      } else {
        throw Exception('Failed to load next lecture: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<List<Lecture>> getTodaySchedule() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/today'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Lecture.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load today\'s schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Map<String, List<Lecture>>> getWeeklySchedule() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/week'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        Map<String, List<Lecture>> weeklySchedule = {};
        
        data.forEach((day, lectures) {
          weeklySchedule[day] = (lectures as List)
              .map((json) => Lecture.fromJson(json))
              .toList();
        });
        
        return weeklySchedule;
      } else {
        throw Exception('Failed to load weekly schedule: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Lecture endpoints
  static Future<List<Lecture>> getAllLectures() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lectures'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Lecture.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lectures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Lecture?> getLectureById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lectures/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Lecture.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load lecture: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Teacher endpoints
  static Future<List<Teacher>> getAllTeachers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teachers'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Teacher.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load teachers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Teacher?> getTeacherById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teachers/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Teacher.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load teacher: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Health check
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
