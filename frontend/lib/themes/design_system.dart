import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shiksha Tantra design language "Forest and Paper", in its signage form:
/// "Forest night". A dark forest background, ivory text, gold accents and
/// serif headings, readable from 3 m. The colours are the dark column of
/// docs/design/2026-11-design-language.md section 2 (same names as the
/// admin's CSS variables), plus the two emergency colours, which keep their
/// meaning on every screen: red for an emergency, amber for "cannot confirm".
///
/// Fonts are bundled (assets/fonts, SIL OFL): the web build runs without a
/// font CDN and kiosks may be offline.
class DesignSystem {
  // ===========================================================================
  // COLOUR TOKENS (dark theme)
  // ===========================================================================

  /// The screen's background: forest night.
  static const Color background = Color(0xFF0F1914);

  /// Cards and panels, a shade lighter.
  static const Color card = Color(0xFF15211B);

  /// Bars that sit over other content (notices, banners).
  static const Color popover = Color(0xFF1A271F);

  /// Text: ivory.
  static const Color ink = Color(0xFFEDEADF);

  /// Quiet fills inside cards (tiles, tracks).
  static const Color muted = Color(0xFF1C2A22);

  /// Secondary text. At least 6.9:1 on every surface above.
  static const Color mutedForeground = Color(0xFFA7B3AA);

  /// Hairlines.
  static const Color border = Color(0xFF2A3A31);
  static const Color borderStrong = Color(0xFF3B4D43);

  /// Control edges.
  static const Color input = Color(0xFF738279);

  /// Gold, dark theme: highlights, eyebrows and the active marker.
  static const Color primary = Color(0xFFE5C46F);
  static const Color primaryForeground = Color(0xFF14201A);
  static const Color accent = Color(0xFF22332A);
  static const Color accentForeground = Color(0xFFF0DDA6);

  /// Eyebrow labels (the same gold in the dark theme).
  static const Color ochre = Color(0xFFE5C46F);

  /// Decoration only: the rule under a title, the active-item marker.
  static const Color gold = Color(0xFFEFD080);

  static const Color destructive = Color(0xFFF08B7C);
  static const Color destructiveForeground = Color(0xFF1A0E0B);
  static const Color dangerSoft = Color(0xFF3A1D18);
  static const Color success = Color(0xFF7FCB9C);
  static const Color successSoft = Color(0xFF16301F);
  static const Color warning = Color(0xFFF0C163);
  static const Color warningSoft = Color(0xFF33290F);
  static const Color info = Color(0xFF88C4E3);
  static const Color infoSoft = Color(0xFF12303F);

  // ===========================================================================
  // EMERGENCY COLOURS: kept as they were, so a drill looks like a drill
  // ===========================================================================

  /// A drill or alert of severity "emergency": red with white text (6.6:1).
  static const Color emergency = Color(0xFFB71C1C);
  static const Color onEmergency = Color(0xFFFFFFFF);

  /// "Alert status unavailable", "Not updated since" and a warning-level
  /// drill: amber with black text (10.3:1).
  static const Color alertAmber = Color(0xFFFFA000);
  static const Color onAlertAmber = Color(0xFF000000);

  /// The clock of a screen that is "almost nothing" outside its hours:
  /// deliberately quiet, still 4.7:1 on the background.
  static const Color dimText = Color(0xFF78877E);

  // ===========================================================================
  // TYPE
  // ===========================================================================
  // Headings and headline figures are serif (Noto Serif; Noto Serif Display for
  // the largest figures). Everything else is Noto Sans. Each face lists its
  // Devanagari companion so Hindi gets a matching face, then the small face
  // with the arrows and minus sign the Latin faces lack.
  static const String serifFamily = 'Noto Serif';
  static const String displayFamily = 'Noto Serif Display';
  static const String sansFamily = 'Noto Sans';

