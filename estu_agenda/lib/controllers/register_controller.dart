import 'package:flutter/material.dart';

class RegisterController extends ChangeNotifier {
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController =
      TextEditingController();

  String? generoSeleccionado;
  bool aceptaTerminos = false;
  bool _cargando = false;

  bool get cargando => _cargando;

  void seleccionarGenero(String? genero) {
    generoSeleccionado = genero;
    notifyListeners();
  }

  void cambiarAceptacion(bool valor) {
    aceptaTerminos = valor;
    notifyListeners();
  }

  String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu nombre';
    }

    return null;
  }

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
    if (value == null || value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  String? validarConfirmacion(String? value) {
    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  Future<bool> registrar() async {
    if (nombreController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        passwordController.text !=
            confirmarPasswordController.text ||
        !aceptaTerminos) {
      return false;
    }

    _cargando = true;
    notifyListeners();

    try {
      // Aquí se conectará el registro real.
      return true;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }
}