import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _cargando = false;

  bool get cargando => _cargando;

  String? validarCorreo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu correo';
    }

    if (!value.contains('@') ||
        !value.contains('.')) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }

    return null;
  }

  Future<bool> iniciarSesion() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      return false;
    }

    _cargando = true;
    notifyListeners();

    try {
      // Aquí se conectará la autenticación real.
      return true;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}