import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controllers/tareas_controller.dart';
import '../widgets/app_drawer.dart';

class MateriasTareasScreen extends StatefulWidget {
  const MateriasTareasScreen({super.key});

  @override
  State<MateriasTareasScreen> createState() => _MateriasTareasScreenState();
}

class _MateriasTareasScreenState extends State<MateriasTareasScreen> {
  final TareasController _controller = TareasController();
  final TextEditingController _inputController = TextEditingController();

  static const Color primaryTeal = Color(0xFF1D969F);
  static const Color bgColor = Color(0xFFEBF6F8);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF124B51);

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
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
              'Materias y Tareas',
              style: TextStyle(
                color: primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
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
          drawer: const AppDrawer(currentRoute: 'materias'),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _controller.errorCarga != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _controller.errorCarga!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _controller.recargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderTitle(Icons.school_outlined, 'Materias'),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: primaryTeal,
                              size: 26,
                            ),
                            tooltip: 'Agregar nueva materia',
                            onPressed: () => _mostrarDialogoMateria(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildMateriaDropdown(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderTitle(
                            Icons.assignment_outlined,
                            'Tareas',
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: _controller.materiaSeleccionada == null
                                ? null
                                : () => _mostrarDialogoTarea(context),
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Tarea',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildFiltroClasificacion(),
                      const SizedBox(height: 12),
                      Expanded(child: _buildListaTareas()),
                      _buildLeyendaEstados(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeaderTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryTeal, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMateriaDropdown() {
    if (_controller.materias.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryTeal.withOpacity(0.3)),
        ),
        child: const Text(
          'No tienes materias. Presiona "+" para agregar una.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryTeal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _controller.materiaIdSeleccionada,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: primaryTeal),
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                items: _controller.materiasPorId.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (materiaId) {
                  if (materiaId != null) {
                    _controller.seleccionarMateria(materiaId);
                  }
                },
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: primaryTeal),
            onSelected: (opcion) {
              if (opcion == 'editar') {
                _mostrarDialogoMateria(context, esEdicion: true);
              } else if (opcion == 'eliminar') {
                _confirmarEliminarMateria(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: textDark),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroClasificacion() {
    final opciones = ['Todas', 'Pendientes', 'En proceso', 'Terminadas'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: opciones.map((opcion) {
          final isSelected = _controller.filtroActivo == opcion;

          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ChoiceChip(
              label: Text(
                opcion,
                style: TextStyle(
                  color: isSelected ? Colors.white : textDark,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryTeal,
              backgroundColor: cardColor,
              onSelected: (_) => _controller.cambiarFiltro(opcion),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _mostrarError(Object error) async {
    if (!mounted) return;
    final message = error is FirebaseException
        ? error.message ?? error.code
        : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo guardar el cambio: $message')),
    );
  }

  Widget _buildListaTareas() {
    final tareas = _controller.tareasFiltradas;

    if (_controller.materiaSeleccionada == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Agrega o selecciona una materia para ver sus tareas.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (tareas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay tareas registradas para esta materia o clasificación.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        itemCount: tareas.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
        itemBuilder: (context, index) {
          final tarea = tareas[index];

          return ListTile(
            leading: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _controller.obtenerColorEstado(tarea.estado),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              tarea.titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
            subtitle: tarea.fechaLimite == null
                ? null
                : Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _formatearFechaLlamativa(tarea.fechaLimite!),
                        style: TextStyle(
                          fontSize: 12,
                          color: tarea.fechaLimite!.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.grey[700],
                          fontWeight: tarea.fechaLimite!.isBefore(DateTime.now())
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Opciones de tarea',
              onSelected: (opcion) async {
                if (opcion == 'pendiente') {
                  try {
                    await _controller.cambiarEstadoTarea(
                      tarea.id,
                      EstadoTarea.pendiente,
                    );
                  } catch (error) {
                    await _mostrarError(error);
                  }
                } else if (opcion == 'enProceso') {
                  try {
                    await _controller.cambiarEstadoTarea(
                      tarea.id,
                      EstadoTarea.enProceso,
                    );
                  } catch (error) {
                    await _mostrarError(error);
                  }
                } else if (opcion == 'terminada') {
                  try {
                    await _controller.cambiarEstadoTarea(
                      tarea.id,
                      EstadoTarea.terminada,
                    );
                  } catch (error) {
                    await _mostrarError(error);
                  }
                } else if (opcion == 'editar') {
                  _mostrarDialogoTarea(context, tareaAEditar: tarea);
                } else if (opcion == 'eliminar') {
                  try {
                    await _controller.eliminarTarea(tarea.id);
                  } catch (error) {
                    await _mostrarError(error);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pendiente',
                  child: Text('🔴 Estado: Pendiente'),
                ),
                const PopupMenuItem(
                  value: 'enProceso',
                  child: Text('🟠 Estado: En proceso'),
                ),
                const PopupMenuItem(
                  value: 'terminada',
                  child: Text('🟢 Estado: Terminada'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Editar tarea'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  String _formatearFechaLlamativa(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora);
    final horaMinuto = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    if (diferencia.isNegative) {
      return 'Fecha límite vencida';
    } else if (diferencia.inDays == 0 && fecha.day == ahora.day) {
      return 'Hoy a las $horaMinuto';
    } else if (diferencia.inDays == 1 || (diferencia.inDays == 0 && fecha.day != ahora.day)) {
      return 'Mañana a las $horaMinuto';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year} a las $horaMinuto';
    }
  }

  Widget _buildLeyendaEstados() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ItemLeyenda(color: Color(0xFFE57373), texto: 'Pendiente'),
          _ItemLeyenda(color: Color(0xFFFFB74D), texto: 'En proceso'),
          _ItemLeyenda(color: Color(0xFF81C784), texto: 'Terminada'),
        ],
      ),
    );
  }

  void _mostrarDialogoMateria(BuildContext context, {bool esEdicion = false}) {
    _inputController.text = esEdicion
        ? (_controller.materiaSeleccionada ?? '')
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? 'Editar Materia' : 'Nueva Materia'),
        content: TextField(
          controller: _inputController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la materia'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
            onPressed: () async {
              try {
                final error = esEdicion
                    ? await _controller.editarMateriaActual(
                        _inputController.text,
                      )
                    : await _controller.agregarMateria(_inputController.text);
                if (error != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error)));
                  }
                  return;
                }
                _inputController.clear();
                if (context.mounted) Navigator.pop(context);
              } catch (error) {
                await _mostrarError(error);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarMateria(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar materia?'),
        content: Text(
          'Se eliminará "${_controller.materiaSeleccionada}" '
          'y todas las tareas asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _controller.eliminarMateriaActual();
                if (context.mounted) Navigator.pop(context);
              } catch (error) {
                await _mostrarError(error);
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoTarea(BuildContext context, {Tarea? tareaAEditar}) {
    final esEdicion = tareaAEditar != null;
    _inputController.text = esEdicion ? tareaAEditar.titulo : '';
    // Variable temporal para capturar la fecha y hora seleccionadas en el diálogo
    DateTime? fechaTemp = tareaAEditar?.fechaLimite;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
            esEdicion ? 'Editar Tarea' : 'Nueva Tarea',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _inputController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Nombre de la tarea',
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18, color: primaryTeal),
                label: Text(
                  fechaTemp == null
                      ? 'Agregar fecha y hora límite'
                      : 'Entrega: ${_formatearFechaLlamativa(fechaTemp!)}',
                  style: const TextStyle(color: textDark, fontSize: 13),
                ),
                onPressed: () async {
                  final fechaSeleccionada = await showDatePicker(
                    context: context,
                    initialDate: fechaTemp ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (fechaSeleccionada != null) {
                    final horaSeleccionada = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(fechaTemp ?? DateTime.now()),
                    );

                    if (horaSeleccionada != null) {
                      setStateDialog(() {
                        fechaTemp = DateTime(
                          fechaSeleccionada.year,
                          fechaSeleccionada.month,
                          fechaSeleccionada.day,
                          horaSeleccionada.hour,
                          horaSeleccionada.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
              ),
              onPressed: () {
                if (esEdicion) {
                  _controller.editarTarea(
                    tareaAEditar.id,
                    _inputController.text,
                    fechaTemp,
                  );
                } else {
                  _controller.agregarTarea(
                    _inputController.text,
                    fechaTemp,
                  );
                }

                _inputController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

    _inputController.text = esEdicion ? tareaAEditar.titulo : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esEdicion ? 'Editar Tarea' : 'Nueva Tarea'),
        content: TextField(
          controller: _inputController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la tarea'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
            onPressed: () async {
              try {
                if (esEdicion) {
                  await _controller.editarTarea(
                    tareaAEditar.id,
                    _inputController.text,
                  );
                } else {
                  await _controller.agregarTarea(_inputController.text);
                }
                _inputController.clear();
                if (context.mounted) Navigator.pop(context);
              } catch (error) {
                await _mostrarError(error);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],

      ),
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String texto;

  const _ItemLeyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
