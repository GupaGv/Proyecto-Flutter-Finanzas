import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        // AppBar: la barra superior de la pantalla. "title" es lo que
        // se muestra centrado (o a la izquierda en Android) en esa barra.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a tu Gestor de Gastos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.perfil),
              child: const Text('Ir a Perfil'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.settings),
              child: const Text('Ir a Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
