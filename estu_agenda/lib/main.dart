import 'package:flutter/material.dart';
import 'screens/horario_screen.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EsTuAgenda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D969F),
        ),
        useMaterial3: true,
      ),
      home: const HorarioScreen(), // Pantalla principal por defecto
    );
  }
}