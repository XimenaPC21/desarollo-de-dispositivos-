import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SpineForceApp());
}

class SpineForceApp extends StatelessWidget {
  const SpineForceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpineForce ECG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4F8A),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}