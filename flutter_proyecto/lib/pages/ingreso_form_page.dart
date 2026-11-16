import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/ingreso_model.dart';
import '../routers.dart';
import '../services/ingreso_service.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/campo_texto.dart';

/// Pantalla con formulario para registrar o editar un ingreso.
/// Diseñada con estética fintech minimalista y adaptable a temas claro y oscuro.
class IngresoFormPage extends StatefulWidget {
  final Ingreso? ingreso;

  const IngresoFormPage({super.key, this.ingreso});

  @override
  State<IngresoFormPage> createState() => _IngresoFormPageState();
}

class _IngresoFormPageState extends State<IngresoFormPage> {
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _guardarIngreso() async {
    if (!_formKey.currentState!.validate()) return;

    final double? monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor ingresa un monto válido mayor a 0.',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: context.appColors.gasto,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      if (_esEdicion) {
        final ingresoActualizado = widget.ingreso!.copyWith(
          monto: monto,
          descripcion: _descripcionCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
        await IngresoService().editar(ingresoActualizado);
      } else {
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
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );

      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar el ingreso: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: context.appColors.gasto,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

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
              backgroundColor: context.appColors.gasto,
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
            backgroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        );
        context.go(AppRoutes.home);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar el ingreso: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: context.appColors.gasto,
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
    final colors = context.appColors;
    final pref = PreferenciasService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar Ingreso' : 'Nuevo Ingreso',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          tooltip: 'Volver',
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          if (_esEdicion)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.gasto),
              tooltip: 'Eliminar ingreso',
              onPressed:
                  _guardando || _eliminando ? null : _confirmarYEliminar,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de Monto reutilizable
                CampoTexto(
                  controller: _montoCtrl,
                  labelText: 'Monto (${pref.simboloMoneda})',
                  hintText: 'Ej: 1500000',
                  prefixIcon: Icons.attach_money_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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

                // Campo de Descripción reutilizable
                CampoTexto(
                  controller: _descripcionCtrl,
                  labelText: 'Descripción',
                  hintText: 'Ej: Quincena 15, Salario, Bono',
                  prefixIcon: Icons.description_outlined,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selector de Fecha estilizado con el tema
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      'Fecha del ingreso',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${_fechaSeleccionada.day.toString().padLeft(2, '0')}/'
                      '${_fechaSeleccionada.month.toString().padLeft(2, '0')}/'
                      '${_fechaSeleccionada.year}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: _seleccionarFecha,
                      child: Text(
                        'Cambiar',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Botón Guardar principal con color primario
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed:
                        _guardando || _eliminando ? null : _guardarIngreso,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _guardando
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(
                      _guardando
                          ? 'Guardando...'
                          : (_esEdicion ? 'Actualizar Ingreso' : 'Guardar Ingreso'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Botón Eliminar en color de error
                if (_esEdicion) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed:
                          _guardando || _eliminando ? null : _confirmarYEliminar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.gasto,
                        side: BorderSide(color: colors.gasto, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _eliminando
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.gasto,
                              ),
                            )
                          : const Icon(Icons.delete_outline, size: 20),
                      label: Text(
                        _eliminando ? 'Eliminando...' : 'Eliminar Ingreso',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
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