  static const List<String> serifFallback = [
    'Noto Serif Devanagari',
    'Noto Sans Devanagari',
    'Noto Sans Math',
    'Noto Sans',
  ];
  static const List<String> sansFallback = [
    'Noto Sans Devanagari',
    'Noto Sans Math',
    'Noto Serif',
  ];

  /// Lining, tabular figures for clocks, times and codes.
  static const List<FontFeature> figures = [
    FontFeature.liningFigures(),
    FontFeature.tabularFigures(),
  ];

  /// Body and working text: Noto Sans.
  static TextStyle sans({
    double size = 24,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double? height,
    double? letterSpacing,
  }) => TextStyle(
    fontFamily: sansFamily,
    fontFamilyFallback: sansFallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  /// Headings and headline figures: Noto Serif, bold.
  static TextStyle serif({
    double size = 28,
    FontWeight weight = FontWeight.w700,
    Color color = ink,
    double? height,
    double? letterSpacing,
    bool figures = false,
  }) => TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: serifFallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    fontFeatures: figures ? DesignSystem.figures : null,
  );

  /// The largest figures (clocks, the pairing code): Noto Serif Display, regular.
  static TextStyle display({
    double size = 96,
    Color color = ink,
    double? height,
    double? letterSpacing,
    bool figures = true,
  }) => TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: serifFallback,
    fontSize: size,
    fontWeight: FontWeight.w400,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    fontFeatures: figures ? DesignSystem.figures : null,
  );

  /// Eyebrow: small caps-style label in gold, letter-spaced (+0.08em). The
  /// caller writes the text in capitals.
  static TextStyle eyebrow({double size = 18, Color color = ochre}) => sans(
    size: size,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: size * 0.08,
    height: 1.2,
  );

  // The signage scale (sizes for far viewing; unchanged from before, now in
  // the new faces).
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: serifFallback,
    fontSize: 96,
    fontWeight: FontWeight.w400,
    height: 1.1,
    letterSpacing: -1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: serifFallback,
    fontSize: 72,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: serifFallback,
    fontSize: 56,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: serifFallback,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: serifFallback,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: serifFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sansFamily,
    fontFamilyFallback: sansFallback,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFamily,
    fontFamilyFallback: sansFallback,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFamily,
    fontFamilyFallback: sansFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  // Use case, for reference (viewing distance on a 1080p screen):
  // - displayLarge (96):   the clock outside school hours
  // - displayMedium (72):  lecture subject
  // - displaySmall (56):   lesson times
  // - headlineLarge (48):  screen titles
  // - headlineMedium (40): secondary titles
  // - headlineSmall (32):  card titles
  // - bodyLarge (24):      notices, working text
  // - bodyMedium (20):     supporting lines
  // - bodySmall (16):      status labels

  // ===========================================================================
  // SPACING (4 px grid, with the signage steps)
  // ===========================================================================
  static const double spacing1 = 8;
  static const double spacing2 = 16;
  static const double spacing3 = 24;
  static const double spacing4 = 32;
  static const double spacing5 = 40;
  static const double spacing6 = 48;

  static const double paddingSmall = spacing2;
  static const double paddingMedium = spacing3;
  static const double paddingLarge = spacing4;
  static const double paddingXLarge = spacing6;

  static const double gapSmall = spacing2;
  static const double gapMedium = spacing3;
  static const double gapLarge = spacing4;

  // ===========================================================================
  // SHAPE: classic rules (hairlines; 4 / 6 / 10 px radii; pills only for badges)
  // ===========================================================================
  static const double radiusSmall = 4;
  static const double radiusControl = 6;
  static const double radiusCard = 10;
  static const double hairline = 1;

  static const double cornerRadiusSmall = radiusSmall;
  static const double cornerRadiusMedium = radiusControl;
  static const double cornerRadiusLarge = radiusCard;
  static const double cornerRadiusXLarge = radiusCard;

  /// A card: the card colour with a hairline border, 10 px radius. No shadow
  /// (paper, not glass).
  static BoxDecoration cardDecoration({
    Color color = card,
    Color borderColor = border,
    double borderWidth = hairline,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radiusCard),
    border: Border.all(color: borderColor, width: borderWidth),
  );

  /// A gold rule under a screen title (2 px).
  static const double ruleWidth = 64;
  static const double ruleHeight = 2;

  /// The quietest a lesson card beside the current one may be drawn. Its text
  /// still passes 4.5:1 at this opacity (see test/design_contrast_test.dart).
  static const double fadedOpacity = 0.72;

  // ===========================================================================
  // MOTION: short, ease-out, off under reduced motion
  // ===========================================================================
  static const Duration animationQuick = Duration(milliseconds: 200);
  static const Duration animationDefault = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);

  static const Curve curveDefault = Curves.easeOut;
  static const Curve curveEntrance = Curves.easeOut;
  static const Curve curveExit = Curves.easeIn;

  // ===========================================================================
  // ICON SIZES, BREAKPOINTS, TOUCH TARGETS
  // ===========================================================================
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXLarge = 48;

  static const double breakpointMobileSmall = 360;
  static const double breakpointMobileLarge = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
  static const double breakpointDesktopLarge = 1440;
  static const double breakpointCinema = 1600;

  static const double minTouchTarget = 48;
  static const double largeTouchTarget = 56;

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  /// How much to scale the signage layout (drawn for a 1920 px wide screen) on
  /// a narrower or wider one, so a 1280 x 720 screen is the same layout smaller.
  static double scaleFor(double screenWidth) =>
      (screenWidth / 1920).clamp(0.6, 1.0).toDouble();

  /// WCAG relative luminance.
  static double luminance(Color color) {
    double linear(double c) =>
        c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * linear(color.r) +
        0.7152 * linear(color.g) +
        0.0722 * linear(color.b);
  }

  /// WCAG contrast ratio between two opaque colours, 1 to 21.
  static double contrastRatio(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Text needs 4.5:1 (WCAG AA); pass 3 for large text and graphics.
  static bool isContrastCompliant(
    Color foreground,
    Color background, {
    double minimum = 4.5,
  }) => contrastRatio(foreground, background) >= minimum;

  /// The school's own colour as a guest on the dark screen: used as it is when
  /// it shows up against the background (3:1), lightened towards ivory until
  /// it does. Null when the school has not set one.
  static Color? guest(Color? school, {Color against = background}) {
    if (school == null) return null;
    final opaque = school.withValues(alpha: 1);
    for (var step = 0; step <= 10; step++) {
      final candidate = Color.lerp(opaque, ink, step / 10)!;
      if (contrastRatio(candidate, against) >= 3) return candidate;
    }
    return ink;
  }

  /// Get TextStyle based on viewing distance
  /// Useful for dynamic sizing based on screen size
  static TextStyle getDisplayText({
    required double screenHeight,
    required double screenWidth,
  }) {
    // For large displays (cinema mode), use larger sizes
    if (screenWidth >= breakpointCinema) {
      return displayLarge.copyWith(fontSize: 128);
    }
    // For desktop large
    if (screenWidth >= breakpointDesktopLarge) {
      return displayLarge;
    }
    // For desktop
    if (screenWidth >= breakpointDesktop) {
      return displayMedium;
    }
    // For tablet and smaller
    return displaySmall;
  }

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(
    double baseSize, {
    required double screenWidth,
    double mobileScale = 0.9,
    double tabletScale = 1.0,
    double desktopScale = 1.1,
    double cinemaScale = 1.5,
  }) {
    if (screenWidth >= breakpointCinema) {
      return baseSize * cinemaScale;
    }
    if (screenWidth >= breakpointDesktopLarge) {
      return baseSize * desktopScale;
    }
    if (screenWidth >= breakpointTablet) {
      return baseSize * tabletScale;
    }
    return baseSize * mobileScale;
  }

  /// Get responsive padding based on screen width
  static double getResponsivePadding(
    double baseValue, {
    required double screenWidth,
  }) {
    if (screenWidth >= breakpointCinema) {
      return baseValue * 1.5;
    }
    if (screenWidth >= breakpointDesktopLarge) {
      return baseValue * 1.2;
    }
    if (screenWidth >= breakpointTablet) {
      return baseValue;
    }
    return baseValue * 0.8;
  }
}

