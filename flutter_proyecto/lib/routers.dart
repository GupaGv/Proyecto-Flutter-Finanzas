import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'models/gasto_model.dart';
import 'models/ingreso_model.dart';
import 'pages/estadisticas_page.dart';
import 'pages/gasto_form_page.dart';
import 'pages/home_page.dart';
import 'pages/ingreso_form_page.dart';
import 'pages/login_page.dart';
import 'pages/perfil_page.dart';
import 'pages/register_page.dart';
import 'pages/settings_page.dart';
import 'services/auth_service.dart';
import 'widgets/scaffold_principal.dart';

/// Rutas nombradas de la aplicación para evitar errores de escritura manual.
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String estadisticas = '/estadisticas';
  static const String perfil = '/perfil';
  static const String settings = '/settings';
  static const String gastoForm = '/gasto-form';
  static const String ingresoForm = '/ingreso-form';
}

/// Notificador que avisa a GoRouter cuando el estado de autenticación cambia
/// (por ejemplo, cuando el usuario inicia o cierra sesión).
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    // Escucha el stream de autenticación provisto por AuthService.
    _sub = AuthService().cambiosDeAutenticacion.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = AuthNotifier();

/// Configuración central de navegación mediante GoRouter con ShellRoute para barra inferior.
/// Controla la redirección automática según el estado de la sesión en Firebase.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    // Verificamos si existe un usuario autenticado mediante AuthService.
    final bool logueado = AuthService().estaAutenticado;

    // Determinamos si la ruta a la que se intenta acceder es de autenticación.
    final bool enRutaAuth =
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;

    // Si el usuario no ha iniciado sesión y quiere entrar a una pantalla protegida,
    // se le redirige a la pantalla de login.
    if (!logueado && !enRutaAuth) {
      return AppRoutes.login;
    }

    // Si el usuario ya está autenticado e intenta ir a login o registro,
    // se le redirige a la pantalla principal.
    if (logueado && enRutaAuth) {
      return AppRoutes.home;
    }

    // Si no aplica ninguna redirección, se permite el acceso normal.
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    // ShellRoute que provee la barra de navegación inferior para Inicio, Perfil y Ajustes
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldPrincipal(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.estadisticas,
          builder: (context, state) => const EstadisticasPage(),
        ),
        GoRoute(
          path: AppRoutes.perfil,
          builder: (context, state) => const PerfilPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
    // Formularios independientes con AppBar completo
    GoRoute(
      path: AppRoutes.gastoForm,
      builder: (context, state) {
        final gasto = state.extra as Gasto?;
        return GastoFormPage(gasto: gasto);
      },
    ),
    GoRoute(
      path: AppRoutes.ingresoForm,
      builder: (context, state) {
        final ingreso = state.extra as Ingreso?;
        return IngresoFormPage(ingreso: ingreso);
      },
    ),
  ],
);
