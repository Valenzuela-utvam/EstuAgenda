import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClaseHorario {
  final String id;
  final String materiaId;
  final String materia;
  final int dia;
  final TimeOfDay inicio;
  final TimeOfDay fin;

  ClaseHorario({
    required this.id,
    required this.materiaId,
    required this.materia,
    required this.dia,
    required this.inicio,
    required this.fin,
  });
}

enum EstadoTarea { pendiente, enProceso, terminada }

class Tarea {
  final String id;
  final String materiaId;
  final String materia;
  final String titulo;
  final EstadoTarea estado;

  Tarea({
    required this.id,
    required this.materiaId,
    required this.materia,
    required this.titulo,
    this.estado = EstadoTarea.pendiente,
  });
}

class TareasController extends ChangeNotifier {
  static final TareasController _instancia = TareasController._interno();
  factory TareasController() => _instancia;

  TareasController._interno() {
    _isLoading = true;
    unawaited(_cambiarUsuario(FirebaseAuth.instance.currentUser?.uid));
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) => unawaited(_cambiarUsuario(user?.uid)),
      onError: (Object error) {
        _errorCarga = 'No se pudo verificar la cuenta: $error';
        _hasSyncError = true;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<User?> _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _subjectsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _classesSubscription;

  final List<ClaseHorario> _clases = [];
  final List<String> _materias = [];
  final List<Tarea> _todasLasTareas = [];
  final Map<String, String> _materiasPorId = {};

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _taskDocuments = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _classDocuments = [];
  CollectionReference<Map<String, dynamic>>? _subjectsCollection;
  CollectionReference<Map<String, dynamic>>? _tasksCollection;
  CollectionReference<Map<String, dynamic>>? _classesCollection;

  String? _userId;
  String? _selectedSubjectId;
  String? _errorCarga;
  String _filtroActivo = 'Todas';
  bool _isLoading = false;
  bool _hasSyncError = false;
  bool _hasBoundAuthState = false;
  bool _receivedSubjects = false;
  bool _receivedTasks = false;
  bool _receivedClasses = false;
  int _bindingGeneration = 0;

  String? get materiaSeleccionada =>
      _selectedSubjectId == null ? null : _materiasPorId[_selectedSubjectId];
  String? get materiaIdSeleccionada => _selectedSubjectId;
  Map<String, String> get materiasPorId => Map.unmodifiable(_materiasPorId);
  String? get errorCarga => _errorCarga;
  bool get isLoading => _isLoading;
  String get filtroActivo => _filtroActivo;
  List<String> get materias => List.unmodifiable(_materias);
  List<ClaseHorario> get clases => List.unmodifiable(_clases);

  List<Tarea> get tareasPendientes => _todasLasTareas
      .where((tarea) => tarea.estado != EstadoTarea.terminada)
      .toList();

  Future<void> _cambiarUsuario(String? userId) async {
    if (_hasBoundAuthState && userId == _userId) return;
    _hasBoundAuthState = true;
    _userId = userId;
    final generation = ++_bindingGeneration;
    final oldSubjectsSubscription = _subjectsSubscription;
    final oldTasksSubscription = _tasksSubscription;
    final oldClassesSubscription = _classesSubscription;
    _subjectsSubscription = null;
    _tasksSubscription = null;
    _classesSubscription = null;
    _subjectsCollection = null;
    _tasksCollection = null;
    _classesCollection = null;
    _selectedSubjectId = null;
    _materiasPorId.clear();
    _materias.clear();
    _clases.clear();
    _todasLasTareas.clear();
    _taskDocuments = [];
    _classDocuments = [];
    _errorCarga = null;
    _hasSyncError = false;
    _receivedSubjects = false;
    _receivedTasks = false;
    _receivedClasses = false;
    _isLoading = userId != null;
    notifyListeners();

    await oldSubjectsSubscription?.cancel();
    await oldTasksSubscription?.cancel();
    await oldClassesSubscription?.cancel();
    if (generation != _bindingGeneration) return;
    if (userId == null) return;

    final userDocument = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);
    _subjectsCollection = userDocument.collection('subjects');
    _tasksCollection = userDocument.collection('tasks');
    _classesCollection = userDocument.collection('classes');

    _subjectsSubscription = _subjectsCollection!.snapshots().listen(
      (snapshot) => _onSubjectsSnapshot(snapshot, generation),
      onError: (Object error) => _onLoadError(error, generation),
    );
    _tasksSubscription = _tasksCollection!.snapshots().listen(
      (snapshot) => _onTasksSnapshot(snapshot, generation),
      onError: (Object error) => _onLoadError(error, generation),
    );
    _classesSubscription = _classesCollection!.snapshots().listen(
      (snapshot) => _onClassesSnapshot(snapshot, generation),
      onError: (Object error) => _onLoadError(error, generation),
    );
  }

