import 'package:flutter/material.dart';
import '../controllers/tareas_controller.dart';
import '../widgets/app_drawer.dart';

class MateriasTareasScreen extends StatefulWidget {
  const MateriasTareasScreen({super.key});

  @override
  State<MateriasTareasScreen> createState() =>
      _MateriasTareasScreenState();
}

class _MateriasTareasScreenState
    extends State<MateriasTareasScreen> {
  final TareasController _controller = TareasController();
  final TextEditingController _inputController =
      TextEditingController();

  static const Color primaryTeal = Color(0xFF1D969F);
  static const Color bgColor = Color(0xFFEBF6F8);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF124B51);

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
                icon: const Icon(
                  Icons.menu,
                  color: primaryTeal,
                  size: 28,
                ),
                tooltip: 'Abrir menú',
                onPressed: () =>
                    Scaffold.of(context).openDrawer(),
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
          drawer: const AppDrawer(
            currentRoute: 'materias',
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderTitle(
                      Icons.school_outlined,
                      'Materias',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: primaryTeal,
                        size: 26,
                      ),
                      tooltip: 'Agregar nueva materia',
                      onPressed: () =>
                          _mostrarDialogoMateria(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildMateriaDropdown(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderTitle(
                      Icons.assignment_outlined,
                      'Tareas',
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onPressed:
                          _controller.materiaSeleccionada == null
                              ? null
                              : () => _mostrarDialogoTarea(
                                    context,
                                  ),
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

  Widget _buildHeaderTitle(
    IconData icon,
    String title,
  ) {
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
          border: Border.all(
            color: primaryTeal.withOpacity(0.3),
          ),
        ),
        child: const Text(
          'No tienes materias. Presiona "+" para agregar una.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _controller.materiaSeleccionada,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: primaryTeal,
                ),
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                items: _controller.materias.map((materia) {
                  return DropdownMenuItem<String>(
                    value: materia,
                    child: Text(materia),
                  );
                }).toList(),
                onChanged: (nuevaMateria) {
                  if (nuevaMateria != null) {
                    _controller.seleccionarMateria(
                      nuevaMateria,
                    );
                  }
                },
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: primaryTeal,
            ),
            onSelected: (opcion) {
              if (opcion == 'editar') {
                _mostrarDialogoMateria(
                  context,
                  esEdicion: true,
                );
              } else if (opcion == 'eliminar') {
                _confirmarEliminarMateria(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 18,
                      color: textDark,
                    ),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
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
    final opciones = [
      'Todas',
      'Pendientes',
      'En proceso',
      'Terminadas',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: opciones.map((opcion) {
          final isSelected =
              _controller.filtroActivo == opcion;

          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ChoiceChip(
              label: Text(
                opcion,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : textDark,
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryTeal,
              backgroundColor: cardColor,
              onSelected: (_) =>
                  _controller.cambiarFiltro(opcion),
            ),
          );
        }).toList(),
      ),
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
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
            const Divider(
              height: 1,
              color: Color(0xFFEEEEEE),
            ),
        itemBuilder: (context, index) {
          final tarea = tareas[index];

          return ListTile(
            leading: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _controller.obtenerColorEstado(
                  tarea.estado,
                ),
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
            trailing: PopupMenuButton<String>(
              tooltip: 'Opciones de tarea',
              onSelected: (opcion) {
                if (opcion == 'pendiente') {
                  _controller.cambiarEstadoTarea(
                    tarea.id,
                    EstadoTarea.pendiente,
                  );
                } else if (opcion == 'enProceso') {
                  _controller.cambiarEstadoTarea(
                    tarea.id,
                    EstadoTarea.enProceso,
                  );
                } else if (opcion == 'terminada') {
                  _controller.cambiarEstadoTarea(
                    tarea.id,
                    EstadoTarea.terminada,
                  );
                } else if (opcion == 'editar') {
                  _mostrarDialogoTarea(
                    context,
                    tareaAEditar: tarea,
                  );
                } else if (opcion == 'eliminar') {
                  _controller.eliminarTarea(tarea.id);
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
                      Text('Editar nombre'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              child: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeyendaEstados() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ItemLeyenda(
            color: Color(0xFFE57373),
            texto: 'Pendiente',
          ),
          _ItemLeyenda(
            color: Color(0xFFFFB74D),
            texto: 'En proceso',
          ),
          _ItemLeyenda(
            color: Color(0xFF81C784),
            texto: 'Terminada',
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoMateria(
    BuildContext context, {
    bool esEdicion = false,
  }) {
    _inputController.text = esEdicion
        ? (_controller.materiaSeleccionada ?? '')
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          esEdicion ? 'Editar Materia' : 'Nueva Materia',
        ),
        content: TextField(
          controller: _inputController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la materia',
          ),
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
                _controller.editarMateriaActual(
                  _inputController.text,
                );
              } else {
                _controller.agregarMateria(
                  _inputController.text,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _controller.eliminarMateriaActual();
              Navigator.pop(context);
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

  void _mostrarDialogoTarea(
    BuildContext context, {
    Tarea? tareaAEditar,
  }) {
    final esEdicion = tareaAEditar != null;

    _inputController.text =
        esEdicion ? tareaAEditar.titulo : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          esEdicion ? 'Editar Tarea' : 'Nueva Tarea',
        ),
        content: TextField(
          controller: _inputController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la tarea',
          ),
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
                );
              } else {
                _controller.agregarTarea(
                  _inputController.text,
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
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String texto;

  const _ItemLeyenda({
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}