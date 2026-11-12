import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../services/auth_service.dart';

/// Pantalla principal de la aplicación "Gestor de Gastos Personales".
/// Muestra el resumen del usuario, accesos directos y el contenedor principal de gastos.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario a través de AuthService (sin llamar a Firebase directamente).
    final usuario = AuthService().usuarioActual;
    final email = usuario?.email ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Gastos'),
        actions: [
          // Acceso a la pantalla de Configuración
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () => context.go(AppRoutes.settings),
          ),
          // Acceso a la pantalla de Perfil
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Perfil',
            onPressed: () => context.go(AppRoutes.perfil),
          ),
          // Botón para cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              // Cierra la sesión mediante AuthService; GoRouter redirige a /login.
              await AuthService().salir();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tarjeta de bienvenida
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta de balance simulado
          Card(
            color: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance Total',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$ 0.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Controla tus gastos diarios con facilidad',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sección de accesos rápidos
          const Text(
            'Secciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.perfil),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Mi Perfil'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.settings),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Ajustes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Lista de gastos recientes (placeholder para el módulo de Cloud Firestore)
          const Text(
            'Gastos Recientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No hay gastos registrados aún',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Próximamente se sincronizarán tus gastos desde Cloud Firestore (usuarios/{uid}/gastos).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Botón flotante para registrar un nuevo gasto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Módulo de agregar gastos con Firestore pendiente de implementación.',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Gasto'),
      ),
    );
  }
}
