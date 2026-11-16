import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Pantalla de perfil de usuario con estética fintech minimalista.
/// Muestra avatar con la inicial, correo, UID y botón de cerrar sesión.
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;
    final email = usuario?.email ?? 'Sin correo registrado';
    final uid = usuario?.uid ?? 'No disponible';
    final inicial = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Avatar minimalista con la inicial del correo
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: colors.greenSecondary.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Correo del usuario
              Text(
                email,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Usuario activo',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // Tarjeta con detalles de la cuenta
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
                        Icons.email_outlined,
                        color: colors.textSecondary,
                        size: 22,
                      ),
                      title: Text(
                        'Correo electrónico',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Divider(color: colors.border, height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.fingerprint_outlined,
                        color: colors.textSecondary,
                        size: 22,
                      ),
                      title: Text(
                        'Identificador de usuario (UID)',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        uid,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Botón ancho para cerrar sesión estilizado con color de error/alerta
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService().salir();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.gasto,
                    side: BorderSide(color: colors.gasto, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout_outlined, size: 20),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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