/// ===========================================================================
/// THEME DATA BUILDER (For ThemeData)
/// ===========================================================================
ThemeData buildMaterialDesign3Theme() {
  const scheme = ColorScheme.dark(
    primary: DesignSystem.primary,
    onPrimary: DesignSystem.primaryForeground,
    secondary: DesignSystem.gold,
    onSecondary: DesignSystem.primaryForeground,
    tertiary: DesignSystem.info,
    onTertiary: DesignSystem.primaryForeground,
    error: DesignSystem.destructive,
    onError: DesignSystem.destructiveForeground,
    surface: DesignSystem.card,
    onSurface: DesignSystem.ink,
    onSurfaceVariant: DesignSystem.mutedForeground,
    surfaceContainerHighest: DesignSystem.muted,
    surfaceContainerHigh: DesignSystem.popover,
    outline: DesignSystem.input,
    outlineVariant: DesignSystem.border,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    primaryColor: DesignSystem.primary,
    scaffoldBackgroundColor: DesignSystem.background,
    canvasColor: DesignSystem.background,
    dividerColor: DesignSystem.border,
    fontFamily: DesignSystem.sansFamily,
    fontFamilyFallback: DesignSystem.sansFallback,
    textTheme: TextTheme(
      displayLarge: DesignSystem.displayLarge.copyWith(color: DesignSystem.ink),
      displayMedium: DesignSystem.displayMedium.copyWith(color: DesignSystem.ink),
      displaySmall: DesignSystem.displaySmall.copyWith(color: DesignSystem.ink),
      headlineLarge: DesignSystem.headlineLarge.copyWith(color: DesignSystem.ink),
      headlineMedium: DesignSystem.headlineMedium.copyWith(color: DesignSystem.ink),
      headlineSmall: DesignSystem.headlineSmall.copyWith(color: DesignSystem.ink),
      titleLarge: DesignSystem.headlineSmall.copyWith(fontSize: 28, color: DesignSystem.ink),
      titleMedium: DesignSystem.headlineSmall.copyWith(fontSize: 22, color: DesignSystem.ink),
      titleSmall: DesignSystem.headlineSmall.copyWith(fontSize: 18, color: DesignSystem.ink),
      bodyLarge: DesignSystem.bodyLarge.copyWith(color: DesignSystem.ink),
      bodyMedium: DesignSystem.bodyMedium.copyWith(color: DesignSystem.ink),
      bodySmall: DesignSystem.bodySmall.copyWith(color: DesignSystem.mutedForeground),
      labelLarge: DesignSystem.bodySmall.copyWith(fontWeight: FontWeight.w600, color: DesignSystem.ink),
      labelMedium: DesignSystem.bodySmall.copyWith(fontWeight: FontWeight.w600, color: DesignSystem.mutedForeground),
      labelSmall: DesignSystem.bodySmall.copyWith(fontSize: 14, color: DesignSystem.mutedForeground),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystem.primary,
        foregroundColor: DesignSystem.primaryForeground,
        textStyle: DesignSystem.sans(size: 20, weight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusControl),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignSystem.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusControl),
        borderSide: const BorderSide(color: DesignSystem.input),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusControl),
        borderSide: const BorderSide(color: DesignSystem.input),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusControl),
        borderSide: const BorderSide(color: DesignSystem.ochre, width: 2),
      ),
    ),
  );
}
