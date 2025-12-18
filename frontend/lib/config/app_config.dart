import 'package:flutter/foundation.dart';

class AppConfig {
  // Default values
  static const String _defaultApiUrl = 'http://localhost:5000/api';

  // Get API Base URL from environment or default
  static String get apiBaseUrl {
    const String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // If running in debug mode on Android emulator, use 10.0.2.2
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
       // Ideally we'd detect emulator, but for now let's stick to localhost or specific config
       // return 'http://10.0.2.2:5000/api'; 
    }

    return _defaultApiUrl;
  }
}
