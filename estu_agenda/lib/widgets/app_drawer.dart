import 'package:flutter/material.dart';
import '../screens/horario_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/materias_tareas_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute; // Para saber qué opción marcar como seleccionada

  static const Color primaryTeal = Color(0xFF1D969F);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF124B51);

  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget destinationScreen,
    required String routeName,
    bool isLogout = false,
  }) {
    final isSelected = currentRoute == routeName;
    final colorText = isLogout ? Colors.red : (isSelected ? primaryTeal : textDark);
    final colorBg = isSelected ? primaryTeal.withOpacity(0.12) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pop(context); // Cierra el drawer
          if (isLogout) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => destinationScreen),
              (route) => false,
            );
          } else if (!isSelected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => destinationScreen),
            );
          }
        },
        dense: true,
        leading: Icon(icon, color: colorText, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: colorText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: cardColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: primaryTeal, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'EsTuAgenda',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: primaryTeal.withOpacity(0.15),
                    child: const Icon(Icons.person_outline, size: 40, color: primaryTeal),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Estudiante',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  Text(
                    'estudiante@email.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: [
                  _buildDrawerOption(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'Inicio',
                    destinationScreen: const HorarioScreen(),
                    routeName: 'horario',
                  ),
                  _buildDrawerOption(
                    context: context,
                    icon: Icons.calendar_month_outlined,
                    title: 'Calendario',
                    destinationScreen: const CalendarScreen(),
                    routeName: 'calendar',
                  ),
                  _buildDrawerOption(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    title: 'Materias y Tareas',
                    destinationScreen: const MateriasTareasScreen(),
                    routeName: 'materias',
                  ),
                  _buildDrawerOption(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'Perfil',
                    destinationScreen: const ProfileScreen(),
                    routeName: 'profile',
                  ),
                  _buildDrawerOption(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    destinationScreen: const SettingsScreen(),
                    routeName: 'settings',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildDrawerOption(
                context: context,
                icon: Icons.logout_rounded,
                title: 'Cerrar sesión',
                destinationScreen: const LoginScreen(),
                routeName: 'logout',
                isLogout: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}