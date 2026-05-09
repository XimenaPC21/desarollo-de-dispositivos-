import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'demographics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4F8A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monitor_heart,
                  size: 90, color: Colors.white),
              const SizedBox(height: 24),
              const Text('SpineForce ECG',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Monitor de ritmo cardíaco',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DemographicsScreen(patient: PatientModel()),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Comenzar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}