import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WearableSyncService {
  static const _channel = MethodChannel('estuagenda/wearable');
  static const _defaultReminderLeadMinutes = 1440;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _subjectsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _calendarSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _settingsSubscription;

  String? _userId;
  bool _isBound = false;
  bool _hasTasks = false;
  bool _hasSubjects = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _taskDocuments = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _calendarDocuments = [];
  Map<String, String> _subjectNames = {};
  int _reminderLeadMinutes = _defaultReminderLeadMinutes;
  Future<void> _sendQueue = Future<void>.value();

  Future<void> setUser(String? userId) async {
    if (_isBound && userId == _userId) return;
    _isBound = true;
    _userId = userId;
    final oldSubscriptions = [
      _tasksSubscription,
      _subjectsSubscription,
      _calendarSubscription,
      _settingsSubscription,
    ];
    _tasksSubscription = null;
    _subjectsSubscription = null;
    _calendarSubscription = null;
    _settingsSubscription = null;
    await Future.wait(
      oldSubscriptions.map((subscription) async {
        await subscription?.cancel();
      }),
    );
    if (userId != _userId) return;

    _hasTasks = false;
    _hasSubjects = false;
    _taskDocuments = [];
    _calendarDocuments = [];
    _subjectNames = {};
    _reminderLeadMinutes = _defaultReminderLeadMinutes;

    if (userId == null) {
      await _send(signedIn: false, tasks: const []);
      return;
    }

    await _send(signedIn: true, tasks: const []);

    final user = FirebaseFirestore.instance.collection('users').doc(userId);
    _tasksSubscription = user
        .collection('tasks')
        .snapshots()
        .listen(
          (snapshot) {
            if (userId != _userId) return;
            _taskDocuments = snapshot.docs;
            _hasTasks = true;
            _sendCurrentTasks();
          },
          onError: (Object error) {
            debugPrint('Wear OS: falló la lectura de tareas: $error');
            if (userId != _userId) return;
            _hasTasks = true;
            _sendCurrentTasks();
          },
        );
    _subjectsSubscription = user
        .collection('subjects')
        .snapshots()
        .listen(
          (snapshot) {
            if (userId != _userId) return;
            final subjects = <String, String>{};
            for (final document in snapshot.docs) {
              final name = document.data()['name'];
              if (name is! String || name.trim().isEmpty) {
                debugPrint('Wear OS: una materia tiene un nombre inválido.');
                return;
              }
              subjects[document.id] = name.trim();
            }
            _subjectNames = subjects;
            _hasSubjects = true;
            _sendCurrentTasks();
          },
          onError: (Object error) {
            debugPrint('Wear OS: falló la lectura de materias: $error');
            if (userId != _userId) return;
            _hasSubjects = true;
            _sendCurrentTasks();
          },
        );
    _calendarSubscription = user
        .collection('calendarTasks')
        .snapshots()
        .listen(
          (snapshot) {
            if (userId != _userId) return;
            _calendarDocuments = snapshot.docs;
            _sendCurrentTasks();
          },
          onError: (Object error) {
            debugPrint('Wear OS: falló la lectura del calendario: $error');
            if (userId != _userId) return;
            _sendCurrentTasks();
          },
        );
    _settingsSubscription = user
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .listen(
          (snapshot) {
            if (userId != _userId) return;
            final value = snapshot.data()?['reminderLeadMinutes'];
            _reminderLeadMinutes =
                value is int &&
                    const {10, 15, 30, 60, 120, 180, 240, 1440}.contains(value)
                ? value
                : _defaultReminderLeadMinutes;
            _sendCurrentTasks();
          },
          onError: (Object error) {
            debugPrint(
              'Wear OS: no se pudo leer la anticipación configurada; '
              'se usará 1 día antes. $error',
            );
            if (userId != _userId) return;
            _reminderLeadMinutes = _defaultReminderLeadMinutes;
            _sendCurrentTasks();
          },
        );
  }

  void _sendCurrentTasks() {
    if (!_hasTasks || !_hasSubjects || _userId == null) {
      return;
    }

    try {
      final now = DateTime.now();
      final tasks = <Map<String, Object>>[];
      for (final document in _taskDocuments) {
        final data = document.data();
        final dueAt = data['dueAt'];
        final title = data['title'];
        final subjectId = data['subjectId'];
        final status = data['status'];
        if ((dueAt != null && dueAt is! Timestamp) ||
            title is! String ||
            subjectId is! String ||
            status is! String) {
          throw const FormatException(
            'Una tarea tiene datos incompletos para sincronizar.',
          );
        }
        if (status == 'terminada') continue;

        tasks.add(
          _watchTask(
            id: 'task-${document.id}',
            title: title,
            subject: _subjectNames[subjectId] ?? 'Materia',
            status: status,
            dueAt: (dueAt as Timestamp?)?.toDate(),
            now: now,
          ),
        );
      }

      for (final document in _calendarDocuments) {
        final data = document.data();
        final dueAt = data['date'];
        final title = data['title'];
        final subject = data['subject'];
        if (dueAt is! Timestamp || title is! String || subject is! String) {
          throw const FormatException(
            'Un evento del calendario tiene datos inválidos.',
          );
        }
        final dueDate = dueAt.toDate();
        final calendarDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
        final today = DateTime(now.year, now.month, now.day);
        if (calendarDay.isBefore(today)) continue;
        tasks.add(
          _watchTask(
            id: 'calendar-${document.id}',
            title: title,
            subject: subject,
            status: 'calendar',
            dueAt: dueDate,
            now: now,
          ),
        );
      }

      tasks.sort((a, b) {
        final firstDueAt = a['dueAt'] as int;
        final secondDueAt = b['dueAt'] as int;
        if (firstDueAt == 0) return secondDueAt == 0 ? 0 : 1;
        if (secondDueAt == 0) return -1;
        return firstDueAt.compareTo(secondDueAt);
      });
      unawaited(_send(signedIn: true, tasks: tasks));
    } on FormatException catch (error) {
      debugPrint('Wear OS: no se sincronizaron las tareas: $error');
    }
  }

  Map<String, Object> _watchTask({
    required String id,
    required String title,
    required String subject,
    required String status,
    required DateTime? dueAt,
    required DateTime now,
  }) {
    final dueAtMillis = dueAt?.millisecondsSinceEpoch ?? 0;
    final reminderAtMillis = dueAt == null
        ? 0
        : dueAtMillis - _reminderLeadMinutes * 60000;
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'status': status,
      'dueAt': dueAtMillis,
      'remindAt': dueAt != null && reminderAtMillis < now.millisecondsSinceEpoch
          ? now.millisecondsSinceEpoch
          : reminderAtMillis,
    };
  }

  Future<void> _send({
    required bool signedIn,
    required List<Map<String, Object>> tasks,
  }) async {
    final payload = jsonEncode({'signedIn': signedIn, 'tasks': tasks});
    final previousSend = _sendQueue;
    final currentSend = previousSend.then((_) => _sendPayload(payload));
    _sendQueue = currentSend;
    await currentSend;
  }

  Future<void> _sendPayload(String payload) async {
    try {
      await _channel.invokeMethod<void>('syncUpcomingTasks', {
        'payload': payload,
      });
    } on PlatformException catch (error) {
      debugPrint(
        'Wear OS: no se pudo enviar la sincronización: ${error.message}',
      );
    } on MissingPluginException catch (error) {
      debugPrint('Wear OS: el puente nativo no está disponible: $error');
    }
  }

  Future<void> dispose() async {
    _userId = null;
    final subscriptions = [
      _tasksSubscription,
      _subjectsSubscription,
      _calendarSubscription,
      _settingsSubscription,
    ];
    _tasksSubscription = null;
    _subjectsSubscription = null;
    _calendarSubscription = null;
    _settingsSubscription = null;
    await Future.wait(
      subscriptions.map((subscription) async {
        await subscription?.cancel();
      }),
    );
  }
}
