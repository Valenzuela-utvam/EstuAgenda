import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';
import 'materias_tareas_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryTeal = Color(0xFF1D969F);
  static const Color bgColor = Color(0xFFEBF6F8);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF124B51);

  final int _currentBottomNavIndex = 3;

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: primaryTeal, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDrawerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isLogout = false,
  }) {
    final colorText = isLogout
        ? Colors.red
        : (isSelected ? primaryTeal : textDark);

    final colorBg = isSelected
        ? primaryTeal.withOpacity(0.12)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(icon, color: colorText, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: colorText,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 0 || index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CalendarScreen(),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MateriasTareasScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: primaryTeal,
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.menu_book_rounded,
              color: primaryTeal,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Configuración',
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Image.asset(
              'assets/logo.png',
              height: 32,
              width: 32,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.account_circle,
                color: primaryTeal,
                size: 32,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: primaryTeal,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: cardColor,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.auto_stories_rounded,
                          color: primaryTeal,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Agenda',
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
                      backgroundColor:
                          primaryTeal.withOpacity(0.15),
                      child: const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: primaryTeal,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  children: [
                    _buildDrawerOption(
                      icon: Icons.home_rounded,
                      title: 'Inicio',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalendarScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerOption(
                      icon: Icons.person_outline_rounded,
                      title: 'Perfil',
                      isSelected: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerOption(
                      icon: Icons.calendar_month_outlined,
                      title: 'Calendario',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalendarScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerOption(
                      icon: Icons.menu_book_rounded,
                      title: 'Materias',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MateriasTareasScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerOption(
                      icon: Icons.check_box_outlined,
                      title: 'Tareas',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MateriasTareasScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerOption(
                      icon: Icons.settings_outlined,
                      title: 'Configuración',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildDrawerOption(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión',
                  isLogout: true,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        primaryTeal.withOpacity(0.15),
                    child: const Icon(
                      Icons.person_outline,
                      size: 36,
                      color: primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estudiante',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mi perfil',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileOption(
              icon: Icons.person_outline,
              title: 'Datos personales',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.assignment_outlined,
              title: 'Datos académicos',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardColor,
          selectedItemColor: primaryTeal,
          unselectedItemColor: Colors.grey.shade400,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
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
      ),
    );
  }
}