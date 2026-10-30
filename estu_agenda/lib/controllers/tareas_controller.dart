import 'package:flutter/material.dart';

class ClaseHorario {
  final String id;
  String materia;
  final int dia; 
  final TimeOfDay inicio;
  final TimeOfDay fin;

  ClaseHorario({
    required this.id,
    required this.materia,
    required this.dia,
    required this.inicio,
    required this.fin,
  });
}

enum EstadoTarea { pendiente, enProceso, terminada }

class Tarea {
  final String id;
  String titulo;
  String materia;
  EstadoTarea estado;

  Tarea({
    required this.id,
    required this.titulo,
    required this.materia,
    this.estado = EstadoTarea.pendiente,
  });
}

class TareasController extends ChangeNotifier {
  static final TareasController _instancia = TareasController._interno();
  factory TareasController() => _instancia;
  TareasController._interno();

  final List<ClaseHorario> _clases = [];
  final List<String> materias = [];
  final List<Tarea> _todasLasTareas = [];

  String? _materiaSeleccionada;
  String? get materiaSeleccionada => _materiaSeleccionada;

  String _filtroActivo = 'Todas';
  String get filtroActivo => _filtroActivo;

  List<ClaseHorario> get clases => List.unmodifiable(_clases);

  List<Tarea> get tareasPendientes {
    return _todasLasTareas
        .where((tarea) => tarea.estado != EstadoTarea.terminada)
        .toList();
  }

  String? agregarClase({
    required String materia,
    required int dia,
    required TimeOfDay inicio,
    required TimeOfDay fin,
  }) {
    final nombre = materia.trim();
    final desde = inicio.hour * 60 + inicio.minute;
    final hasta = fin.hour * 60 + fin.minute;

    if (!materias.contains(nombre)) {
      return 'Selecciona una materia registrada.';
    }

    if (dia < 1 || dia > 7) {
      return 'Selecciona un día válido.';
    }

    if (hasta <= desde) {
      return 'La hora de fin debe ser posterior a la de inicio.';
    }

    final hayCruce = _clases.any((clase) {
      final inicioExistente = clase.inicio.hour * 60 + clase.inicio.minute;
      final finExistente = clase.fin.hour * 60 + clase.fin.minute;

      return clase.dia == dia && desde < finExistente && hasta > inicioExistente;
    });

    if (hayCruce) {
      return 'Ya tienes una clase en ese horario.';
    }

    _clases.add(
      ClaseHorario(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        materia: nombre,
        dia: dia,
        inicio: inicio,
        fin: fin,
      ),
    );

    notifyListeners();
    return null;
  }

  void eliminarClase(String id) {
    _clases.removeWhere((clase) => clase.id == id);
    notifyListeners();
  }

  void agregarMateria(String nuevaMateria) {
    final materiaLimpia = nuevaMateria.trim();
    if (materiaLimpia.isEmpty) return;

    if (!materias.contains(materiaLimpia)) {
      materias.add(materiaLimpia);
      _materiaSeleccionada = materiaLimpia;
      notifyListeners();
    }
  }

  void editarMateriaActual(String nuevoNombre) {
    final nombreLimpio = nuevoNombre.trim();
    if (nombreLimpio.isEmpty || _materiaSeleccionada == null) return;

    final index = materias.indexOf(_materiaSeleccionada!);
    if (index != -1) {
      final materiaAntigua = _materiaSeleccionada!;
      for (final clase in _clases) {
        if (clase.materia == materiaAntigua) {
          clase.materia = nombreLimpio;
        }
      }
      materias[index] = nombreLimpio;
      _materiaSeleccionada = nombreLimpio;

      for (var tarea in _todasLasTareas) {
        if (tarea.materia == materiaAntigua) {
          tarea.materia = nombreLimpio;
        }
      }
      notifyListeners();
    }
  }

  void eliminarMateriaActual() {
    if (_materiaSeleccionada == null) return;

    final materiaAEliminar = _materiaSeleccionada!;
    materias.remove(materiaAEliminar);
    _clases.removeWhere((clase) => clase.materia == materiaAEliminar);
    _todasLasTareas.removeWhere((t) => t.materia == materiaAEliminar);

    _materiaSeleccionada = materias.isNotEmpty ? materias.first : null;
    notifyListeners();
  }

  void seleccionarMateria(String nuevaMateria) {
    _materiaSeleccionada = nuevaMateria;
    notifyListeners();
  }

  void agregarTarea(String titulo) {
    if (titulo.trim().isEmpty || _materiaSeleccionada == null) return;
    _todasLasTareas.add(
      Tarea(
        id: DateTime.now().toString(),
        titulo: titulo.trim(),
        materia: _materiaSeleccionada!,
        estado: EstadoTarea.pendiente,
      ),
    );
    notifyListeners();
  }

  void editarTarea(String id, String nuevoTitulo) {
    final tituloLimpio = nuevoTitulo.trim();
    if (tituloLimpio.isEmpty) return;

    final index = _todasLasTareas.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todasLasTareas[index].titulo = tituloLimpio;
      notifyListeners();
    }
  }

  void eliminarTarea(String id) {
    _todasLasTareas.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void cambiarEstadoTarea(String id, EstadoTarea nuevoEstado) {
    final index = _todasLasTareas.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todasLasTareas[index].estado = nuevoEstado;
      notifyListeners();
    }
  }

  void cambiarFiltro(String nuevoFiltro) {
    _filtroActivo = nuevoFiltro;
    notifyListeners();
  }

  List<Tarea> get tareasFiltradas {
    if (_materiaSeleccionada == null) return [];

    var tareasDeMateria = _todasLasTareas.where((t) => t.materia == _materiaSeleccionada);

    if (_filtroActivo == 'Pendientes') {
      return tareasDeMateria.where((t) => t.estado == EstadoTarea.pendiente).toList();
    } else if (_filtroActivo == 'En proceso') {
      return tareasDeMateria.where((t) => t.estado == EstadoTarea.enProceso).toList();
    } else if (_filtroActivo == 'Terminadas') {
      return tareasDeMateria.where((t) => t.estado == EstadoTarea.terminada).toList();
    }
    return tareasDeMateria.toList();
  }

  Color obtenerColorEstado(EstadoTarea estado) {
    switch (estado) {
      case EstadoTarea.pendiente:
        return const Color(0xFFE57373);
      case EstadoTarea.enProceso:
        return const Color(0xFFFFB74D);
      case EstadoTarea.terminada:
        return const Color(0xFF81C784);
    }
  }
}