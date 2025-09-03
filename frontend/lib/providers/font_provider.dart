import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider with ChangeNotifier {
  double _fontScale = 1.0;
  static const String _fontScaleKey = 'font_scale';

  double get fontScale => _fontScale;

  // Base font sizes
  static const double baseHeaderFontSize = 20.0;
  static const double baseSubjectFontSize = 16.0;
  static const double baseBodyFontSize = 14.0;
  static const double baseSmallFontSize = 12.0;
  static const double baseTinyFontSize = 10.0;
  static const double baseTimeFontSize = 13.0;

  // Scaled font sizes
  double get headerFontSize => baseHeaderFontSize * _fontScale;
  double get subjectFontSize => baseSubjectFontSize * _fontScale;
  double get bodyFontSize => baseBodyFontSize * _fontScale;
  double get smallFontSize => baseSmallFontSize * _fontScale;
  double get tinyFontSize => baseTinyFontSize * _fontScale;
  double get timeFontSize => baseTimeFontSize * _fontScale;

  // Icon sizes that scale with font
  double get smallIconSize => 14.0 * _fontScale;
  double get mediumIconSize => 18.0 * _fontScale;
  double get largeIconSize => 22.0 * _fontScale;

  // Padding that scales with font
  double get basePadding => 12.0 * _fontScale;
  double get smallPadding => 8.0 * _fontScale;
  double get largePadding => 16.0 * _fontScale;

  FontProvider() {
    _loadFontScale();
  }

  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.8, 1.5); // Limit scale between 80% and 150%
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, _fontScale);
  }

  // Preset font sizes
  String get fontSizeLabel {
    if (_fontScale <= 0.85) return 'Small';
    if (_fontScale <= 1.0) return 'Normal';
    if (_fontScale <= 1.2) return 'Large';
    return 'Extra Large';
  }

  // Quick preset methods
  Future<void> setSmallFont() => setFontScale(0.8);
  Future<void> setNormalFont() => setFontScale(1.0);
  Future<void> setLargeFont() => setFontScale(1.2);
  Future<void> setExtraLargeFont() => setFontScale(1.5);
}
