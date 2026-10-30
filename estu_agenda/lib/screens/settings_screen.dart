import 'package:flutter/material.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryTeal = Color(0xFF1D969F);
  static const Color bgColor = Color(0xFFEBF6F8);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF124B51);

  bool _sonido = true;
  bool _notificaciones = true;
  bool _modoOscuro = false;

  void _mostrarOpcion({
    required String titulo,
    required Widget contenido,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: contenido,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
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
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: primaryTeal,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Configuraciones',
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingsOption(
              icon: Icons.volume_up_outlined,
              title: 'Sonido',
              iconColor: Colors.blue,
              iconBgColor: Colors.blue.withOpacity(0.15),
              onTap: () {
                _mostrarOpcion(
                  titulo: 'Sonido',
                  contenido: StatefulBuilder(
                    builder: (context, setDialogState) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Activar sonido'),
                        value: _sonido,
                        onChanged: (value) {
                          setState(() => _sonido = value);
                          setDialogState(() {});
                        },
                      );
                    },
                  ),
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.notifications_none_rounded,
              title: 'Notificaciones',
              iconColor: Colors.deepPurple,
              iconBgColor: Colors.deepPurple.withOpacity(0.15),
              onTap: () {
                _mostrarOpcion(
                  titulo: 'Notificaciones',
                  contenido: StatefulBuilder(
                    builder: (context, setDialogState) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Activar notificaciones',
                        ),
                        value: _notificaciones,
                        onChanged: (value) {
                          setState(() {
                            _notificaciones = value;
                          });
                          setDialogState(() {});
                        },
                      );
                    },
                  ),
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.palette_outlined,
              title: 'Apariencia',
              iconColor: Colors.pink,
              iconBgColor: Colors.pink.withOpacity(0.15),
              onTap: () {
                _mostrarOpcion(
                  titulo: 'Apariencia',
                  contenido: StatefulBuilder(
                    builder: (context, setDialogState) {
                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Modo oscuro'),
                        value: _modoOscuro,
                        onChanged: (value) {
                          setState(() => _modoOscuro = value);
                          setDialogState(() {});
                        },
                      );
                    },
                  ),
                );
              },
            ),
            _buildSettingsOption(
              icon: Icons.info_outline,
              title: 'Acerca de',
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.withOpacity(0.15),
              onTap: () {
                _mostrarOpcion(
                  titulo: 'Acerca de EsTuAgenda',
                  contenido: const Text(
                    'EsTuAgenda te ayuda a organizar tus materias, '
                    'tareas y horarios escolares.',
                  ),
                );
              },
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.logout,
                color: primaryTeal,
              ),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: primaryTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}