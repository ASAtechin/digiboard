import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lecture.dart';
import '../models/teacher.dart';
import '../services/config_service.dart';

class ApiService {
  // Base URL from Runtime Config
  static String get baseUrl => ConfigService.apiBaseUrl;
  
  // Schedule endpoints
  static Future<Lecture?> getNextLecture() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/next'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
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
      if (kDebugMode) print('Error in getNextLecture: $e');
      throw Exception('Network error: $e');
    }
  }
  
  static Future<List<Lecture>> getTodaySchedule() async {
    if (kDebugMode) {
      print('--- DigiBoard API: Fetching Today Schedule ---');
      print('URL: $baseUrl/schedule/today');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule/today'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (kDebugMode) {
        print('--- DigiBoard API: Response Received ---');
        print('Status Code: ${response.statusCode}');
        print('Body Length: ${response.body.length}');
        if (response.body.length < 500) { // Print small bodies
          print('Body: ${response.body}');
        } else {
          print('Body (preview): ${response.body.substring(0, 250)}...');
        }
        print('------------------------------------');
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final lectures = data.map((json) => Lecture.fromJson(json)).toList();
        
        if (kDebugMode) {
          print('--- DigiBoard API: Parsing Success ---');
          print('Parsed ${lectures.length} lectures for today.');
          print('------------------------------------');
        }
        
        return lectures;
      } else {
        if (kDebugMode) {
          print('--- DigiBoard API: ERROR ---');
          print('Failed to load today\'s schedule with status code: ${response.statusCode}');
          print('--------------------------');
        }
        throw Exception('Failed to load today\'s schedule: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('--- DigiBoard API: NETWORK/PARSING ERROR ---');
        print('Error in getTodaySchedule: $e');
        print('Stacktrace: $stacktrace');
        print('------------------------------------------');
      }
      throw Exception('Network error or parsing failed: $e');
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
  
  // Weather API
  static Future<Map<String, dynamic>> getCurrentWeather({double? lat, double? long}) async {
    try {
      // Using Open-Meteo API (Free, no key required)
      // Defaulting to Chennai coordinates (13.0827, 80.2707) if not provided
      final latitude = lat ?? 13.0827;
      final longitude = long ?? 80.2707;

      final response = await http.get(
        Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching weather: $e');
      return {};
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
  
  // Notification API
  // Throws when the alert status cannot be confirmed. Callers must treat that as
  // "status unknown", never as "no alert".
  static Future<Map<String, dynamic>> getNotification() async {
    final response = await http
        .get(Uri.parse('$baseUrl/notification'))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Alert status unavailable (HTTP ${response.statusCode})');
    }
    final body = json.decode(response.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Alert status response was not understood');
    }
    return body;
  }
  
  // Settings API
  static Future<Map<String, dynamic>?> getSchoolLocation() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/school_location'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['value'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error fetching school location: $e');
      return null;
    }
  }
}
