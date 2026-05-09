import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'ble_screen.dart';

class DemographicsScreen extends StatefulWidget {
  final PatientModel patient;
  const DemographicsScreen({super.key, required this.patient});

  @override
  State<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends State<DemographicsScreen> {
  final _nombreCtrl = TextEditingController();
  final _edadCtrl   = TextEditingController();
  String _sexo      = 'M';
  String _actividad = 'moderado';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos del paciente')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _edadCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Edad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Sexo', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Radio(
                    value: 'M',
                    groupValue: _sexo,
                    onChanged: (v) => setState(() => _sexo = v!)),
                const Text('Masculino'),
                const SizedBox(width: 16),
                Radio(
                    value: 'F',
                    groupValue: _sexo,
                    onChanged: (v) => setState(() => _sexo = v!)),
                const Text('Femenino'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Nivel de actividad física',
                style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _actividad,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                    value: 'sedentario', child: Text('Sedentario')),
                DropdownMenuItem(
                    value: 'moderado', child: Text('Moderado')),
                DropdownMenuItem(
                    value: 'activo', child: Text('Activo')),
              ],
              onChanged: (v) => setState(() => _actividad = v!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.patient.nombre    = _nombreCtrl.text;
                  widget.patient.edad      = int.tryParse(_edadCtrl.text) ?? 0;
                  widget.patient.sexo      = _sexo;
                  widget.patient.actividad = _actividad;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BleScreen(patient: widget.patient),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16)),
                child: const Text('Conectar sensor',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}