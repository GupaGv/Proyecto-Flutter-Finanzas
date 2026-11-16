import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta principal de saldo con estética fintech minimalista.
/// Muestra el balance disponible y los totales de ingresos y gastos del período,
/// con opción de alternar la visibilidad de los montos (••••).
class TarjetaSaldo extends StatelessWidget {
  final double disponible;
  final double totalIngresos;
  final double totalGastos;
  final String moneda;
  final bool montosOcultos;
  final VoidCallback onToggleVisibilidad;

  const TarjetaSaldo({
    super.key,
    required this.disponible,
    required this.totalIngresos,
    required this.totalGastos,
    required this.moneda,
    required this.montosOcultos,
    required this.onToggleVisibilidad,
  });

  String _formatearValor(double valor) {
    if (montosOcultos) return '••••';
    return formatearMoneda(valor, moneda);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.saldoCardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Título "Disponible" y botón para ocultar/mostrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disponible este mes',
                style: TextStyle(
                  color: colors.saldoCardSubtext,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              IconButton(
                icon: Icon(
                  montosOcultos
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.saldoCardSubtext,
                  size: 20,
                ),
                tooltip: montosOcultos ? 'Mostrar montos' : 'Ocultar montos',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onToggleVisibilidad,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Monto grande del balance disponible
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatearValor(disponible),
              style: TextStyle(
                color: colors.saldoCardText,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Fila inferior: Ingresos y Gastos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Sección de Ingresos
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingresos',
                              style: TextStyle(
                                color: colors.saldoCardSubtext,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatearValor(totalIngresos),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withValues(alpha: 0.15),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                // Sección de Gastos
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gastos',
                              style: TextStyle(
                                color: colors.saldoCardSubtext,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _formatearValor(totalGastos),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
