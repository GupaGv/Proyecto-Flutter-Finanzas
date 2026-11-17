import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/gasto_model.dart';
import '../theme/app_theme.dart';

/// Widget compacto que muestra un resumen gráfico de barras de los últimos 7 días.
/// Incluye un botón / enlace directo a la pantalla completa de estadísticas.
class ResumenUltimos7Dias extends StatelessWidget {
  final List<Gasto> todosLosGastos;
  final String moneda;
  final VoidCallback onVerEstadisticas;

  const ResumenUltimos7Dias({
    super.key,
    required this.todosLosGastos,
    required this.moneda,
    required this.onVerEstadisticas,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    // Calcular los últimos 7 días terminando en hoy
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final List<DateTime> dias = List.generate(
      7,
      (i) => hoy.subtract(Duration(days: 6 - i)),
    );

    // Sumar gastos por día
    final List<double> montosPorDia = List.generate(7, (i) {
      final dia = dias[i];
      final gastosDelDia = todosLosGastos.where((g) {
        final gDia = DateTime(g.fecha.year, g.fecha.month, g.fecha.day);
        return gDia.isAtSameMomentAs(dia);
      });
      return gastosDelDia.fold<double>(0.0, (sum, g) => sum + g.monto);
    });

    final double totalSieteDias =
        montosPorDia.fold(0.0, (sum, val) => sum + val);
    final double maxMonto =
        montosPorDia.fold(0.0, (maxVal, val) => max(maxVal, val));

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título, total y botón "Ver estadísticas"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Últimos 7 días',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalSieteDias > 0
                        ? 'Total: ${formatearMoneda(totalSieteDias, moneda)}'
                        : 'Sin gastos registrados',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onVerEstadisticas,
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.bar_chart_outlined, size: 16),
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver estadísticas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_outlined, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de barras compacto
          if (totalSieteDias == 0)
            Container(
              height: 90,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_down_outlined,
                    size: 20,
                    color: colors.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No has registrado gastos esta semana',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxMonto > 0 ? maxMonto * 1.15 : 10,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          Theme.of(context).cardTheme.color ?? Colors.grey.shade900,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dia = dias[group.x];
                        final fFecha =
                            DateFormat('E d', 'es_ES').format(dia);
                        return BarTooltipItem(
                          '$fFecha\n',
                          TextStyle(
                            color: colors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: formatearMoneda(rod.toY, moneda),
                              style: TextStyle(
                                color: colors.gasto,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= dias.length) {
                            return const SizedBox.shrink();
                          }
                          final dia = dias[index];
                          final nombreDia =
                              DateFormat('E', 'es_ES').format(dia).toUpperCase();
                          final esHoy = index == 6;

                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              nombreDia.substring(0, min(2, nombreDia.length)),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    esHoy ? FontWeight.w700 : FontWeight.w500,
                                color: esHoy ? primary : colors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final monto = montosPorDia[i];
                    final esMax = maxMonto > 0 && monto == maxMonto;

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: monto,
                          color: esMax
                              ? colors.gasto
                              : (monto > 0
                                  ? primary
                                  : colors.border.withValues(alpha: 0.5)),
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxMonto > 0 ? maxMonto * 1.15 : 10,
                            color: colors.border.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
