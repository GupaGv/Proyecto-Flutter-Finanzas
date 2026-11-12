import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../services/auth_service.dart';

/// Pantalla de perfil de usuario.
/// Muestra los datos de la cuenta activa sin consultar directamente a Firebase.
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario mediante AuthService.
    final usuario = AuthService().usuarioActual;
    final email = usuario?.email ?? 'Sin correo registrado';
    final uid = usuario?.uid ?? 'No disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Usuario de Gestor de Gastos',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Tarjeta con información detallada de la cuenta
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Correo electrónico'),
                        subtitle: Text(email),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: const Text('Identificador (UID)'),
                        subtitle: Text(
                          uid,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón para volver al Inicio con context.go
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Volver a Inicio'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón para cerrar sesión
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    // Cerrar sesión mediante AuthService.
                    await AuthService().salir();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
