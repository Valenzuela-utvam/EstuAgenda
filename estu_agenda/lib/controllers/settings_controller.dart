import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  bool _sonido = true;
  bool _notificaciones = true;
  bool _modoOscuro = false;

  bool get sonido => _sonido;
  bool get notificaciones => _notificaciones;
  bool get modoOscuro => _modoOscuro;

  void cambiarSonido(bool valor) {
    _sonido = valor;
    notifyListeners();
  }

  void cambiarNotificaciones(bool valor) {
    _notificaciones = valor;
    notifyListeners();
  }

  void cambiarModoOscuro(bool valor) {
    _modoOscuro = valor;
    notifyListeners();
  }
}