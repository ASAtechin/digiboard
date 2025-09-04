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
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
