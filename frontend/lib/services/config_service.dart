import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static String _apiBaseUrl = 'http://localhost:5000/api'; // Default fallback

  static String get apiBaseUrl => _apiBaseUrl;

  static Future<void> loadConfig() async {
    print('ConfigService: Loading config...');
    try {
      final String response = await rootBundle.loadString('assets/config.json');
      print('ConfigService: Config file loaded. Content: $response');
      final Map<String, dynamic> data = json.decode(response);
      
      if (data.containsKey('apiBaseUrl')) {
        _apiBaseUrl = data['apiBaseUrl'];
        print('ConfigService: API URL set to $_apiBaseUrl');
      }
    } catch (e) {
      print('ConfigService: Error loading config: $e');
      print('ConfigService: Using default API URL: $_apiBaseUrl');
    }
  }
}
