import 'package:flutter/material.dart';
import '../controllers/tareas_controller.dart';
import '../widgets/app_drawer.dart';
import 'materias_tareas_screen.dart';

class HorarioScreen extends StatelessWidget {
  const HorarioScreen({super.key});

  static const Color primaryTeal = Color(0xFF1D969F);
  static const Color bgColor = Color(0xFFEBF6F8);
  static const Color textDark = Color(0xFF124B51);

  static const _dias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves',
    'Viernes', 'Sábado', 'Domingo',
  ];

  Future<void> _agregarClase(BuildContext context) async {
    final controller = TareasController();

    if (controller.materias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero agrega una materia en “Materias y Tareas”.',
          ),
        ),
      );
      return;
    }

    String materia = controller.materias.first;
    int dia = 1;
    TimeOfDay inicio = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay fin = const TimeOfDay(hour: 9, minute: 0);
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, actualizar) => AlertDialog(
          title: const Text('Agregar clase'),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: materia,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                    ),
                    items: controller.materias.map((nombre) {
                      return DropdownMenuItem(
                        value: nombre,
                        child: Text(nombre),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        actualizar(() => materia = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: dia,
                    decoration: const InputDecoration(
                      labelText: 'Día',
                    ),
                    items: List.generate(7, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_dias[index]),
                      );
                    }),
                    onChanged: (valor) {
                      if (valor != null) {
                        actualizar(() => dia = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hora de inicio'),
                    trailing: Text(inicio.format(context)),
                    onTap: () async {
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: inicio,
                      );
                      if (hora != null && context.mounted) {
                        actualizar(() => inicio = hora);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hora de fin'),
                    trailing: Text(fin.format(context)),
                    onTap: () async {
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: fin,
                      );
                      if (hora != null && context.mounted) {
                        actualizar(() => fin = hora);
                      }
                    },
                  ),
                  if (error != null)
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final mensaje = controller.agregarClase(
                  materia: materia,
                  dia: dia,
                  inicio: inicio,
                  fin: fin,
                );

                if (mensaje != null) {
                  actualizar(() => error = mensaje);
                  return;
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  String _hora(int minutos) {
    final horas = (minutos ~/ 60).toString().padLeft(2, '0');
    final resto = (minutos % 60).toString().padLeft(2, '0');
    return '$horas:$resto';
  }

  @override
  Widget build(BuildContext context) {
    final controller = TareasController();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: primaryTeal,
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: primaryTeal,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Inicio (Mi Horario)',
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: primaryTeal,
              size: 28,
            ),
            tooltip: 'Agregar Materias / Tareas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MateriasTareasScreen(),
                ),
              );
            },
          ),
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
      drawer: const AppDrawer(currentRoute: 'horario'),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final clases = controller.clases;
          int primeraHora = 8;
          int ultimaHora = 14;

          if (clases.isNotEmpty) {
            primeraHora = clases
                .map((clase) => clase.inicio.hour)
                .reduce((a, b) => a < b ? a : b);

            ultimaHora = clases.map((clase) {
              return clase.fin.hour +
                  (clase.fin.minute > 0 ? 1 : 0);
            }).reduce((a, b) => a > b ? a : b);
          }

          final altura = (ultimaHora - primeraHora) * 80.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mi horario semanal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _agregarClase(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar clase'),
                    ),
                    const SizedBox(height: 12),
                    if (clases.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Agrega tus materias y después asigna '
                          'sus clases aquí.',
                        ),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 1050,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 70),
                                ..._dias.map(
                                  (dia) => SizedBox(
                                    width: 140,
                                    height: 44,
                                    child: Center(
                                      child: Text(
                                        dia,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: altura,
                              child: Stack(
                                children: [
                                  for (int hora = primeraHora;
                                      hora < ultimaHora;
                                      hora++)
                                    Positioned(
                                      top: (hora - primeraHora) * 80.0,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 70,
                                            child: Text(_hora(hora * 60)),
                                          ),
                                          const Expanded(
                                            child: Divider(height: 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  for (final clase in clases)
                                    Positioned(
                                      left: 70 +
                                          (clase.dia - 1) * 140.0 +
                                          3,
                                      top: (
                                        (clase.inicio.hour -
                                                    primeraHora) *
                                                60 +
                                            clase.inicio.minute
                                      ) * 80 / 60,
                                      width: 134,
                                      height: (
                                        (clase.fin.hour -
                                                    clase.inicio.hour) *
                                                60 +
                                            clase.fin.minute -
                                            clase.inicio.minute
                                      ) * 80 / 60,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 2,
                                        ),
                                        child: Material(
                                          color: const Color(0xFFBEE6E8),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: () => showDialog<void>(
                                              context: context,
                                              builder: (dialogContext) =>
                                                  AlertDialog(
                                                title: Text(clase.materia),
                                                content: Text(
                                                  '${_dias[clase.dia - 1]}\n'
                                                  '${clase.inicio.format(context)}'
                                                  ' – ${clase.fin.format(context)}',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                      dialogContext,
                                                    ),
                                                    child: const Text('Cerrar'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      controller.eliminarClase(
                                                        clase.id,
                                                      );
                                                      Navigator.pop(
                                                        dialogContext,
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Eliminar clase',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            child: SingleChildScrollView(
                                              padding:
                                                  const EdgeInsets.all(6),
                                              child: Text(
                                                '${clase.materia}\n'
                                                '${_hora(clase.inicio.hour * 60 + clase.inicio.minute)}'
                                                '–${_hora(clase.fin.hour * 60 + clase.fin.minute)}',
                                                style: const TextStyle(
                                                  color: Color(0xFF124B51),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}