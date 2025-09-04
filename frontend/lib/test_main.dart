import 'package:flutter/material.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      home: const Scaffold(
        body: Center(
          child: Text(
            'Hello! This is a test Flutter web app.',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
