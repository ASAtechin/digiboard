import 'package:flutter/material.dart';

/// Classroom Board Theme - Designs the dashboard to look like a distant classroom board
class ClassroomBoardTheme {
  // Board Colors
  static const Color boardGreen = Color(0xFF1B4D2E);    // Deep classroom green
  static const Color boardDarkGreen = Color(0xFF0F3620); // Darker green for depth
  static const Color chalkWhite = Color(0xFFFAF9F6);     // Chalk white
  static const Color chalkYellow = Color(0xFFFFE680);    // Chalk yellow
  static const Color chalkOrange = Color(0xFFFFB366);    // Chalk orange
  static const Color chalkPink = Color(0xFFFF99BB);      // Chalk pink
  static const Color chalkBlue = Color(0xFF99CCFF);      // Chalk blue

  // Board texture and styling
  static const double boardBorderRadius = 0;
  
  // Chalk text properties - LARGE for distant viewing
  static const TextStyle chalkTitle = TextStyle(
    fontFamily: 'Arial',
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: chalkWhite,
    letterSpacing: 2,
    height: 1.3,
    shadows: [
      Shadow(
        offset: Offset(3, 3),
        blurRadius: 6,
        color: Color.fromARGB(60, 0, 0, 0),
      ),
    ],
  );

  static const TextStyle chalkSubtitle = TextStyle(
    fontFamily: 'Arial',
    fontSize: 40,
    color: chalkYellow,
    letterSpacing: 1.2,
    fontWeight: FontWeight.bold,
    height: 1.3,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 4,
        color: Color.fromARGB(40, 0, 0, 0),
      ),
    ],
  );

  static const TextStyle chalkBody = TextStyle(
    fontFamily: 'Arial',
    fontSize: 28,
    color: chalkWhite,
    letterSpacing: 0.8,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle chalkLabel = TextStyle(
    fontFamily: 'Arial',
    fontSize: 20,
    color: chalkWhite,
    letterSpacing: 0.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
  
  // Extra large for emphasis
  static const TextStyle chalkDisplayLarge = TextStyle(
    fontFamily: 'Arial',
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: chalkYellow,
    letterSpacing: 2.5,
    height: 1.4,
    shadows: [
      Shadow(
        offset: Offset(4, 4),
        blurRadius: 8,
        color: Color.fromARGB(80, 0, 0, 0),
      ),
    ],
  );

  // Shadow effects to simulate distance
  static List<BoxShadow> distantShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 15),
    ),
  ];

  // Decorative line/chalk line - THICKER for visibility
  static Widget chalkLine({double width = double.infinity, double height = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chalkWhite.withOpacity(0.2),
            chalkWhite.withOpacity(0.9),
            chalkWhite.withOpacity(0.2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  // Board background with texture
  static BoxDecoration boardDecoration({double blur = 0}) {
    return BoxDecoration(
      color: boardGreen,
      image: DecorationImage(
        image: const AssetImage('assets/board_texture.png'),
        fit: BoxFit.cover,
        opacity: 0.05,
      ),
      boxShadow: distantShadow,
    );
  }

  // Erased chalk effect container
  static Widget erasedSection(
    Widget child, {
    double padding = 12,
    bool hasBorder = false,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: boardGreen.withOpacity(0.5),
        border: hasBorder
            ? Border.all(
                color: chalkWhite.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              )
            : null,
      ),
      child: child,
    );
  }

  // Chalk drawing effect border
  static BoxDecoration chalkBorderDecoration({
    Color borderColor = chalkWhite,
    double borderWidth = 2,
    bool dashed = false,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor.withOpacity(0.6),
        width: borderWidth,
        style: dashed ? BorderStyle.solid : BorderStyle.solid,
      ),
    );
  }
}

/// Classroom Board Color Palette
class ClassroomColors {
  // Main board
  static const Color board = ClassroomBoardTheme.boardGreen;
  
  // Chalk colors (content)
  static const Color nextLectureTitle = ClassroomBoardTheme.chalkYellow;
  static const Color teacherInfo = ClassroomBoardTheme.chalkBlue;
  static const Color scheduleInfo = ClassroomBoardTheme.chalkPink;
  static const Color defaultText = ClassroomBoardTheme.chalkWhite;
  
  // Status indicators
  static const Color active = ClassroomBoardTheme.chalkOrange;
  static const Color upcoming = ClassroomBoardTheme.chalkYellow;
  static const Color completed = Color(0xFF99DD99);
}

/// Board-style text theme
class ClassroomTextTheme {
  static final TextTheme textTheme = TextTheme(
    displayLarge: ClassroomBoardTheme.chalkTitle,
    displayMedium: ClassroomBoardTheme.chalkTitle.copyWith(fontSize: 24),
    displaySmall: ClassroomBoardTheme.chalkTitle.copyWith(fontSize: 20),
    headlineMedium: ClassroomBoardTheme.chalkSubtitle,
    headlineSmall: ClassroomBoardTheme.chalkSubtitle.copyWith(fontSize: 16),
    titleLarge: ClassroomBoardTheme.chalkBody.copyWith(fontWeight: FontWeight.bold),
    bodyLarge: ClassroomBoardTheme.chalkBody,
    bodyMedium: ClassroomBoardTheme.chalkLabel,
    labelLarge: ClassroomBoardTheme.chalkLabel.copyWith(fontWeight: FontWeight.bold),
  );
}
