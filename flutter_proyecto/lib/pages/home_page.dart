import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/gasto_model.dart';
import '../models/ingreso_model.dart';
import '../routers.dart';
import '../services/auth_service.dart';
import '../services/gasto_service.dart';
import '../services/ingreso_service.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';
import '../widgets/acciones_rapidas.dart';
import '../widgets/encabezado_seccion.dart';
import '../widgets/fila_categoria.dart';
import '../widgets/fila_movimiento.dart';
import '../widgets/tarjeta_saldo.dart';

/// Modelo interno para unificar ingresos y gastos en una sola lista cronológica.
class _MovimientoItem {
  final bool esGasto;
  final Gasto? gasto;
  final Ingreso? ingreso;
  final DateTime fecha;

  _MovimientoItem.gasto(this.gasto)
      : esGasto = true,
        ingreso = null,
        fecha = gasto!.fecha;

  _MovimientoItem.ingreso(this.ingreso)
      : esGasto = false,
        gasto = null,
        fecha = ingreso!.fecha;

  String get id => esGasto ? gasto!.id : ingreso!.id;
  String get descripcion => esGasto ? gasto!.descripcion : ingreso!.descripcion;
  double get monto => esGasto ? gasto!.monto : ingreso!.monto;
  String get categoria => esGasto ? gasto!.categoria : 'Ingreso';
}

