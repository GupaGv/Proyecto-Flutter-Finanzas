import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/gasto_model.dart';
import '../models/ingreso_model.dart';
import '../services/gasto_service.dart';
import '../services/ingreso_service.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/encabezado_seccion.dart';

/// Pantalla de análisis y estadísticas interactivas con estética fintech minimalista.
/// Incluye:
/// a) "Gasto por día": gráfico de barras con rango de fechas, resaltando mayor y menor gasto.
/// b) "Gastos por categoría": gráfico de dona interactivo por mes con porcentajes.
/// c) "Ingresos vs gastos": gráfico de barras agrupadas comparativo de los últimos 6 meses.
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final GastoService _gastoService = GastoService();
  final IngresoService _ingresoService = IngresoService();

  // Rango para "Gasto por día" (por defecto últimos 7 días)
  late DateTimeRange _rangoFechas;

  // Mes seleccionado para "Gastos por categoría"
  late DateTime _mesCategoria;

  // Índice tocado en el gráfico de dona
  int _categoriaTocadaIndex = -1;

  static const List<String> _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    _rangoFechas = DateTimeRange(
      start: hoy.subtract(const Duration(days: 6)),
      end: hoy,
    );
    _mesCategoria = DateTime(ahora.year, ahora.month, 1);
  }

  void _mesAnterior() {
    setState(() {
      _mesCategoria = DateTime(
        _mesCategoria.year,
        _mesCategoria.month - 1,
        1,
      );
      _categoriaTocadaIndex = -1;
    });
  }

  void _mesSiguiente() {
    setState(() {
      _mesCategoria = DateTime(
        _mesCategoria.year,
        _mesCategoria.month + 1,
        1,
      );
      _categoriaTocadaIndex = -1;
    });
  }

  Future<void> _seleccionarRangoFechas() async {
    final DateTime ahora = DateTime.now();
    final DateTimeRange? nuevoRango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(ahora.year + 2),
      initialDateRange: _rangoFechas,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (nuevoRango != null) {
      setState(() {
        _rangoFechas = nuevoRango;
      });
    }
  }

  /// Paleta armónica de colores para el gráfico de dona por categoría.
  Color _obtenerColorCategoria(int index, AppColorsExtension colors, Color primary) {
    final List<Color> paleta = [
      primary,
      colors.greenSecondary,
      colors.gasto,
      const Color(0xFF3D8B7A),
      const Color(0xFFE09F3E),
      const Color(0xFF5E548E),
      const Color(0xFF3F88C5),
      const Color(0xFF9A8C98),
      const Color(0xFF588157),
    ];
    return paleta[index % paleta.length];
  }

  @override
  Widget build(BuildContext context) {
    final pref = PreferenciasService();
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: pref,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Estadísticas',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: StreamBuilder<List<Gasto>>(
            stream: _gastoService.obtenerGastos(),
            builder: (context, snapshotGastos) {
              return StreamBuilder<List<Ingreso>>(
                stream: _ingresoService.obtenerIngresos(),
                builder: (context, snapshotIngresos) {
                  if (snapshotGastos.connectionState ==
                          ConnectionState.waiting &&
                      !snapshotGastos.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final todosLosGastos = snapshotGastos.data ?? [];
                  final todosLosIngresos = snapshotIngresos.data ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // a) Sección "Gasto por día"
                        _construirSeccionGastoPorDia(
                          todosLosGastos,
                          pref.moneda,
                          colors,
                          primary,
                        ),
                        const SizedBox(height: 28),

                        // b) Sección "Gastos por categoría"
                        _construirSeccionGastosPorCategoria(
                          todosLosGastos,
                          pref.moneda,
                          colors,
                          primary,
                        ),
                        const SizedBox(height: 28),

                        // c) Sección "Ingresos vs gastos"
                        _construirSeccionIngresosVsGastos(
                          todosLosGastos,
                          todosLosIngresos,
                          pref.moneda,
                          colors,
                          primary,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // a) Gasto por día
  // ===========================================================================
  Widget _construirSeccionGastoPorDia(
    List<Gasto> todosLosGastos,
    String moneda,
    AppColorsExtension colors,
    Color primary,
  ) {
    final inicio = DateTime(
      _rangoFechas.start.year,
      _rangoFechas.start.month,
      _rangoFechas.start.day,
    );
    final fin = DateTime(
      _rangoFechas.end.year,
      _rangoFechas.end.month,
      _rangoFechas.end.day,
    );
    final int cantidadDias = fin.difference(inicio).inDays + 1;

    final List<DateTime> listaDias = List.generate(
      cantidadDias,
      (i) => inicio.add(Duration(days: i)),
    );

    // Mapeo y suma de gastos por fecha
    final Map<DateTime, double> gastoPorFecha = {};
    for (final dia in listaDias) {
      gastoPorFecha[dia] = 0.0;
    }
    for (final g in todosLosGastos) {
      final gDia = DateTime(g.fecha.year, g.fecha.month, g.fecha.day);
      if (gastoPorFecha.containsKey(gDia)) {
        gastoPorFecha[gDia] = gastoPorFecha[gDia]! + g.monto;
      }
    }

    final double totalRango =
        gastoPorFecha.values.fold(0.0, (sum, val) => sum + val);
    final double promedioDiario =
        cantidadDias > 0 ? (totalRango / cantidadDias) : 0.0;

    // Identificar día de mayor y menor gasto
    DateTime? diaMayorGasto;
    double mayorGasto = -1;
    DateTime? diaMenorGasto;
    double menorGasto = double.infinity;

    final diasConGasto =
        gastoPorFecha.entries.where((e) => e.value > 0).toList();

    if (diasConGasto.isNotEmpty) {
      for (final entry in diasConGasto) {
        if (entry.value > mayorGasto) {
          mayorGasto = entry.value;
          diaMayorGasto = entry.key;
        }
        if (entry.value < menorGasto) {
          menorGasto = entry.value;
          diaMenorGasto = entry.key;
        }
      }
    } else {
      mayorGasto = 0;
      menorGasto = 0;
    }

    final String formatoRango =
        '${DateFormat('d MMM', 'es_ES').format(inicio)} - ${DateFormat('d MMM yyyy', 'es_ES').format(fin)}';

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con selector de rango de fechas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EncabezadoSeccion(titulo: 'Gasto por día'),
              OutlinedButton.icon(
                onPressed: _seleccionarRangoFechas,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: colors.border),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.date_range_outlined, size: 15),
                label: Text(
                  formatoRango,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de barras interactivo
          if (totalRango == 0)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 36,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay gastos registrados en este período',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: mayorGasto > 0 ? mayorGasto * 1.25 : 10,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          Theme.of(context).cardTheme.color ??
                          Colors.grey.shade900,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dia = listaDias[group.x];
                        final fFecha =
                            DateFormat('EEEE d MMMM', 'es_ES').format(dia);
                        return BarTooltipItem(
                          '${fFecha[0].toUpperCase()}${fFecha.substring(1)}\n',
                          TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: formatearMoneda(rod.toY, moneda),
                              style: TextStyle(
                                color: (mayorGasto > 0 &&
                                        rod.toY == mayorGasto)
                                    ? colors.gasto
                                    : primary,
                                fontSize: 13,
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
                        reservedSize: 26,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= listaDias.length) {
                            return const SizedBox.shrink();
                          }
                          // Si hay demasiados días, mostrar etiquetas espaciadas
                          if (listaDias.length > 10 &&
                              index % (listaDias.length ~/ 6) != 0 &&
                              index != listaDias.length - 1) {
                            return const SizedBox.shrink();
                          }
                          final dia = listaDias[index];
                          final label = DateFormat('d MMM', 'es_ES').format(dia);

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        mayorGasto > 0 ? (mayorGasto / 4) : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colors.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(listaDias.length, (i) {
                    final dia = listaDias[i];
                    final monto = gastoPorFecha[dia] ?? 0.0;
                    final bool esMayor =
                        mayorGasto > 0 && monto == mayorGasto;
                    final bool esMenor =
                        diasConGasto.length > 1 &&
                            menorGasto > 0 &&
                            monto == menorGasto;

                    Color colorBarra;
                    if (monto == 0) {
                      colorBarra = colors.border.withValues(alpha: 0.3);
                    } else if (esMayor) {
                      colorBarra = colors.gasto;
                    } else if (esMenor) {
                      colorBarra = colors.greenSecondary;
                    } else {
                      colorBarra = primary;
                    }

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: monto,
                          color: colorBarra,
                          width: max(
                              6.0,
                              min(22.0, 220.0 / listaDias.length)),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Leyenda de colores explicativa
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _indicadorColor(colors.gasto, 'Día más alto'),
                const SizedBox(width: 16),
                _indicadorColor(colors.greenSecondary, 'Día más bajo'),
                const SizedBox(width: 16),
                _indicadorColor(primary, 'Otros días'),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 16),

          // Métricas resumen: total, promedio diario, día más caro y día más barato
          LayoutBuilder(
            builder: (context, constraints) {
              final double tarjetaAncho =
                  (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _tarjetaMetrica(
                    ancho: tarjetaAncho,
                    titulo: 'Total período',
                    valor: formatearMoneda(totalRango, moneda),
                    icono: Icons.payments_outlined,
                    colors: colors,
                  ),
                  _tarjetaMetrica(
                    ancho: tarjetaAncho,
                    titulo: 'Promedio diario',
                    valor: formatearMoneda(promedioDiario, moneda),
                    icono: Icons.calendar_view_day_outlined,
                    colors: colors,
                  ),
                  _tarjetaMetrica(
                    ancho: tarjetaAncho,
                    titulo: 'Día más caro',
                    valor: diaMayorGasto != null && mayorGasto > 0
                        ? '${DateFormat('d MMM', 'es_ES').format(diaMayorGasto)} (${formatearMoneda(mayorGasto, moneda)})'
                        : 'Sin gastos',
                    icono: Icons.arrow_upward_outlined,
                    colorIcono: colors.gasto,
                    colors: colors,
                  ),
                  _tarjetaMetrica(
                    ancho: tarjetaAncho,
                    titulo: 'Día más barato',
                    valor: diaMenorGasto != null && menorGasto > 0
                        ? '${DateFormat('d MMM', 'es_ES').format(diaMenorGasto)} (${formatearMoneda(menorGasto, moneda)})'
                        : 'Sin gastos',
                    icono: Icons.arrow_downward_outlined,
                    colorIcono: colors.greenSecondary,
                    colors: colors,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // b) Gastos por categoría (Dona interactiva)
  // ===========================================================================
  Widget _construirSeccionGastosPorCategoria(
    List<Gasto> todosLosGastos,
    String moneda,
    AppColorsExtension colors,
    Color primary,
  ) {
    final nombreMes = _meses[_mesCategoria.month - 1];
    final anio = _mesCategoria.year;

    // Filtrar gastos por el mes seleccionado
    final gastosMes = todosLosGastos.where((g) {
      return g.fecha.year == _mesCategoria.year &&
          g.fecha.month == _mesCategoria.month;
    }).toList();

    // Agrupar por categoría
    final Map<String, double> totalesPorCategoria = {};
    for (final g in gastosMes) {
      totalesPorCategoria[g.categoria] =
          (totalesPorCategoria[g.categoria] ?? 0.0) + g.monto;
    }

    final totalMes =
        totalesPorCategoria.values.fold(0.0, (sum, val) => sum + val);

    final categoriasOrdenadas = totalesPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de mes minimalista
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EncabezadoSeccion(titulo: 'Gastos por categoría'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_outlined, size: 18),
                    tooltip: 'Mes anterior',
                    visualDensity: VisualDensity.compact,
                    onPressed: _mesAnterior,
                  ),
                  Text(
                    '$nombreMes $anio',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_outlined, size: 18),
                    tooltip: 'Mes siguiente',
                    visualDensity: VisualDensity.compact,
                    onPressed: _mesSiguiente,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (gastosMes.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 40,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay gastos registrados en $nombreMes $anio',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Gráfico de dona con indicador central
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 52,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _categoriaTocadaIndex = -1;
                              return;
                            }
                            _categoriaTocadaIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: List.generate(
                        categoriasOrdenadas.length,
                        (i) {
                          final entry = categoriasOrdenadas[i];
                          final isTouched = i == _categoriaTocadaIndex;
                          final double fontSize = isTouched ? 14 : 11;
                          final double radius = isTouched ? 58 : 50;
                          final double porcentaje =
                              totalMes > 0 ? (entry.value / totalMes) * 100 : 0;

                          final color = _obtenerColorCategoria(
                            i,
                            colors,
                            primary,
                          );

                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            title: '${porcentaje.toStringAsFixed(0)}%',
                            radius: radius,
                            titleStyle: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Texto interactivo en el centro de la dona
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _categoriaTocadaIndex >= 0 &&
                                  _categoriaTocadaIndex <
                                      categoriasOrdenadas.length
                              ? categoriasOrdenadas[_categoriaTocadaIndex].key
                              : 'Total mes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _categoriaTocadaIndex >= 0 &&
                                  _categoriaTocadaIndex <
                                      categoriasOrdenadas.length
                              ? formatearMoneda(
                                  categoriasOrdenadas[_categoriaTocadaIndex]
                                      .value,
                                  moneda,
                                )
                              : formatearMoneda(totalMes, moneda),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_categoriaTocadaIndex >= 0 &&
                            _categoriaTocadaIndex < categoriasOrdenadas.length)
                          Text(
                            '${((categoriasOrdenadas[_categoriaTocadaIndex].value / totalMes) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _obtenerColorCategoria(
                                _categoriaTocadaIndex,
                                colors,
                                primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Lista detallada de categorías con porcentaje y monto
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoriasOrdenadas.length,
              separatorBuilder: (context, index) =>
                  Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
              itemBuilder: (context, i) {
                final entry = categoriasOrdenadas[i];
                final color = _obtenerColorCategoria(i, colors, primary);
                final porcentaje =
                    totalMes > 0 ? (entry.value / totalMes) * 100 : 0.0;
                final bool esSeleccionado = i == _categoriaTocadaIndex;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _categoriaTocadaIndex = esSeleccionado ? -1 : i;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: esSeleccionado
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: esSeleccionado
                                  ? primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          '${porcentaje.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatearMoneda(entry.value, moneda),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // c) Ingresos vs gastos (Últimos 6 meses)
  // ===========================================================================
  Widget _construirSeccionIngresosVsGastos(
    List<Gasto> todosLosGastos,
    List<Ingreso> todosLosIngresos,
    String moneda,
    AppColorsExtension colors,
    Color primary,
  ) {
    final ahora = DateTime.now();

    // Generar los últimos 6 meses cronológicos
    final List<DateTime> seisMeses = List.generate(6, (i) {
      return DateTime(ahora.year, ahora.month - 5 + i, 1);
    });

    final List<double> ingresosPorMes = [];
    final List<double> gastosPorMes = [];

    double maxY = 0;
    bool hayMovimientos = false;

    for (final mes in seisMeses) {
      final ingresosMes = todosLosIngresos.where((ing) {
        return ing.fecha.year == mes.year && ing.fecha.month == mes.month;
      });
      final double totalIng =
          ingresosMes.fold(0.0, (sum, ing) => sum + ing.monto);

      final gastosMes = todosLosGastos.where((g) {
        return g.fecha.year == mes.year && g.fecha.month == mes.month;
      });
      final double totalGasto =
          gastosMes.fold(0.0, (sum, g) => sum + g.monto);

      if (totalIng > 0 || totalGasto > 0) {
        hayMovimientos = true;
      }

      maxY = max(maxY, max(totalIng, totalGasto));
      ingresosPorMes.add(totalIng);
      gastosPorMes.add(totalGasto);
    }

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EncabezadoSeccion(titulo: 'Ingresos vs gastos'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _indicadorColor(colors.ingreso, 'Ingresos'),
                  const SizedBox(width: 12),
                  _indicadorColor(colors.gasto, 'Gastos'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!hayMovimientos)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows_outlined,
                    size: 36,
                    color: colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay registros en los últimos 6 meses',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY > 0 ? maxY * 1.2 : 10,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          Theme.of(context).cardTheme.color ??
                          Colors.grey.shade900,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final mes = seisMeses[group.x];
                        final nombreMes =
                            '${_meses[mes.month - 1]} ${mes.year}';
                        final tipo = rodIndex == 0 ? 'Ingresos' : 'Gastos';
                        final color =
                            rodIndex == 0 ? colors.ingreso : colors.gasto;

                        return BarTooltipItem(
                          '$nombreMes\n',
                          TextStyle(
                            color: colors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '$tipo: ${formatearMoneda(rod.toY, moneda)}',
                              style: TextStyle(
                                color: color,
                                fontSize: 13,
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
                        reservedSize: 26,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index < 0 || index >= seisMeses.length) {
                            return const SizedBox.shrink();
                          }
                          final mes = seisMeses[index];
                          final nombreCorto = _meses[mes.month - 1]
                              .substring(0, 3)
                              .toUpperCase();

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              nombreCorto,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? (maxY / 4) : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colors.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(6, (i) {
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        // Barra de Ingreso
                        BarChartRodData(
                          toY: ingresosPorMes[i],
                          color: colors.ingreso,
                          width: 11,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        // Barra de Gasto
                        BarChartRodData(
                          toY: gastosPorMes[i],
                          color: colors.gasto,
                          width: 11,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // Helpers de interfaz
  // ===========================================================================
  Widget _indicadorColor(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            fontSize: 11,
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _tarjetaMetrica({
    required double ancho,
    required String titulo,
    required String valor,
    required IconData icono,
    Color? colorIcono,
    required AppColorsExtension colors,
  }) {
    return Container(
      width: ancho,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icono,
                size: 16,
                color: colorIcono ?? colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
