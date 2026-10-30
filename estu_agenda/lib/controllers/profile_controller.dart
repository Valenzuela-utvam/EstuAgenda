import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  String _nombre = 'Estudiante';
  String _correo = 'estudiante@email.com';

  String get nombre => _nombre;
  String get correo => _correo;

  void actualizarPerfil({
    required String nombre,
    required String correo,
  }) {
    if (nombre.trim().isEmpty ||
        correo.trim().isEmpty) {
      return;
    }

    _nombre = nombre.trim();
    _correo = correo.trim();

    notifyListeners();
  }

  void actualizarNombre(String nombre) {
    if (nombre.trim().isEmpty) return;

    _nombre = nombre.trim();
    notifyListeners();
  }

  void actualizarCorreo(String correo) {
    if (correo.trim().isEmpty ||
        !correo.contains('@')) {
      return;
    }

    _correo = correo.trim();
    notifyListeners();
  }
}