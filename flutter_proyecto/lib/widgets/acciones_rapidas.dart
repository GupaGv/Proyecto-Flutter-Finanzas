import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../theme/app_theme.dart';

/// Barra de acciones rápidas para registrar un nuevo ingreso o gasto.
class AccionesRapidas extends StatelessWidget {
  const AccionesRapidas({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        // Botón Nuevo Ingreso
        Expanded(
          child: InkWell(
            onTap: () => context.go(AppRoutes.ingresoForm),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colors.greenSecondary.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_downward_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nuevo ingreso',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón Nuevo Gasto
        Expanded(
          child: InkWell(
            onTap: () => context.go(AppRoutes.gastoForm),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colors.gasto.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward_outlined,
                      size: 14,
                      color: colors.gasto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nuevo gasto',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
