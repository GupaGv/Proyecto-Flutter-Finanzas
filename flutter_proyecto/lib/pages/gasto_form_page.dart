import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/gasto_model.dart';
import '../routers.dart';
import '../services/gasto_service.dart';
import '../services/preferencias_service.dart';

/// Pantalla con formulario para registrar o editar un gasto.
/// Si recibe un objeto [gasto], entra en modo edición; de lo contrario, en modo creación.
class GastoFormPage extends StatefulWidget {
  final Gasto? gasto;

  const GastoFormPage({super.key, this.gasto});

  @override
  State<GastoFormPage> createState() => _GastoFormPageState();
}

class _GastoFormPageState extends State<GastoFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late final TextEditingController _montoCtrl;
  late final TextEditingController _descripcionCtrl;

  // Categorías disponibles para seleccionar
  static const List<String> _categorias = [
    'Alimentación',
    'Transporte',
    'Vivienda',
    'Servicios',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Ropa',
    'Otros',
  ];

  late String _categoriaSeleccionada;
  late DateTime _fechaSeleccionada;
  bool _guardando = false;
  bool _eliminando = false;

  bool get _esEdicion => widget.gasto != null;

  @override
  void initState() {
    super.initState();
    // Inicializar los campos con los datos del gasto existente o valores predeterminados.
    final gasto = widget.gasto;
    _montoCtrl = TextEditingController(
      text: gasto != null ? gasto.monto.toStringAsFixed(2) : '',
    );
    _descripcionCtrl = TextEditingController(text: gasto?.descripcion ?? '');
    _categoriaSeleccionada = gasto != null && _categorias.contains(gasto.categoria)
        ? gasto.categoria
        : _categorias.first;
    _fechaSeleccionada = gasto?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  /// Abre el selector de fecha nativo de Flutter.
  Future<void> _seleccionarFecha() async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Seleccionar fecha del gasto',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fechaElegida != null) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
      });
    }
  }

  /// Guarda el nuevo gasto o actualiza el existente a través de GastoService.
  Future<void> _guardarGasto() async {
    if (!_formKey.currentState!.validate()) return;

    final double? monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un monto válido mayor a 0.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      if (_esEdicion) {
        // Actualizar gasto existente
        final gastoActualizado = widget.gasto!.copyWith(
          monto: monto,
          categoria: _categoriaSeleccionada,
          descripcion: _descripcionCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
        await GastoService().editar(gastoActualizado);
      } else {
        // Crear nuevo gasto
        final nuevoGasto = Gasto(
          monto: monto,
          categoria: _categoriaSeleccionada,
          descripcion: _descripcionCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
        await GastoService().agregar(nuevoGasto);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Gasto actualizado correctamente'
                : 'Gasto registrado con éxito',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      // Regresamos a la pantalla de Inicio con context.go
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el gasto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  /// Muestra diálogo de confirmación y elimina el gasto en modo edición.
  Future<void> _confirmarYEliminar() async {
    final gasto = widget.gasto;
    if (gasto == null) return;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text('¿Seguro que deseas eliminar "${gasto.descripcion}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      setState(() => _eliminando = true);

      try {
        await GastoService().eliminar(gasto.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gasto "${gasto.descripcion}" eliminado'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
        context.go(AppRoutes.home);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el gasto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _eliminando = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Gasto' : 'Nuevo Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          // Ícono de papelera en la barra superior cuando se está editando
          if (_esEdicion)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Eliminar gasto',
              onPressed:
                  _guardando || _eliminando ? null : _confirmarYEliminar,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de Monto
                TextFormField(
                  controller: _montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monto (${PreferenciasService().simboloMoneda})',
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                    border: const OutlineInputBorder(),
                    hintText: 'Ej: 25000',
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el monto del gasto';
                    }
                    final parseado = double.tryParse(valor.replaceAll(',', '.'));
                    if (parseado == null || parseado <= 0) {
                      return 'Ingresa un número válido mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selector de Categoría (Dropdown)
                DropdownButtonFormField<String>(
                  initialValue: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _categorias.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (nuevaCat) {
                    if (nuevaCat != null) {
                      setState(() => _categoriaSeleccionada = nuevaCat);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Campo de Descripción
                TextFormField(
                  controller: _descripcionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Almuerzo universitario, pasajes de bus',
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa una breve descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selector de Fecha con DatePicker
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Fecha del gasto'),
                    subtitle: Text(
                      '${_fechaSeleccionada.day.toString().padLeft(2, '0')}/'
                      '${_fechaSeleccionada.month.toString().padLeft(2, '0')}/'
                      '${_fechaSeleccionada.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: TextButton.icon(
                      onPressed: _seleccionarFecha,
                      icon: const Icon(Icons.edit_calendar),
                      label: const Text('Cambiar'),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Botón Guardar / Actualizar
                FilledButton.icon(
                  onPressed: _guardando || _eliminando ? null : _guardarGasto,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _guardando
                        ? 'Guardando...'
                        : (_esEdicion ? 'Actualizar Gasto' : 'Guardar Gasto'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Botón Eliminar cuando se está editando
                if (_esEdicion) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed:
                        _guardando || _eliminando ? null : _confirmarYEliminar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _eliminando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(
                      _eliminando ? 'Eliminando...' : 'Eliminar Gasto',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
