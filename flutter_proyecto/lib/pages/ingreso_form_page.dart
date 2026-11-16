import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ingreso_model.dart';
import '../routers.dart';
import '../services/ingreso_service.dart';
import '../services/preferencias_service.dart';

/// Pantalla con formulario para registrar o editar un ingreso.
/// Si recibe un objeto [ingreso], entra en modo edición; de lo contrario, en modo creación.
class IngresoFormPage extends StatefulWidget {
  final Ingreso? ingreso;

  const IngresoFormPage({super.key, this.ingreso});

  @override
  State<IngresoFormPage> createState() => _IngresoFormPageState();
}

class _IngresoFormPageState extends State<IngresoFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late final TextEditingController _montoCtrl;
  late final TextEditingController _descripcionCtrl;

  late DateTime _fechaSeleccionada;
  bool _guardando = false;
  bool _eliminando = false;

  bool get _esEdicion => widget.ingreso != null;

  @override
  void initState() {
    super.initState();
    final ingreso = widget.ingreso;
    _montoCtrl = TextEditingController(
      text: ingreso != null ? ingreso.monto.toStringAsFixed(2) : '',
    );
    _descripcionCtrl = TextEditingController(text: ingreso?.descripcion ?? '');
    _fechaSeleccionada = ingreso?.fecha ?? DateTime.now();
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
      helpText: 'Seleccionar fecha del ingreso',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fechaElegida != null) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
      });
    }
  }

  /// Guarda el nuevo ingreso o actualiza el existente a través de IngresoService.
  Future<void> _guardarIngreso() async {
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
        // Actualizar ingreso existente
        final ingresoActualizado = widget.ingreso!.copyWith(
          monto: monto,
          descripcion: _descripcionCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
        await IngresoService().editar(ingresoActualizado);
      } else {
        // Crear nuevo ingreso
        final nuevoIngreso = Ingreso(
          monto: monto,
          descripcion: _descripcionCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
        await IngresoService().agregar(nuevoIngreso);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Ingreso actualizado correctamente'
                : 'Ingreso registrado con éxito',
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
          content: Text('Error al guardar el ingreso: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  /// Muestra diálogo de confirmación y elimina el ingreso en modo edición.
  Future<void> _confirmarYEliminar() async {
    final ingreso = widget.ingreso;
    if (ingreso == null) return;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: Text('¿Seguro que deseas eliminar "${ingreso.descripcion}"?'),
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
        await IngresoService().eliminar(ingreso.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ingreso "${ingreso.descripcion}" eliminado'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
        context.go(AppRoutes.home);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el ingreso: $e'),
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
        title: Text(_esEdicion ? 'Editar Ingreso' : 'Nuevo Ingreso'),
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
              tooltip: 'Eliminar ingreso',
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monto (${PreferenciasService().simboloMoneda})',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: const OutlineInputBorder(),
                    hintText: 'Ej: 1500000',
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el monto del ingreso';
                    }
                    final parseado =
                        double.tryParse(valor.replaceAll(',', '.'));
                    if (parseado == null || parseado <= 0) {
                      return 'Ingresa un número válido mayor a 0';
                    }
                    return null;
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
                    hintText: 'Ej: Quincena 15, Venta de producto, Salario',
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa una descripción';
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
                    title: const Text('Fecha del ingreso'),
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
                  onPressed: _guardando || _eliminando ? null : _guardarIngreso,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
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
                        : (_esEdicion ? 'Actualizar Ingreso' : 'Guardar Ingreso'),
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
                      _eliminando ? 'Eliminando...' : 'Eliminar Ingreso',
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
