import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../services/preferencias_service.dart';

/// Pantalla de configuración y ajustes de la aplicación "Gestor de Gastos Personales".
/// Permite modificar y persistir la moneda y el modo oscuro con shared_preferences.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferenciasService _preferencias = PreferenciasService();
  bool _notificacionesActivas = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _preferencias,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configuración'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Volver',
              onPressed: () => context.go(AppRoutes.home),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Preferencias Generales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Selector de Moneda guardada con shared_preferences
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Moneda principal'),
                    subtitle: Text(_preferencias.moneda),
                    trailing: DropdownButton<String>(
                      value: _preferencias.moneda,
                      underline: const SizedBox(),
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
                ),
                const SizedBox(height: 8),

                // Interruptor de notificaciones
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Recordatorios de gastos'),
                    subtitle: const Text('Notificar para registrar gastos diarios'),
                    value: _notificacionesActivas,
                    onChanged: (valor) {
                      setState(() => _notificacionesActivas = valor);
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Interruptor de modo oscuro guardado con shared_preferences
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Modo oscuro'),
                    subtitle: const Text('Aplica tema oscuro en toda la app'),
                    value: _preferencias.modoOscuro,
                    onChanged: (valor) {
                      _preferencias.setModoOscuro(valor);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Información de la App',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Aplicación'),
                        subtitle: Text('Gestor de Gastos Personales'),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.verified_outlined),
                        title: Text('Versión'),
                        subtitle: Text('1.0.0'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Botón para volver a Inicio con context.go
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Volver a Inicio'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
