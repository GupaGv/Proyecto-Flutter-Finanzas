import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../theme/app_theme.dart';

/// Estructura base (Shell) con barra de navegación inferior minimalista.
/// Permite alternar entre Inicio, Estadísticas, Perfil y Ajustes sin romper la navegación declarativa.
class ScaffoldPrincipal extends StatelessWidget {
  final Widget child;

  const ScaffoldPrincipal({super.key, required this.child});

  /// Determina el índice activo según la ruta actual en GoRouter.
  int _calcularIndice(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.estadisticas)) return 1;
    if (location.startsWith(AppRoutes.perfil)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0; // Inicio por defecto
  }

  /// Navega a la ruta correspondiente mediante context.go.
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.estadisticas);
        break;
      case 2:
        context.go(AppRoutes.perfil);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    final indiceActual = _calcularIndice(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border(
            top: BorderSide(color: colors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: indiceActual,
          onDestinationSelected: (i) => _onItemTapped(i, context),
          backgroundColor: Theme.of(context).cardTheme.color,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: colors.greenSecondary.withValues(alpha: 0.35),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: colors.textSecondary,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.home,
                color: primary,
                size: 22,
              ),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.bar_chart_outlined,
                color: colors.textSecondary,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.bar_chart,
                color: primary,
                size: 22,
              ),
              label: 'Estadísticas',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: colors.textSecondary,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.person,
                color: primary,
                size: 22,
              ),
              label: 'Perfil',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
                color: colors.textSecondary,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.settings,
                color: primary,
                size: 22,
              ),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