  void _onSubjectsSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    int generation,
  ) {
    if (generation != _bindingGeneration) return;
    final subjects = <String, String>{};
    for (final document in snapshot.docs) {
      final name = document.data()['name'];
      if (name is! String || name.trim().isEmpty) {
        _onLoadError(
          const FormatException('Una materia tiene un nombre inválido.'),
          generation,
        );
        return;
      }
      subjects[document.id] = name.trim();
    }

    _materiasPorId
      ..clear()
      ..addAll(subjects);
    _materias
      ..clear()
      ..addAll(subjects.values);
    if (_selectedSubjectId == null ||
        !_materiasPorId.containsKey(_selectedSubjectId)) {
      _selectedSubjectId = subjects.isEmpty ? null : subjects.keys.first;
    }
    _receivedSubjects = true;
    _refreshRelatedData(generation);
  }

  void _onTasksSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    int generation,
  ) {
    if (generation != _bindingGeneration) return;
    _taskDocuments = snapshot.docs;
    _receivedTasks = true;
    _refreshRelatedData(generation);
  }

  void _onClassesSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    int generation,
  ) {
    if (generation != _bindingGeneration) return;
    _classDocuments = snapshot.docs;
    _receivedClasses = true;
    _refreshRelatedData(generation);
  }

  void _refreshRelatedData(int generation) {
    try {
      _todasLasTareas
        ..clear()
        ..addAll(
          _taskDocuments.map((document) {
            final data = document.data();
            final subjectId = data['subjectId'];
            final title = data['title'];
            final stateName = data['status'];
            if (subjectId is! String ||
                title is! String ||
                stateName is! String ||
                !_materiasPorId.containsKey(subjectId)) {
              throw const FormatException('Una tarea tiene datos inválidos.');
            }

            final state = EstadoTarea.values.where(
              (value) => value.name == stateName,
            );
            if (state.isEmpty) {
              throw const FormatException(
                'Una tarea tiene un estado inválido.',
              );
            }

            return Tarea(
              id: document.id,
              materiaId: subjectId,
              materia: _materiasPorId[subjectId]!,
              titulo: title,
              estado: state.first,
            );
          }),
        );

      _clases
        ..clear()
        ..addAll(
          _classDocuments.map((document) {
            final data = document.data();
            final subjectId = data['subjectId'];
            final weekday = data['weekday'];
            final startMinutes = data['startMinutes'];
            final endMinutes = data['endMinutes'];
            if (subjectId is! String ||
                weekday is! int ||
                startMinutes is! int ||
                endMinutes is! int ||
                !_materiasPorId.containsKey(subjectId) ||
                weekday < 1 ||
                weekday > 7 ||
                startMinutes < 0 ||
                startMinutes >= 24 * 60 ||
                endMinutes <= startMinutes ||
                endMinutes >= 24 * 60) {
              throw const FormatException('Una clase tiene datos inválidos.');
            }

            return ClaseHorario(
              id: document.id,
              materiaId: subjectId,
              materia: _materiasPorId[subjectId]!,
              dia: weekday,
              inicio: TimeOfDay(
                hour: startMinutes ~/ 60,
                minute: startMinutes % 60,
              ),
              fin: TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60),
            );
          }),
        );
      if (!_hasSyncError) _errorCarga = null;
    } on FormatException catch (error) {
      _errorCarga = error.message;
    }

    _isLoading = !(_receivedSubjects && _receivedTasks && _receivedClasses);
    notifyListeners();
  }

  void _onLoadError(Object error, int generation) {
    if (generation != _bindingGeneration) return;
    _errorCarga = 'No se pudieron sincronizar materias y tareas: $error';
    _hasSyncError = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> recargar() async {
    if (_userId == null) return;
    _hasBoundAuthState = false;
    await _cambiarUsuario(_userId);
  }

  String? validarClase({
    required String materiaId,
    required int dia,
    required TimeOfDay inicio,
    required TimeOfDay fin,
    String? claseIdIgnorada,
  }) {
    final desde = inicio.hour * 60 + inicio.minute;
    final hasta = fin.hour * 60 + fin.minute;
    if (!_materiasPorId.containsKey(materiaId)) {
      return 'Selecciona una materia registrada.';
    }
    if (dia < 1 || dia > 7) return 'Selecciona un día válido.';
    if (hasta <= desde) {
      return 'La hora de fin debe ser posterior a la de inicio.';
    }
    final hayCruce = _clases.any((clase) {
      if (clase.id == claseIdIgnorada || clase.dia != dia) return false;
      final inicioExistente = clase.inicio.hour * 60 + clase.inicio.minute;
      final finExistente = clase.fin.hour * 60 + clase.fin.minute;
      return desde < finExistente && hasta > inicioExistente;
    });
    if (hayCruce) return 'Ya tienes una clase en ese horario.';
    return null;
  }

  Future<void> agregarClase({
    required String materiaId,
    required int dia,
    required TimeOfDay inicio,
    required TimeOfDay fin,
  }) async {
    final message = validarClase(
      materiaId: materiaId,
      dia: dia,
      inicio: inicio,
      fin: fin,
    );
    if (message != null) throw ArgumentError(message);
    final classes = _classesCollection;
    if (classes == null) throw StateError('No hay una cuenta autenticada.');

    await classes.add({
      'subjectId': materiaId,
      'weekday': dia,
      'startMinutes': inicio.hour * 60 + inicio.minute,
      'endMinutes': fin.hour * 60 + fin.minute,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarClase(String id) async {
    final classes = _classesCollection;
    if (classes == null) throw StateError('No hay una cuenta autenticada.');
    await classes.doc(id).delete();
  }

  Future<String?> agregarMateria(String nuevaMateria) async {
    final materiaLimpia = nuevaMateria.trim();
    if (materiaLimpia.isEmpty) return 'Escribe el nombre de la materia.';
    if (_materias.any(
      (value) => value.toLowerCase() == materiaLimpia.toLowerCase(),
    )) {
      return 'Ya existe una materia con ese nombre.';
    }
    final subjects = _subjectsCollection;
    if (subjects == null) throw StateError('No hay una cuenta autenticada.');

    final subject = await subjects.add({
      'name': materiaLimpia,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _materiasPorId[subject.id] = materiaLimpia;
    _materias.add(materiaLimpia);
    _selectedSubjectId = subject.id;
    notifyListeners();
    return null;
  }

  Future<String?> editarMateriaActual(String nuevoNombre) async {
    final nombreLimpio = nuevoNombre.trim();
    final subjectId = _selectedSubjectId;
    if (nombreLimpio.isEmpty) return 'Escribe el nombre de la materia.';
    if (subjectId == null) return 'Selecciona una materia.';
    if (_materias.any(
      (value) =>
          value.toLowerCase() == nombreLimpio.toLowerCase() &&
          value != _materiasPorId[subjectId],
    )) {
      return 'Ya existe una materia con ese nombre.';
    }
    final subjects = _subjectsCollection;
    if (subjects == null) throw StateError('No hay una cuenta autenticada.');

    await subjects.doc(subjectId).update({
      'name': nombreLimpio,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return null;
  }

  Future<void> eliminarMateriaActual() async {
    final subjectId = _selectedSubjectId;
    final subjects = _subjectsCollection;
    final tasks = _tasksCollection;
    final classes = _classesCollection;
    if (subjectId == null ||
        subjects == null ||
        tasks == null ||
        classes == null) {
      throw StateError('No hay una materia seleccionada.');
    }

    final taskSnapshot = await tasks
        .where('subjectId', isEqualTo: subjectId)
        .get();
    final classSnapshot = await classes
        .where('subjectId', isEqualTo: subjectId)
        .get();
    final references = <DocumentReference<Map<String, dynamic>>>[
      ...taskSnapshot.docs.map((document) => document.reference),
      ...classSnapshot.docs.map((document) => document.reference),
      subjects.doc(subjectId),
    ];

    for (var start = 0; start < references.length; start += 450) {
      final batch = FirebaseFirestore.instance.batch();
      for (final reference in references.skip(start).take(450)) {
        batch.delete(reference);
      }
      await batch.commit();
    }
  }

  void seleccionarMateria(String materiaId) {
    if (!_materiasPorId.containsKey(materiaId)) return;
    _selectedSubjectId = materiaId;
    notifyListeners();
  }

  Future<void> agregarTarea(String titulo) async {
    final tituloLimpio = titulo.trim();
    final subjectId = _selectedSubjectId;
    final tasks = _tasksCollection;
    if (tituloLimpio.isEmpty || subjectId == null || tasks == null) {
      throw StateError(
        'Selecciona una materia y escribe el nombre de la tarea.',
      );
    }
    await tasks.add({
      'subjectId': subjectId,
      'title': tituloLimpio,
      'status': EstadoTarea.pendiente.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> editarTarea(String id, String nuevoTitulo) async {
    final tituloLimpio = nuevoTitulo.trim();
    final tasks = _tasksCollection;
    if (tituloLimpio.isEmpty || tasks == null) {
      throw StateError('Escribe un nombre válido para la tarea.');
    }
    await tasks.doc(id).update({
      'title': tituloLimpio,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarTarea(String id) async {
    final tasks = _tasksCollection;
    if (tasks == null) throw StateError('No hay una cuenta autenticada.');
    await tasks.doc(id).delete();
  }

  Future<void> cambiarEstadoTarea(String id, EstadoTarea nuevoEstado) async {
    final tasks = _tasksCollection;
    if (tasks == null) throw StateError('No hay una cuenta autenticada.');
    await tasks.doc(id).update({
      'status': nuevoEstado.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void cambiarFiltro(String nuevoFiltro) {
    _filtroActivo = nuevoFiltro;
    notifyListeners();
  }

  List<Tarea> get tareasFiltradas {
    final selectedSubjectId = _selectedSubjectId;
    if (selectedSubjectId == null) return [];

    final tasks = _todasLasTareas.where(
      (task) => task.materiaId == selectedSubjectId,
    );
    if (_filtroActivo == 'Pendientes') {
      return tasks
          .where((task) => task.estado == EstadoTarea.pendiente)
          .toList();
    }
    if (_filtroActivo == 'En proceso') {
      return tasks
          .where((task) => task.estado == EstadoTarea.enProceso)
          .toList();
    }
    if (_filtroActivo == 'Terminadas') {
      return tasks
          .where((task) => task.estado == EstadoTarea.terminada)
          .toList();
    }
    return tasks.toList();
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

  @override
  void dispose() {
    unawaited(_authSubscription.cancel());
    unawaited(_subjectsSubscription?.cancel());
    unawaited(_tasksSubscription?.cancel());
    unawaited(_classesSubscription?.cancel());
    super.dispose();
  }
}
