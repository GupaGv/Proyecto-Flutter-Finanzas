import 'package:go_router/go_router.dart';

import 'views/login_page.dart';
import 'views/home_page.dart';
import 'views/perfil_page.dart';
import 'views/settings_page.dart';

// Constantes con los nombres de las rutas, para no escribir el string
// "/home" a mano en cada lugar del código (evita errores de tipeo).
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String perfil = '/perfil';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  // initialLocation: la ruta con la que arranca la app al abrirla.

  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
      // builder: qué widget se construye cuando el usuario está en esta ruta.
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
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
);
