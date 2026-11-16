import 'package:flutter/material.dart';

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

                      // Conmutador de Modo Oscuro
                      SwitchListTile(
                        secondary: Icon(
                          Icons.dark_mode_outlined,
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

                // Sección 2: Información de la aplicación
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
