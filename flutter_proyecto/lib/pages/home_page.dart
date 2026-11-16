import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/gasto_model.dart';
import '../models/ingreso_model.dart';
import '../routers.dart';
import '../services/auth_service.dart';
import '../services/gasto_service.dart';
import '../services/ingreso_service.dart';
import '../services/preferencias_service.dart';

/// Pantalla principal de la aplicación "Gestor de Gastos Personales".
/// Incluye selector de mes, tarjetas de Ingresos/Gastos/Disponible,
/// resumen por categoría (gastos) y listas en tiempo real de ingresos y gastos.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mes y año actualmente seleccionados para visualizar
  late DateTime _mesSeleccionado;

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

  /// Cambia al mes anterior.
  void _mesAnterior() {
    setState(() {
      _mesSeleccionado = DateTime(
        _mesSeleccionado.year,
        _mesSeleccionado.month - 1,
        1,
      );
    });
  }

  /// Cambia al mes siguiente.
  void _mesSiguiente() {
    setState(() {
      _mesSeleccionado = DateTime(
        _mesSeleccionado.year,
        _mesSeleccionado.month + 1,
        1,
      );
    });
  }

  /// Retorna al mes actual.
  void _irAMesActual() {
    final ahora = DateTime.now();
    setState(() {
      _mesSeleccionado = DateTime(ahora.year, ahora.month, 1);
    });
  }

  /// Asigna un ícono según la categoría del gasto.
  IconData _iconoPorCategoria(String categoria) {
    switch (categoria) {
      case 'Alimentación':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_bus;
      case 'Vivienda':
        return Icons.home;
      case 'Servicios':
        return Icons.receipt_long;
      case 'Salud':
        return Icons.local_hospital;
      case 'Educación':
        return Icons.school;
      case 'Entretenimiento':
        return Icons.movie;
      case 'Ropa':
        return Icons.checkroom;
      default:
        return Icons.attach_money;
    }
  }

  /// Diálogo reutilizable de confirmación para eliminar un registro.
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
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Elimina un gasto tras pedir confirmación mediante el ícono de papelera.
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
              backgroundColor: Colors.grey.shade800,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el gasto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Elimina un ingreso tras pedir confirmación mediante el ícono de papelera.
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
              backgroundColor: Colors.grey.shade800,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el ingreso: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Abre un menú modal desde el botón flotante para registrar un nuevo gasto o ingreso.
  void _mostrarMenuRegistro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '¿Qué deseas registrar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Icon(Icons.arrow_upward, color: Colors.red.shade700),
                  ),
                  title: const Text(
                    'Nuevo Gasto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Registra una salida de dinero'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go(AppRoutes.gastoForm);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green.shade200),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.arrow_downward, color: Colors.green.shade700),
                  ),
                  title: const Text(
                    'Nuevo Ingreso',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Registra una entrada de dinero'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go(AppRoutes.ingresoForm);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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

    return ListenableBuilder(
      listenable: pref,
      builder: (context, _) {
        final simbolo = pref.simboloMoneda;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestor de Gastos'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Configuración',
                onPressed: () => context.go(AppRoutes.settings),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: 'Perfil',
                onPressed: () => context.go(AppRoutes.perfil),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: () async {
                  await AuthService().salir();
                },
              ),
            ],
          ),
          // Escucha simultáneamente las colecciones de Gastos e Ingresos
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
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Error al cargar información: $error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final todosLosGastos = snapshotGastos.data ?? [];
                  final todosLosIngresos = snapshotIngresos.data ?? [];

                  // Filtrar gastos e ingresos que corresponden al mes y año seleccionado
                  final gastosDelMes = todosLosGastos.where((g) {
                    return g.fecha.year == _mesSeleccionado.year &&
                        g.fecha.month == _mesSeleccionado.month;
                  }).toList();

                  final ingresosDelMes = todosLosIngresos.where((i) {
                    return i.fecha.year == _mesSeleccionado.year &&
                        i.fecha.month == _mesSeleccionado.month;
                  }).toList();

                  // Cálculos financieros del mes
                  final totalGastos = gastosDelMes.fold<double>(
                    0.0,
                    (acum, g) => acum + g.monto,
                  );

                  final totalIngresos = ingresosDelMes.fold<double>(
                    0.0,
                    (acum, i) => acum + i.monto,
                  );

                  final disponible = totalIngresos - totalGastos;
                  final disponibleEsNegativo = disponible < 0;

                  // Agrupación y suma por categoría para el resumen mensual (solo gastos)
                  final Map<String, double> totalesPorCategoria = {};
                  for (final g in gastosDelMes) {
                    totalesPorCategoria[g.categoria] =
                        (totalesPorCategoria[g.categoria] ?? 0.0) + g.monto;
                  }

                  final categoriasOrdenadas = totalesPorCategoria.entries
                      .toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Tarjeta de bienvenida
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  size: 24,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Selector para cambiar de mes (aplica a gastos e ingresos)
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                tooltip: 'Mes anterior',
                                onPressed: _mesAnterior,
                              ),
                              GestureDetector(
                                onTap: esMesActual ? null : _irAMesActual,
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$nombreMes $anio',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Hoy',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                tooltip: 'Mes siguiente',
                                onPressed: _mesSiguiente,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tres tarjetas del mes: Ingresos, Gastos y Disponible
                      Row(
                        children: [
                          // Tarjeta Ingresos
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 6.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_downward,
                                          color: Colors.green.shade700,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Ingresos',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '+$simbolo ${totalIngresos.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Tarjeta Gastos
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 6.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward,
                                          color: Colors.red.shade700,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Gastos',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '-$simbolo ${totalGastos.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Tarjeta Disponible (en rojo si es negativo)
                          Expanded(
                            child: Card(
                              elevation: 2,
                              color: disponibleEsNegativo
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.red.shade900.withValues(alpha: 0.4)
                                      : Colors.red.shade50)
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.green.shade900
                                          .withValues(alpha: 0.3)
                                      : Colors.green.shade50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: disponibleEsNegativo
                                      ? Colors.red.shade400
                                      : Colors.green.shade400,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 6.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          disponibleEsNegativo
                                              ? Icons.warning_amber_rounded
                                              : Icons.account_balance_wallet,
                                          color: disponibleEsNegativo
                                              ? Colors.red.shade700
                                              : Colors.green.shade800,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Disponible',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: disponibleEsNegativo
                                              ? Colors.red.shade700
                                              : Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${disponible < 0 ? "-" : ""}$simbolo ${disponible.abs().toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: disponibleEsNegativo
                                              ? Colors.red.shade700
                                              : Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sección: Resumen por categoría (solo de gastos)
                      const Text(
                        'Resumen por Categoría (Gastos)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (categoriasOrdenadas.isEmpty)
                        Card(
                          elevation: 0,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'Sin gastos registrados en este mes para categorizar',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          ),
                        )
                      else
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                for (final entry in categoriasOrdenadas) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _iconoPorCategoria(entry.key),
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                entry.key,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '$simbolo ${entry.value.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${totalGastos > 0 ? ((entry.value / totalGastos) * 100).toStringAsFixed(0) : 0}%)',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: totalGastos > 0
                                                ? (entry.value / totalGastos)
                                                : 0.0,
                                            minHeight: 5,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (entry != categoriasOrdenadas.last)
                                    const Divider(height: 12),
                                ],
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Sección: Lista de Ingresos del mes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ingresos de $nombreMes',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${ingresosDelMes.length} item(s)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (ingresosDelMes.isEmpty)
                        Card(
                          elevation: 0,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 24.0,
                              horizontal: 16,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.savings_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No hay ingresos en este mes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final ingreso in ingresosDelMes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Dismissible(
                              key: Key('ingreso_${ingreso.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.delete, color: Colors.white),
                                  ],
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await _mostrarDialogoConfirmacion(
                                  context,
                                  ingreso.descripcion,
                                );
                              },
                              onDismissed: (direction) async {
                                try {
                                  await IngresoService().eliminar(ingreso.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Ingreso "${ingreso.descripcion}" eliminado',
                                        ),
                                        backgroundColor: Colors.grey.shade800,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error al eliminar el ingreso: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    child: Icon(
                                      Icons.arrow_downward,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  title: Text(
                                    ingreso.descripcion,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Ingreso • ${ingreso.fecha.day.toString().padLeft(2, '0')}/${ingreso.fecha.month.toString().padLeft(2, '0')}/${ingreso.fecha.year}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '+$simbolo ${ingreso.monto.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Eliminar ingreso',
                                        onPressed: () =>
                                            _eliminarIngresoConConfirmacion(
                                          context,
                                          ingreso,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    context.go(
                                      AppRoutes.ingresoForm,
                                      extra: ingreso,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      const SizedBox(height: 24),

                      // Sección: Lista de Gastos del mes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gastos de $nombreMes',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${gastosDelMes.length} item(s)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (gastosDelMes.isEmpty)
                        Card(
                          elevation: 0,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 24.0,
                              horizontal: 16,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No hay gastos en este mes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final gasto in gastosDelMes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Dismissible(
                              key: Key('gasto_${gasto.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.delete, color: Colors.white),
                                  ],
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await _mostrarDialogoConfirmacion(
                                  context,
                                  gasto.descripcion,
                                );
                              },
                              onDismissed: (direction) async {
                                try {
                                  await GastoService().eliminar(gasto.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Gasto "${gasto.descripcion}" eliminado',
                                        ),
                                        backgroundColor: Colors.grey.shade800,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error al eliminar el gasto: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    child: Icon(
                                      _iconoPorCategoria(gasto.categoria),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                  title: Text(
                                    gasto.descripcion,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${gasto.categoria} • ${gasto.fecha.day.toString().padLeft(2, '0')}/${gasto.fecha.month.toString().padLeft(2, '0')}/${gasto.fecha.year}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '-$simbolo ${gasto.monto.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Eliminar gasto',
                                        onPressed: () =>
                                            _eliminarGastoConConfirmacion(
                                          context,
                                          gasto,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    context.go(
                                      AppRoutes.gastoForm,
                                      extra: gasto,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              );
            },
          ),
          // Botón flotante que abre el menú con "Nuevo gasto" y "Nuevo ingreso"
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _mostrarMenuRegistro(context),
            icon: const Icon(Icons.add),
            label: const Text('Registrar'),
          ),
        );
      },
    );
  }
}
