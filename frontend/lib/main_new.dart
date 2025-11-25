import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'screens/timetable_carousel_screen_v3.dart' as timetable_screen;
import 'themes/design_system.dart';

// DigiBoard - Material Design 3 Educational Management System
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FontProvider(),
      child: const DigiBoard(),
    ),
  );
}

class DigiBoard extends StatelessWidget {
  const DigiBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiBoard - Classroom Display System',
      debugShowCheckedModeBanner: false,
      theme: buildMaterialDesign3Theme(),
      home: const timetable_screen.TimetableCarouselScreenV3(),
    );
  }
}
