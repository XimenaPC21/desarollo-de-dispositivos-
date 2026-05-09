import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'result_screen.dart';

const String ESP32_IP   = "10.82.79.155";
const int    ESP32_PORT = 8080;
const int    MAX_PUNTOS = 100;

class BleScreen extends StatefulWidget {
  final PatientModel patient;
  const BleScreen({super.key, required this.patient});

  @override
  State<BleScreen> createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  String _status    = 'Conectando al ESP32...';
  bool   _conectado = false;
  bool   _midiendo  = false;

  List<FlSpot> _puntos = [];
  double _tiempo = 0;

  List<double> _senalBuffer  = [];
  List<double> _intervalosRR = [];
  double _bpmActual  = 0;
  double _ultimoPico = -1;
  double _umbral     = 0;
  int    _muestras   = 0;

  Socket?             _socket;
  StreamSubscription? _dataSub;

  @override
  void initState() {
    super.initState();
    _connectToESP32();
  }

  void _connectToESP32() async {
    try {
      setState(() => _status = 'Conectando a ESP32...');
      _socket = await Socket.connect(ESP32_IP, ESP32_PORT,
          timeout: const Duration(seconds: 10));
      setState(() {
        _status    = 'Conectado';
        _conectado = true;
      });
      _dataSub = _socket!.listen(
        (List<int> data) {
          String line = utf8.decode(data).trim();
          for (String parte in line.split('\n')) {
            if (parte.isNotEmpty) _onDataReceived(parte);
          }
        },
        onError: _onError,
      );
    } catch (e) {
      setState(() => _status = 'Error: verifica que el ESP32 esté encendido');
    }
  }

  void _onDataReceived(String line) {
    double mv = double.tryParse(line.trim()) ?? -1;
    if (mv < 100 || mv > 3300) return;

    _muestras++;
    _tiempo += 0.05;

    // Buffer de señal
    _senalBuffer.add(mv);
    if (_senalBuffer.length > 200) _senalBuffer.removeAt(0);

    // Umbral dinámico
    if (_senalBuffer.length >= 20) {
      double max = _senalBuffer.reduce((a, b) => a > b ? a : b);
      double min = _senalBuffer.reduce((a, b) => a < b ? a : b);
      _umbral = min + (max - min) * 0.5;
    }

    // Detectar pico QRS
    int n = _senalBuffer.length;
    if (n >= 5) {
      double curr  = _senalBuffer[n - 1];
      double prev1 = _senalBuffer[n - 2];
      double prev2 = _senalBuffer[n - 3];

      bool esPico = curr > _umbral &&
          curr > prev1 &&
          curr > prev2 &&
          (curr - prev1) > 50;

      if (esPico && (_ultimoPico < 0 || (_tiempo - _ultimoPico) > 0.3)) {
        if (_ultimoPico >= 0) {
          double intervaloRR = _tiempo - _ultimoPico;
          if (intervaloRR < 2.0) {
            _intervalosRR.add(intervaloRR);
            if (_intervalosRR.length > 8) _intervalosRR.removeAt(0);
            if (_intervalosRR.length >= 2) {
              double promedioRR = _intervalosRR.reduce((a, b) => a + b) /
                  _intervalosRR.length;
              _bpmActual = 60.0 / promedioRR;
            }
          }
        }
        _ultimoPico = _tiempo;
      }
    }

    // Actualizar gráfica cada 3 muestras
    if (_muestras % 3 == 0) {
      setState(() {
        _puntos.add(FlSpot(_tiempo, mv));
        if (_puntos.length > MAX_PUNTOS) _puntos.removeAt(0);
      });
    }
  }

  void _onError(dynamic error) {
    setState(() {
      _status    = 'Conexión perdida. Reconectando...';
      _conectado = false;
    });
    Future.delayed(const Duration(seconds: 2), _connectToESP32);
  }

  void _startMeasurement() {
    setState(() {
      _midiendo     = true;
      _intervalosRR = [];
      _bpmActual    = 0;
      _status       = 'Midiendo 15 segundos...';
    });
    Future.delayed(const Duration(seconds: 15), _finishMeasurement);
  }

  void _finishMeasurement() {
    widget.patient.bpmPromedio = _bpmActual;
    setState(() {
      _midiendo = false;
      _status   = 'Medición completada';
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ResultScreen(patient: widget.patient)),
    );
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    _socket?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double xMax = _puntos.isNotEmpty ? _puntos.last.x : 1;
    double xMin = xMax - (MAX_PUNTOS * 0.05);

    return Scaffold(
      appBar: AppBar(title: const Text('Sensor ECG')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Estado y BPM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _conectado ? Icons.wifi : Icons.wifi_off,
                      color: _conectado ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(_status,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4F8A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_bpmActual.toStringAsFixed(0)} BPM',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gráfica ECG
            Expanded(
              child: _puntos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        minX: xMin,
                        maxX: xMax,
                        minY: 1000,
                        maxY: 3200,
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 500,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 0.5,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 0.5,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 500,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _puntos,
                            isCurved: false,
                            color: const Color(0xFF1B4F8A),
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Botón
            if (_conectado)
              SizedBox(
                width: double.infinity,
                child: _midiendo
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _startMeasurement,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar medición (15s)'),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            textStyle: const TextStyle(fontSize: 16)),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}