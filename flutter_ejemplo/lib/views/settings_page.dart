import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 80),
            const SizedBox(height: 16),
            const Text('Ajustes de la aplicación'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Volver a Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
