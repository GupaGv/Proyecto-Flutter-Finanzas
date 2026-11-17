import 'package:flutter/material.dart';

import '../services/demo_data_service.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/encabezado_seccion.dart';

/// Pantalla de configuración y ajustes de la aplicación "Gestor de Gastos Personales".
/// Opciones agrupadas en secciones con divisores sutiles y estética fintech minimalista.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferenciasService _preferencias = PreferenciasService();
  final DemoDataService _demoService = DemoDataService();

  bool _cargandoDemo = false;
  bool _borrandoDemo = false;

  /// Muestra el diálogo de confirmación para cargar datos de demostración.
  Future<void> _dialogoCargarDemo() async {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cargar datos de demostración'),
        content: const Text(
          'Se generarán ingresos y gastos realistas para los últimos 6 meses '
          'con el fin de visualizar balances y gráficas interactivas.\n\n'
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Theme.of(ctx).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cargar datos'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _cargandoDemo = true);
    try {
      final total = await _demoService.cargarDemo();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se generaron $total registros de demostración exitosamente.',
          ),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos de demostración: $e'),
          backgroundColor: colors.gasto,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cargandoDemo = false);
      }
    }
  }

  /// Muestra el diálogo de confirmación para borrar únicamente los datos demo.
  Future<void> _dialogoBorrarDemo() async {
    final colors = context.appColors;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Borrar datos de demostración'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar los datos de demostración?\n\n'
          'Esta acción borrará únicamente los registros marcados como demo. '
          'Tus registros reales no se verán afectados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.gasto,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar demo'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _borrandoDemo = true);
    try {
      final total = await _demoService.borrarDemo();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            total > 0
                ? 'Se eliminaron $total registros de demostración.'
                : 'No se encontraron datos de demostración para eliminar.',
          ),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al borrar datos de demostración: $e'),
          backgroundColor: colors.gasto,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _borrandoDemo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListenableBuilder(
      listenable: _preferencias,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Configuración',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              children: [
                // Sección 1: Preferencias generales
                const EncabezadoSeccion(titulo: 'Preferencias generales'),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Selector de Moneda
                      ListTile(
                        leading: Icon(
                          Icons.attach_money_outlined,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                        title: const Text(
                          'Moneda principal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _preferencias.moneda,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        trailing: DropdownButton<String>(
                          value: _preferencias.moneda,
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: colors.textSecondary,
                          ),
                          dropdownColor: Theme.of(context).cardTheme.color,
                          items: const [
                            DropdownMenuItem(
                              value: r'COP ($)',
                              child: Text(r'COP ($)'),
                            ),
                            DropdownMenuItem(
                              value: r'USD ($)',
                              child: Text(r'USD ($)'),
                            ),
                            DropdownMenuItem(
                              value: r'EUR (€)',
                              child: Text(r'EUR (€)'),
                            ),
                          ],
                          onChanged: (nuevaMoneda) {
                            if (nuevaMoneda != null) {
                              _preferencias.setMoneda(nuevaMoneda);
                            }
                          },
                        ),
                      ),
                      Divider(color: colors.border, height: 1),

                      // Selector de Modo Oscuro
                      SwitchListTile(
                        secondary: Icon(
                          _preferencias.modoOscuro
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                        title: const Text(
                          'Modo oscuro',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Ajusta la apariencia visual para entornos con poca luz',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        value: _preferencias.modoOscuro,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        onChanged: (valor) {
                          _preferencias.setModoOscuro(valor);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sección 2: Datos de demostración
                const EncabezadoSeccion(titulo: 'Datos de demostración'),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.cloud_upload_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                        title: const Text(
                          'Cargar datos de demostración',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Genera ingresos y gastos de prueba de los últimos 6 meses',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        trailing: _cargandoDemo
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : Icon(
                                Icons.chevron_right_outlined,
                                color: colors.textSecondary,
                                size: 20,
                              ),
                        onTap: (_cargandoDemo || _borrandoDemo)
                            ? null
                            : _dialogoCargarDemo,
                      ),
                      Divider(color: colors.border, height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.delete_sweep_outlined,
                          color: colors.gasto,
                          size: 22,
                        ),
                        title: Text(
                          'Borrar datos de demostración',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.gasto,
                          ),
                        ),
                        subtitle: Text(
                          'Elimina únicamente los registros marcados como demo',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        trailing: _borrandoDemo
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.gasto,
                                ),
                              )
                            : Icon(
                                Icons.chevron_right_outlined,
                                color: colors.textSecondary,
                                size: 20,
                              ),
                        onTap: (_cargandoDemo || _borrandoDemo)
                            ? null
                            : _dialogoBorrarDemo,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sección 3: Información de la aplicación
                const EncabezadoSeccion(titulo: 'Información de la aplicación'),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                        title: const Text(
                          'Aplicación',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Gestor de Gastos Personales',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      Divider(color: colors.border, height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.verified_outlined,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                        title: const Text(
                          'Versión',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