/// Pantalla principal con diseño fintech minimalista y elegante.
/// Muestra tarjeta de saldo con toggle de privacidad, acciones rápidas,
/// resumen por categoría y lista unificada de movimientos recientes.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _mesSeleccionado;
  bool _montosOcultos = false;

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
    _mesSeleccionado = DateTime(ahora.year, ahora.month, 1);
  }

  void _mesAnterior() {
    setState(() {
      _mesSeleccionado = DateTime(
        _mesSeleccionado.year,
        _mesSeleccionado.month - 1,
        1,
      );
    });
  }

  void _mesSiguiente() {
    setState(() {
      _mesSeleccionado = DateTime(
        _mesSeleccionado.year,
        _mesSeleccionado.month + 1,
        1,
      );
    });
  }

  void _irAMesActual() {
    final ahora = DateTime.now();
    setState(() {
      _mesSeleccionado = DateTime(ahora.year, ahora.month, 1);
    });
  }

  IconData _iconoPorCategoria(String categoria) {
    switch (categoria) {
      case 'Alimentación':
        return Icons.restaurant_outlined;
      case 'Transporte':
        return Icons.directions_bus_outlined;
      case 'Vivienda':
        return Icons.home_outlined;
      case 'Servicios':
        return Icons.receipt_long_outlined;
      case 'Salud':
        return Icons.local_hospital_outlined;
      case 'Educación':
        return Icons.school_outlined;
      case 'Entretenimiento':
        return Icons.movie_outlined;
      case 'Ropa':
        return Icons.checkroom_outlined;
      default:
        return Icons.attach_money_outlined;
    }
  }

  Future<bool?> _mostrarDialogoConfirmacion(
      BuildContext context, String descripcion) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Seguro que deseas eliminar "$descripcion"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.appColors.gasto,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarGastoConConfirmacion(
      BuildContext context, Gasto gasto) async {
    final bool? confirmar =
        await _mostrarDialogoConfirmacion(context, gasto.descripcion);

    if (confirmar == true && context.mounted) {
      try {
        await GastoService().eliminar(gasto.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gasto "${gasto.descripcion}" eliminado'),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el gasto: $e'),
              backgroundColor: context.appColors.gasto,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarIngresoConConfirmacion(
      BuildContext context, Ingreso ingreso) async {
    final bool? confirmar =
        await _mostrarDialogoConfirmacion(context, ingreso.descripcion);

    if (confirmar == true && context.mounted) {
      try {
        await IngresoService().eliminar(ingreso.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ingreso "${ingreso.descripcion}" eliminado'),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el ingreso: $e'),
              backgroundColor: context.appColors.gasto,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;
    final email = usuario?.email ?? 'Usuario';

    final nombreMes = _meses[_mesSeleccionado.month - 1];
    final anio = _mesSeleccionado.year;
    final ahora = DateTime.now();
    final esMesActual =
        _mesSeleccionado.year == ahora.year && _mesSeleccionado.month == ahora.month;

    final pref = PreferenciasService();
    final colors = context.appColors;

    return ListenableBuilder(
      listenable: pref,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.greenSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hola,',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                tooltip: 'Configuración',
                onPressed: () => context.go(AppRoutes.settings),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, size: 22),
                tooltip: 'Perfil',
                onPressed: () => context.go(AppRoutes.perfil),
              ),
              IconButton(
                icon: const Icon(Icons.logout_outlined, size: 22),
                tooltip: 'Cerrar sesión',
                onPressed: () async {
                  await AuthService().salir();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: StreamBuilder<List<Gasto>>(
            stream: GastoService().obtenerGastos(),
            builder: (context, snapshotGastos) {
              return StreamBuilder<List<Ingreso>>(
                stream: IngresoService().obtenerIngresos(),
                builder: (context, snapshotIngresos) {
                  if (snapshotGastos.connectionState ==
                          ConnectionState.waiting ||
                      snapshotIngresos.connectionState ==
                          ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshotGastos.hasError || snapshotIngresos.hasError) {
                    final error =
                        snapshotGastos.error ?? snapshotIngresos.error;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 44,
                              color: colors.gasto,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Error al cargar información: $error',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.gasto),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final todosLosGastos = snapshotGastos.data ?? [];
                  final todosLosIngresos = snapshotIngresos.data ?? [];

                  // Filtrado por el mes seleccionado
                  final gastosDelMes = todosLosGastos.where((g) {
                    return g.fecha.year == _mesSeleccionado.year &&
                        g.fecha.month == _mesSeleccionado.month;
                  }).toList();

                  final ingresosDelMes = todosLosIngresos.where((i) {
                    return i.fecha.year == _mesSeleccionado.year &&
                        i.fecha.month == _mesSeleccionado.month;
                  }).toList();

                  final totalGastos = gastosDelMes.fold<double>(
                    0.0,
                    (acum, g) => acum + g.monto,
                  );

                  final totalIngresos = ingresosDelMes.fold<double>(
                    0.0,
                    (acum, i) => acum + i.monto,
                  );

                  final disponible = totalIngresos - totalGastos;

                  // Agrupación por categoría (solo gastos del mes)
                  final Map<String, double> totalesPorCategoria = {};
                  for (final g in gastosDelMes) {
                    totalesPorCategoria[g.categoria] =
                        (totalesPorCategoria[g.categoria] ?? 0.0) + g.monto;
                  }

                  final categoriasOrdenadas = totalesPorCategoria.entries
                      .toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  // Movimientos combinados del mes ordenados cronológicamente
                  final List<_MovimientoItem> movimientos = [
                    ...gastosDelMes.map((g) => _MovimientoItem.gasto(g)),
                    ...ingresosDelMes.map((i) => _MovimientoItem.ingreso(i)),
                  ]..sort((a, b) => b.fecha.compareTo(a.fecha));

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    children: [
                      // Selector de mes minimalista
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left_outlined,
                                size: 20,
                              ),
                              tooltip: 'Mes anterior',
                              onPressed: _mesAnterior,
                            ),
                            GestureDetector(
                              onTap: esMesActual ? null : _irAMesActual,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$nombreMes $anio',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (!esMesActual) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.greenSecondary
                                            .withValues(alpha: 0.35),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Hoy',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_right_outlined,
                                size: 20,
                              ),
                              tooltip: 'Mes siguiente',
                              onPressed: _mesSiguiente,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tarjeta Principal de Saldo
                      TarjetaSaldo(
                        disponible: disponible,
                        totalIngresos: totalIngresos,
                        totalGastos: totalGastos,
                        moneda: pref.moneda,
                        montosOcultos: _montosOcultos,
                        onToggleVisibilidad: () {
                          setState(() {
                            _montosOcultos = !_montosOcultos;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dos acciones rápidas
                      const AccionesRapidas(),
                      const SizedBox(height: 24),

                      // Resumen por Categoría
                      EncabezadoSeccion(
                        titulo: 'Resumen por categoría',
                        badge: categoriasOrdenadas.isNotEmpty
                            ? '${categoriasOrdenadas.length}'
                            : null,
                      ),
                      const SizedBox(height: 8),

                      if (categoriasOrdenadas.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              'Sin gastos registrados en este período',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border, width: 1),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < categoriasOrdenadas.length;
                                  i++) ...[
                                FilaCategoria(
                                  categoria: categoriasOrdenadas[i].key,
                                  monto: categoriasOrdenadas[i].value,
                                  porcentaje: totalGastos > 0
                                      ? (categoriasOrdenadas[i].value /
                                          totalGastos)
                                      : 0.0,
                                  icono: _iconoPorCategoria(
                                      categoriasOrdenadas[i].key),
                                  moneda: pref.moneda,
                                  montosOcultos: _montosOcultos,
                                ),
                                if (i != categoriasOrdenadas.length - 1)
                                  const SizedBox(height: 4),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Movimientos Recientes (Gastos e Ingresos unificados)
                      EncabezadoSeccion(
                        titulo: 'Movimientos recientes',
                        badge: '${movimientos.length}',
                      ),
                      const SizedBox(height: 8),

                      if (movimientos.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border, width: 1),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 36,
                                color: colors.textSecondary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No hay movimientos en este mes',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        for (final item in movimientos)
                          FilaMovimiento(
                            id: '${item.esGasto ? "gasto" : "ingreso"}_${item.id}',
                            descripcion: item.descripcion,
                            subtitulo:
                                '${item.categoria} • ${item.fecha.day.toString().padLeft(2, '0')}/${item.fecha.month.toString().padLeft(2, '0')}/${item.fecha.year}',
                            monto: item.monto,
                            esIngreso: !item.esGasto,
                            icono: item.esGasto
                                ? _iconoPorCategoria(item.categoria)
                                : Icons.arrow_downward_outlined,
                            moneda: pref.moneda,
                            montosOcultos: _montosOcultos,
                            onTap: () {
                              if (item.esGasto) {
                                context.go(
                                  AppRoutes.gastoForm,
                                  extra: item.gasto,
                                );
                              } else {
                                context.go(
                                  AppRoutes.ingresoForm,
                                  extra: item.ingreso,
                                );
                              }
                            },
                            onEliminar: () {
                              if (item.esGasto) {
                                _eliminarGastoConConfirmacion(
                                    context, item.gasto!);
                              } else {
                                _eliminarIngresoConConfirmacion(
                                    context, item.ingreso!);
                              }
                            },
                            onConfirmarEliminacion: () =>
                                _mostrarDialogoConfirmacion(
                                    context, item.descripcion),
                            onDismissed: () async {
                              try {
                                if (item.esGasto) {
                                  await GastoService().eliminar(item.gasto!.id);
                                } else {
                                  await IngresoService()
                                      .eliminar(item.ingreso!.id);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item.esGasto ? "Gasto" : "Ingreso"} "${item.descripcion}" eliminado',
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al eliminar: $e'),
                                      backgroundColor: colors.gasto,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
