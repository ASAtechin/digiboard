import 'package:flutter/material.dart';

/// Material Design 3 Professional Educational Theme
/// Soft, refined colors with Material Design principles
/// Designed for modern educational institutions
class ProfessionalTheme {
  // Material Design 3 - Primary Color Palette (Soft)
  static const Color primary = Color(0xFF5B6B70);           // Soft slate blue
  static const Color onPrimary = Color(0xFFFFFFFF);         // Pure white
  static const Color primaryContainer = Color(0xFFDEE5EA);  // Very light blue-gray
  static const Color onPrimaryContainer = Color(0xFF192028); // Dark charcoal

  // Material Design 3 - Secondary Color Palette (Soft Teal)
  static const Color secondary = Color(0xFF4F6F74);         // Soft teal
  static const Color onSecondary = Color(0xFFFFFFFF);       // Pure white
  static const Color secondaryContainer = Color(0xFFD1EAF0); // Very light teal
  static const Color onSecondaryContainer = Color(0xFF071D23); // Dark teal

  // Material Design 3 - Tertiary Color Palette (Soft Purple)
  static const Color tertiary = Color(0xFF6B5B7E);          // Soft purple
  static const Color onTertiary = Color(0xFFFFFFFF);        // Pure white
  static const Color tertiaryContainer = Color(0xFFEFDEFF); // Very light purple
  static const Color onTertiaryContainer = Color(0xFF251A35); // Dark purple

  // Material Design 3 - Surface Colors
  static const Color surface = Color(0xFFFBF8F3);           // Very soft warm white
  static const Color onSurface = Color(0xFF1C1B1F);         // Almost black
  static const Color surfaceDim = Color(0xFFDDD9D0);        // Soft gray
  static const Color surfaceBright = Color(0xFFFFFBFE);     // Bright white
  
  // Material Design 3 - Container Colors
  static const Color background = Color(0xFFFBF8F3);        // Soft warm background
  static const Color onBackground = Color(0xFF1C1B1F);      // Text color

  // Material Design 3 - Error Colors (Soft)
  static const Color error = Color(0xFFB3261E);             // Soft red
  static const Color onError = Color(0xFFFFFFFF);           // White
  static const Color errorContainer = Color(0xFFF9DEDC);    // Very light red
  static const Color onErrorContainer = Color(0xFF410E0B);  // Dark red

  // Material Design 3 - Outline & Shadows
  static const Color outline = Color(0xFF79747E);           // Medium gray
  static const Color outlineVariant = Color(0xFFCAC7D0);    // Light gray
  static const Color shadow = Color(0xFF000000);            // Black (for shadows)
  static const Color scrim = Color(0xFF000000);             // Black (for dimming)

  // Additional Semantic Colors (Soft)
  static const Color successGreen = Color(0xFF4CAF50);      // Soft green
  static const Color warningOrange = Color(0xFFFF9800);     // Soft orange
  static const Color infoBlue = Color(0xFF2196F3);          // Soft blue
  static const Color indigoAccent = Color(0xFF5C6BC0);      // Soft indigo

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F);       // Primary text
  static const Color textSecondary = Color(0xFF49454F);     // Secondary text
  static const Color textTertiary = Color(0xFF79747E);      // Tertiary text
  static const Color textHint = Color(0xFFCAC7D0);          // Hint text

  // Gradient Palettes (Material Design 3 inspired)
  static const List<Color> primaryGradient = [
    Color(0xFF5B6B70),  // Primary
    Color(0xFF4F6F74),  // Secondary
  ];
  
  static const List<Color> surfaceGradient = [
    Color(0xFFFBF8F3),  // Background
    Color(0xFFF1EFEB),  // Slightly darker
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF2196F3),  // Info Blue
    Color(0xFF5C6BC0),  // Indigo
  ];

  // Text Styles (Material Design 3)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    letterSpacing: 0.5,
  );

  // Shadow Styles (Material Design 3 - Soft)
  static const List<BoxShadow> elevationLevel0 = [];

  static const List<BoxShadow> elevationLevel1 = [
    BoxShadow(
      color: Color(0x0D000000),  // 5% black
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevationLevel2 = [
    BoxShadow(
      color: Color(0x0D000000),  // 5% black
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A000000),  // 3% black
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevationLevel3 = [
    BoxShadow(
      color: Color(0x0A000000),  // 3% black
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
    BoxShadow(
      color: Color(0x0A000000),  // 3% black
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevationLevel4 = [
    BoxShadow(
      color: Color(0x0A000000),  // 3% black
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),  // 3% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevationLevel5 = [
    BoxShadow(
      color: Color(0x0A000000),  // 3% black
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),  // 3% black
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];

  // Spacing System (Material Design 3)
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing7 = 28.0;
  static const double spacing8 = 32.0;

  // Corner Radius (Material Design 3)
  static const double cornerExtraSmall = 4.0;
  static const double cornerSmall = 8.0;
  static const double cornerMedium = 12.0;
  static const double cornerLarge = 16.0;
  static const double cornerExtraLarge = 28.0;

  // Icon Sizes
  static const double iconSmall = 18.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXL = 48.0;

  // Helper Methods
  static Color getSubjectColor(String subject) {
    final lower = subject.toLowerCase();
    
    if (lower.contains('math') || lower.contains('calculus') || lower.contains('algebra')) {
      return indigoAccent;
    } else if (lower.contains('computer') || lower.contains('programming') || lower.contains('software')) {
      return infoBlue;
    } else if (lower.contains('physics') || lower.contains('chemistry') || lower.contains('biology')) {
      return successGreen;
    } else if (lower.contains('history') || lower.contains('literature') || lower.contains('english')) {
      return warningOrange;
    } else if (lower.contains('language')) {
      return tertiary;
    }
    return secondary;
  }

  static Color getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('happening') || lower.contains('ongoing') || lower.contains('progress')) {
      return successGreen;
    } else if (lower.contains('next') || lower.contains('upcoming') || lower.contains('starting')) {
      return infoBlue;
    } else if (lower.contains('completed') || lower.contains('past')) {
      return textTertiary;
    }
    return textSecondary;
  }

  // Material Card Decoration
  static BoxDecoration materialCardDecoration({
    Color bgColor = surface,
    List<BoxShadow>? shadow,
    double radius = cornerLarge,
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ?? elevationLevel1,
    );
  }

  // Material Gradient Card
  static BoxDecoration materialGradientCard({
    List<Color>? colors,
    double radius = cornerLarge,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ?? elevationLevel2,
    );
  }

  // Material Divider
  static Widget materialDivider({
    double height = 1.0,
    double thickness = 1.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: outlineVariant,
        borderRadius: BorderRadius.circular(thickness / 2),
      ),
    );
  }

  // Material Filled Button Style
  static ButtonStyle materialFilledButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primary,
      foregroundColor: foregroundColor ?? onPrimary,
      elevation: 2,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing4,
        vertical: spacing3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerSmall),
      ),
    );
  }

  // Material Outlined Button Style
  static ButtonStyle materialOutlinedButtonStyle({
    Color? borderColor,
    Color? foregroundColor,
  }) {
    return OutlinedButton.styleFrom(
      side: BorderSide(
        color: borderColor ?? outline,
        width: 1.0,
      ),
      foregroundColor: foregroundColor ?? primary,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing4,
        vertical: spacing3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerSmall),
      ),
    );
  }

  // Chip Decoration
  static InputDecoration chipInputDecoration({
    String? label,
    Color? backgroundColor,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: backgroundColor ?? primaryContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerSmall),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing3,
        vertical: spacing2,
      ),
    );
  }
}
