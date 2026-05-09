import 'package:flutter/material.dart';
import '../models/patient_model.dart';

class ResultScreen extends StatelessWidget {
  final PatientModel patient;
  const ResultScreen({super.key, required this.patient});

  String _getRecomendacion() {
    double bpm       = patient.bpmPromedio;
    int    edad      = patient.edad;
    String actividad = patient.actividad;

    double bpmMin = actividad == 'activo' ? 45 : 60;
    double bpmMax = edad > 60 ? 90 : 100;

    if (bpm < bpmMin) {
      return '⚠️ Frecuencia cardíaca baja (bradicardia).\nConsulta a tu médico si presentas mareos o fatiga.';
    } else if (bpm > bpmMax) {
      return '⚠️ Frecuencia cardíaca elevada (taquicardia).\nDescansa y consulta a tu médico si persiste.';
    } else if (actividad == 'sedentario' && bpm > 80) {
      return '✅ Ritmo normal pero considera aumentar tu actividad física para mejorar tu salud cardiovascular.';
    } else {
      return '✅ Frecuencia cardíaca dentro del rango normal para tu perfil. ¡Sigue así!';
    }
  }

  Color _getColor() {
    double bpm = patient.bpmPromedio;
    if (bpm < 50 || bpm > 100) return Colors.red.shade100;
    if (bpm > 85) return Colors.orange.shade100;
    return Colors.green.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${patient.nombre}',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                '${patient.edad} años  •  ${patient.sexo}  •  ${patient.actividad}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                      '${patient.bpmPromedio.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4F8A))),
                  const Text('BPM promedio',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRecomendacion(),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16)),
                child: const Text('Nueva medición',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}