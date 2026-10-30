import 'package:flutter/material.dart';
import 'horario_screen.dart';
import 'calendar_screen.dart';
import 'materias_tareas_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // 0 = Horario (Pantalla principal de inicio)

  final List<Widget> _paginas = const [
    HorarioScreen(),         // Pantalla Principal: Horario
    CalendarScreen(),        // Calendario mensual estilo Google
    MateriasTareasScreen(),  // Materias y Tareas
    ProfileScreen(),         // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF1D969F);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}