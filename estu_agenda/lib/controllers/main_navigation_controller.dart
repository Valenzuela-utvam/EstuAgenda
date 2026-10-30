import 'package:flutter/material.dart';

class MainNavigationController extends ChangeNotifier {
  int _indiceActual = 0;

  int get indiceActual => _indiceActual;

  void cambiarPantalla(int indice) {
    if (indice < 0 || indice > 4) return;

    _indiceActual = indice;
    notifyListeners();
  }

  void irAInicio() {
    cambiarPantalla(0);
  }

  void irACalendario() {
    cambiarPantalla(1);
  }

  void irAMaterias() {
    cambiarPantalla(2);
  }

  void irAPerfil() {
    cambiarPantalla(3);
  }

  void irAConfiguracion() {
    cambiarPantalla(4);
  }
}