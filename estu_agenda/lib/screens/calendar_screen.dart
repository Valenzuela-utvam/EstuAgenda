import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'materias_tareas_screen.dart';
import '../widgets/app_drawer.dart';

class CalendarTask {
  final String id;
  final DateTime date;
  final String title;
  final String subject;

  CalendarTask({
    required this.id,
    required this.date,
    required this.title,
    required this.subject,
  });

  factory CalendarTask.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final date = data['date'];
    if (date is! Timestamp ||
        data['title'] is! String ||
        data['subject'] is! String) {
      throw const FormatException('El evento tiene datos incompletos.');
    }

    return CalendarTask(
      id: document.id,
      date: date.toDate(),
      title: data['title'] as String,
      subject: data['subject'] as String,
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const Color primaryTeal = Color(0xFF1D969F);
  static const Color bgColor = Color(0xFFEBF6F8);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF124B51);

  late DateTime _visibleMonth;
  late final Stream<QuerySnapshot<Map<String, dynamic>>>? _tasksStream;
  List<CalendarTask> _tasks = [];
  CollectionReference<Map<String, dynamic>>? _tasksCollection;

  final List<String> _months = const [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  final List<String> _weekDays = const [
    'LUN',
    'MAR',
    'MIÉ',
    'JUE',
    'VIE',
    'SÁB',
    'DOM',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _tasksStream = null;
    } else {
      _tasksCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('calendarTasks');
      _tasksStream = _tasksCollection!.snapshots();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<CalendarTask> _tasksForDay(DateTime day) {
    return _tasks.where((task) => _isSameDay(task.date, day)).toList();
  }

  List<CalendarTask> get _upcomingTasks {
    final now = DateTime.now();

    final tasks = _tasks
        .where(
          (task) =>
              task.date.isAfter(DateTime(now.year, now.month, now.day - 1)),
        )
        .toList();

    tasks.sort((a, b) => a.date.compareTo(b.date));
    return tasks.take(3).toList();
  }

  void _previousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();

    setState(() {
      _visibleMonth = DateTime(now.year, now.month, 1);
    });
  }

  void _openTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MateriasTareasScreen()),
    );
  }

  Future<void> _addTask() async {
    final collection = _tasksCollection;
    if (collection == null) return;

    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var date = DateTime.now();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          title: const Text('Agregar tarea al calendario'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Tarea'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe el nombre de la tarea.'
                      : null,
                ),
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Materia'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Escribe la materia.'
                      : null,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha'),
                  subtitle: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: dialogContext,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      updateDialog(() => date = selectedDate);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result != true || !mounted) {
      titleController.dispose();
      subjectController.dispose();
      return;
    }

    try {
      await collection.add({
        'title': titleController.text.trim(),
        'subject': subjectController.text.trim(),
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo guardar la tarea: ${error.message ?? error.code}',
            ),
          ),
        );
      }
    } finally {
      titleController.dispose();
      subjectController.dispose();
    }
  }

  Future<void> _deleteTask(CalendarTask task) async {
    final collection = _tasksCollection;
    if (collection == null) return;

    try {
      await collection.doc(task.id).delete();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo eliminar la tarea: ${error.message ?? error.code}',
            ),
          ),
        );
      }
    }
  }

  String _formatTaskDate(DateTime date) {
    return '${date.day} '
        '${_months[date.month - 1].substring(0, 3).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    if (_tasksStream == null) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver tu calendario.')),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _tasksStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar las tareas del calendario. '
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        try {
          _tasks = snapshot.data!.docs.map(CalendarTask.fromDocument).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
        } on FormatException catch (error) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: Text('Datos inválidos en el calendario: $error'),
            ),
          );
        }

        return _buildCalendarView();
      },
    );
  }

  Widget _buildCalendarView() {
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    final firstWeekday = firstDayOfMonth.weekday;
    const totalCells = 42;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: primaryTeal, size: 28),
            tooltip: 'Abrir menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Stuagenda',
          style: TextStyle(
            color: primaryTeal,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
      drawer: const AppDrawer(currentRoute: 'calendar'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: primaryTeal,
                    size: 25,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Calendario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _goToToday,
                    style: TextButton.styleFrom(foregroundColor: primaryTeal),
                    child: const Text(
                      'Hoy',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: _addTask,
                    tooltip: 'Agregar tarea',
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: primaryTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.chevron_left, color: primaryTeal),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${_months[_visibleMonth.month - 1]} '
                          '${_visibleMonth.year}',
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right, color: primaryTeal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _weekDays.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCells,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 50,
                  ),
                  itemBuilder: (context, index) {
                    final dayNumber = index - (firstWeekday - 1);

                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final date = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month,
                      dayNumber,
                    );

                    final dayTasks = _tasksForDay(date);
                    final hasTasks = dayTasks.isNotEmpty;
                    final isToday = _isSameDay(date, now);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _openTasks,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? primaryTeal.withOpacity(0.10)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isToday
                                  ? primaryTeal
                                  : Colors.grey.shade200,
                              width: isToday ? 1.5 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    color: isToday ? primaryTeal : textDark,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (hasTasks)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryTeal.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: primaryTeal,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${dayTasks.length} tarea'
                                          '${dayTasks.length == 1 ? '' : 's'}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: textDark,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: primaryTeal,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Próximas tareas',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _openTasks,
                    style: TextButton.styleFrom(foregroundColor: primaryTeal),
                    child: const Text(
                      'Ver todo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (_upcomingTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'No tienes tareas pendientes',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                ..._upcomingTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _openTasks,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: primaryTeal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: textDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${task.subject} · '
                                      '${_formatTaskDate(task.date)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                tooltip: 'Opciones de tarea',
                                onSelected: (option) {
                                  if (option == 'eliminar') {
                                    _deleteTask(task);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'eliminar',
                                    child: Text('Eliminar tarea'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pending_actions_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_tasks.length} tareas pendientes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _openTasks,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Ver todo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
