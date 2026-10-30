import 'package:flutter/material.dart';

class CalendarController extends ChangeNotifier {
  DateTime _fechaSeleccionada = DateTime.now();
  DateTime _mesActual = DateTime.now();

  DateTime get fechaSeleccionada => _fechaSeleccionada;
  DateTime get mesActual => _mesActual;

  void seleccionarFecha(DateTime fecha) {
    _fechaSeleccionada = fecha;
    _mesActual = DateTime(fecha.year, fecha.month);
    notifyListeners();
  }

  void mesAnterior() {
    _mesActual = DateTime(
      _mesActual.year,
      _mesActual.month - 1,
    );
    notifyListeners();
  }

  void mesSiguiente() {
    _mesActual = DateTime(
      _mesActual.year,
      _mesActual.month + 1,
    );
    notifyListeners();
  }

  void irAHoy() {
    _fechaSeleccionada = DateTime.now();
    _mesActual = DateTime.now();
    notifyListeners();
  }

  bool esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}