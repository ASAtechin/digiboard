import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';

class ConfigService {
  static String _apiBaseUrl = 'http://localhost:5000/api'; // Default fallback
  // Shiksha Tantra platform API, e.g. https://api.example.com/v1. Empty: use the original backend.
  static String _platformBaseUrl = '';

  /// Set at build time for hosted and installed builds:
  /// flutter build apk --dart-define=PLATFORM_BASE_URL=https://.../v1
  static const String _builtInPlatformUrl = String.fromEnvironment('PLATFORM_BASE_URL');

  static String get apiBaseUrl => _apiBaseUrl;
  static String get platformBaseUrl => _platformBaseUrl;

  static Future<void> loadConfig() async {
    debugPrint('ConfigService: Loading config...');
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      debugPrint('ConfigService: Config file loaded. Content: $response');
      final Map<String, dynamic> data = json.decode(response);
      
      if (data.containsKey('apiBaseUrl')) {
        _apiBaseUrl = data['apiBaseUrl'];
        debugPrint('ConfigService: API URL set to $_apiBaseUrl');
      }
      final platform = data['platformBaseUrl'];
      if (platform is String && platform.isNotEmpty) {
        _platformBaseUrl = platform;
        debugPrint('ConfigService: platform URL set to $_platformBaseUrl');
      }
    } catch (e) {
      debugPrint('ConfigService: Error loading config: $e');
      debugPrint('ConfigService: Using default API URL: $_apiBaseUrl');
    }
    if (_builtInPlatformUrl.isNotEmpty) {
      _platformBaseUrl = _builtInPlatformUrl;
      debugPrint('ConfigService: platform URL set at build time to $_platformBaseUrl');
    }
  }
}
