import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/gasto_model.dart';
import '../routers.dart';
import '../services/gasto_service.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/campo_texto.dart';

/// Pantalla con formulario para registrar o editar un gasto.
/// Diseñada con estética fintech minimalista y adaptable a temas claro y oscuro.
class GastoFormPage extends StatefulWidget {
  final Gasto? gasto;

  const GastoFormPage({super.key, this.gasto});

  @override
  State<GastoFormPage> createState() => _GastoFormPageState();
}

class _GastoFormPageState extends State<GastoFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _montoCtrl;
  late final TextEditingController _descripcionCtrl;

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
    final gasto = widget.gasto;
    _montoCtrl = TextEditingController(
      text: gasto != null ? gasto.monto.toStringAsFixed(2) : '',
    );
    _descripcionCtrl = TextEditingController(text: gasto?.descripcion ?? '');
    _categoriaSeleccionada =
        gasto != null && _categorias.contains(gasto.categoria)
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

  Future<void> _guardarGasto() async {
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
        final gastoActualizado = widget.gasto!.copyWith(
          monto: monto,
          categoria: _categoriaSeleccionada,
          descripcion: _descripcionCtrl.text.trim(),
          fecha: _fechaSeleccionada,
        );
        await GastoService().editar(gastoActualizado);
      } else {
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
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );

      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar el gasto: $e',
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
        await GastoService().eliminar(gasto.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gasto "${gasto.descripcion}" eliminado'),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        );
        context.go(AppRoutes.home);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar el gasto: $e',
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
          _esEdicion ? 'Editar Gasto' : 'Nuevo Gasto',
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
              tooltip: 'Eliminar gasto',
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
                  hintText: 'Ej: 25000',
                  prefixIcon: Icons.monetization_on_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el monto del gasto';
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

                // Selector de Categoría con estilo minimalista del tema
                DropdownButtonFormField<String>(
                  initialValue: _categoriaSeleccionada,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color,
                    labelText: 'Categoría',
                    labelStyle: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.border, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  dropdownColor: Theme.of(context).cardTheme.color,
                  icon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: colors.textSecondary,
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

                // Campo de Descripción reutilizable
                CampoTexto(
                  controller: _descripcionCtrl,
                  labelText: 'Descripción',
                  hintText: 'Ej: Almuerzo universitario, pasajes',
                  prefixIcon: Icons.description_outlined,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa una breve descripción';
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
                      'Fecha del gasto',
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
                    onPressed: _guardando || _eliminando ? null : _guardarGasto,
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
                          : (_esEdicion ? 'Actualizar Gasto' : 'Guardar Gasto'),
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
                        _eliminando ? 'Eliminando...' : 'Eliminar Gasto',
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
