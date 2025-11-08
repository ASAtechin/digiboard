import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'screens/home_screen.dart';

// Delhi Public School DigiBoard - Indian School Management System
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
      title: 'Delhi Public School DigiBoard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'System',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 100, // Taller app bar for TV
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
