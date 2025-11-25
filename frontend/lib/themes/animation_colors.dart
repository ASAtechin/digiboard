import 'package:flutter/material.dart';

/// Animation Color Schemes
/// 
/// Provides predefined color palettes for the AnimatedBorderContainer widget
/// and other animated components in the DigiBoard application.
/// 
/// Each color scheme is designed to create a specific visual atmosphere:
/// - Vibrant: Eye-catching, modern, energetic
/// - Warm: Friendly, welcoming, warm-toned
/// - Cool: Professional, calm, cool-toned
/// - Rainbow: Playful, diverse, full spectrum
class AnimationColorSchemes {
  /// Vibrant pulse scheme - Modern, eye-catching colors
  /// Colors: Blue → Purple → Pink → Cyan
  /// Best for: Attention-grabbing animations, status indicators
  static const List<Color> vibrantPulse = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
  ];

  /// Warm pulse scheme - Friendly, warm-toned colors
  /// Colors: Amber → Orange → Red → Violet
  /// Best for: Notifications, alerts, important updates
  static const List<Color> warmPulse = [
    Color(0xFFF59E0B), // Amber
    Color(0xFFF97316), // Orange
    Color(0xFFDC2626), // Red
    Color(0xFF9333EA), // Violet
  ];

  /// Cool pulse scheme - Professional, calm colors
  /// Colors: Cyan → Blue → Indigo → Purple
  /// Best for: Professional themes, calm interactions
  static const List<Color> coolPulse = [
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
  ];

  /// Rainbow pulse scheme - Full spectrum, playful
  /// Colors: Red → Orange → Yellow → Green → Blue → Purple
  /// Best for: Fun animations, kid-friendly interfaces
  static const List<Color> rainbow = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
  ];

  /// Monochrome blue scheme - Professional single-color variations
  /// Best for: Subtle animations, professional apps
  static const List<Color> monochromeBlue = [
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFF0284C7), // Blue
    Color(0xFF1E40AF), // Dark Blue
    Color(0xFF1E3A8A), // Navy Blue
  ];

  /// Monochrome green scheme - Nature, growth theme
  /// Best for: Success states, eco-friendly apps
  static const List<Color> monochromeGreen = [
    Color(0xFF10B981), // Emerald
    Color(0xFF059669), // Green
    Color(0xFF047857), // Dark Green
    Color(0xFF065F46), // Forest Green
  ];

  /// Dual color pulse - Simple two-color alternation
  /// Best for: Minimalist designs, focused attention
  static const List<Color> dualBluePurple = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
  ];

  /// Dual color pulse - Complementary colors
  static const List<Color> dualOrangeBlue = [
    Color(0xFFF97316), // Orange
    Color(0xFF3B82F6), // Blue
  ];

  /// Get a color scheme by name
  /// Returns vibrantPulse if name not found
  static List<Color> getByName(String name) {
    switch (name.toLowerCase()) {
      case 'vibrant':
      case 'vibrantpulse':
        return vibrantPulse;
      case 'warm':
      case 'warmpulse':
        return warmPulse;
      case 'cool':
      case 'coolpulse':
        return coolPulse;
      case 'rainbow':
        return rainbow;
      case 'monotone':
      case 'monochromeblue':
        return monochromeBlue;
      case 'green':
      case 'monochromegreen':
        return monochromeGreen;
      case 'dual':
      case 'dualbluepurple':
        return dualBluePurple;
      case 'dualorangeblue':
        return dualOrangeBlue;
      default:
        return vibrantPulse;
    }
  }

  /// Get all available color scheme names
  static List<String> getAllNames() {
    return [
      'vibrant',
      'warm',
      'cool',
      'rainbow',
      'monochromeBlue',
      'monochromeGreen',
      'dualBluePurple',
      'dualOrangeBlue',
    ];
  }
}

/// Predefined animation durations for consistent pacing
class AnimationDurations {
  /// Fast pulse - 2 seconds for quick, energetic animations
  static const Duration fast = Duration(seconds: 2);

  /// Normal pulse - 3 seconds (default, balanced)
  static const Duration normal = Duration(seconds: 3);

  /// Slow pulse - 4 seconds for subtle, calm animations
  static const Duration slow = Duration(seconds: 4);

  /// Very slow pulse - 5 seconds for gentle, barely noticeable animations
  static const Duration verySlow = Duration(seconds: 5);
}
