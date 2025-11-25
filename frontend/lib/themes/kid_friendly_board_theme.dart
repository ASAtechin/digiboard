import 'package:flutter/material.dart';

/// Kid-Friendly Classroom Board Theme
/// Fun, colorful, and engaging design for students
class KidFriendlyBoardTheme {
  // Fun board colors with gradients
  static const Color boardPurple = Color(0xFF6B3FA0);    // Fun purple
  static const Color boardBlue = Color(0xFF2E5984);      // Friendly blue
  static const Color boardTeal = Color(0xFF1B8B8B);      // Cool teal
  
  // Vibrant chalk colors (more fun!)
  static const Color chalkyYellow = Color(0xFFFFD700);   // Bright yellow
  static const Color chalkyPink = Color(0xFFFF69B4);     // Hot pink
  static const Color chalkyGreen = Color(0xFF00FF7F);    // Spring green
  static const Color chalkyOrange = Color(0xFFFF8C00);   // Dark orange
  static const Color chalkyBlue = Color(0xFF87CEEB);     // Sky blue
  static const Color chalkyCyan = Color(0xFF00FFFF);     // Cyan
  static const Color chalkyRed = Color(0xFFFF4500);      // Orange red
  static const Color chalkWhite = Color(0xFFFAF9F6);
  
  // Fun text styles with playful fonts
  static const TextStyle funTitle = TextStyle(
    fontFamily: 'Arial',
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: chalkyYellow,
    letterSpacing: 2,
    height: 1.4,
    shadows: [
      Shadow(
        offset: Offset(4, 4),
        blurRadius: 8,
        color: Color.fromARGB(80, 0, 0, 0),
      ),
    ],
  );

  static const TextStyle funSubtitle = TextStyle(
    fontFamily: 'Arial',
    fontSize: 44,
    fontWeight: FontWeight.bold,
    color: chalkyPink,
    letterSpacing: 1.5,
    height: 1.4,
    shadows: [
      Shadow(
        offset: Offset(3, 3),
        blurRadius: 6,
        color: Color.fromARGB(60, 0, 0, 0),
      ),
    ],
  );

  static const TextStyle funBody = TextStyle(
    fontFamily: 'Arial',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: chalkWhite,
    letterSpacing: 0.8,
    height: 1.4,
  );

  static const TextStyle funLabel = TextStyle(
    fontFamily: 'Arial',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: chalkWhite,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Fun elements
  static const TextStyle funEmoji = TextStyle(
    fontSize: 48,
    fontFamily: 'Apple Color Emoji',
  );

  static const TextStyle largeEmoji = TextStyle(
    fontSize: 72,
    fontFamily: 'Apple Color Emoji',
  );

  // Fun decorative line
  static Widget funChalkLine({double width = double.infinity, double height = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chalkyYellow.withOpacity(0.3),
            chalkyPink.withOpacity(0.8),
            chalkyGreen.withOpacity(0.3),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  // Fun wavy line
  static Widget wavyChalkLine({double width = double.infinity}) {
    return SizedBox(
      width: width,
      height: 6,
      child: CustomPaint(
        painter: WavyLinePainter(),
      ),
    );
  }

  // Colorful box with rounded corners
  static Widget funBox(
    Widget child, {
    Color? gradientStart,
    Color? gradientEnd,
    double padding = 20,
    double borderRadius = 20,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientStart ?? chalkyYellow.withOpacity(0.1),
            gradientEnd ?? chalkyPink.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: chalkyYellow.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: child,
    );
  }

  // Star decoration
  static Widget starDecoration({double size = 32}) {
    return Text('⭐', style: TextStyle(fontSize: size));
  }

  // Fun bubble
  static Widget funBubble(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: (color ?? chalkyBlue).withOpacity(0.2),
        border: Border.all(
          color: color ?? chalkyBlue,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: funLabel.copyWith(
          color: color ?? chalkyBlue,
        ),
      ),
    );
  }

  // Fun sticker effect
  static Widget stickerDecoration(String emoji, {double rotation = 0.1}) {
    return Transform.rotate(
      angle: rotation,
      child: Text(emoji, style: largeEmoji),
    );
  }
}

/// Custom painter for wavy line
class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KidFriendlyBoardTheme.chalkyYellow.withOpacity(0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = 3.0;
    final waveWidth = 20.0;

    path.moveTo(0, size.height / 2);
    for (double i = 0; i < size.width; i += waveWidth) {
      path.quadraticBezierTo(
        i + waveWidth / 2,
        size.height / 2 - waveHeight,
        i + waveWidth,
        size.height / 2,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavyLinePainter oldDelegate) => false;
}

/// Kid-Friendly Colors Palette
class KidColors {
  static const Color primary = KidFriendlyBoardTheme.boardPurple;
  static const Color secondary = KidFriendlyBoardTheme.boardBlue;
  static const Color accent = KidFriendlyBoardTheme.chalkyPink;
  
  static const Color success = KidFriendlyBoardTheme.chalkyGreen;
  static const Color warning = KidFriendlyBoardTheme.chalkyOrange;
  static const Color info = KidFriendlyBoardTheme.chalkyBlue;
  static const Color error = KidFriendlyBoardTheme.chalkyRed;
  
  // Gradient colors for fun
  static const List<Color> rainbowGradient = [
    KidFriendlyBoardTheme.chalkyRed,
    KidFriendlyBoardTheme.chalkyOrange,
    KidFriendlyBoardTheme.chalkyYellow,
    KidFriendlyBoardTheme.chalkyGreen,
    KidFriendlyBoardTheme.chalkyBlue,
    KidFriendlyBoardTheme.chalkyPink,
  ];
}
