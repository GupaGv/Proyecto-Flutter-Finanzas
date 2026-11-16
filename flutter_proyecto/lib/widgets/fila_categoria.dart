import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fila para visualizar una categoría de gasto con su porcentaje y barra de progreso.
class FilaCategoria extends StatelessWidget {
  final String categoria;
  final double monto;
  final double porcentaje; // de 0.0 a 1.0
  final IconData icono;
  final String moneda;
  final bool montosOcultos;

  const FilaCategoria({
    super.key,
    required this.categoria,
    required this.monto,
    required this.porcentaje,
    required this.icono,
    required this.moneda,
    this.montosOcultos = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final valorFormateado =
        montosOcultos ? '••••' : formatearMoneda(monto, moneda);
    final porcentajeTexto = '${(porcentaje * 100).toStringAsFixed(0)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.greenSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icono,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  categoria,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                valorFormateado,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 34,
                child: Text(
                  porcentajeTexto,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: colors.border.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
