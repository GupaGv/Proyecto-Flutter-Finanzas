import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fila para visualizar un movimiento (ingreso o gasto) con estética fintech minimalista.
/// Soporta deslizar para eliminar (Dismissible), botón de papelera y toque para editar.
class FilaMovimiento extends StatelessWidget {
  final String id;
  final String descripcion;
  final String subtitulo;
  final double monto;
  final bool esIngreso;
  final IconData icono;
  final String moneda;
  final bool montosOcultos;
  final VoidCallback onTap;
  final VoidCallback onEliminar;
  final Future<bool?> Function() onConfirmarEliminacion;
  final VoidCallback onDismissed;

  const FilaMovimiento({
    super.key,
    required this.id,
    required this.descripcion,
    required this.subtitulo,
    required this.monto,
    required this.esIngreso,
    required this.icono,
    required this.moneda,
    required this.onTap,
    required this.onEliminar,
    required this.onConfirmarEliminacion,
    required this.onDismissed,
    this.montosOcultos = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorMonto = esIngreso ? colors.ingreso : colors.gasto;
    final prefijo = esIngreso ? '+' : '-';
    final textoMonto = montosOcultos
        ? '••••'
        : '$prefijo${formatearMoneda(monto, moneda)}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Dismissible(
        key: Key(id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: colors.gasto,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.delete_outline, color: Colors.white, size: 20),
            ],
          ),
        ),
        confirmDismiss: (_) => onConfirmarEliminacion(),
        onDismissed: (_) => onDismissed(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: esIngreso
                    ? colors.greenSecondary.withValues(alpha: 0.35)
                    : colors.border.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                size: 20,
                color: esIngreso
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            title: Text(
              descripcion,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: -0.1,
              ),
            ),
            subtitle: Text(
              subtitulo,
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  textoMonto,
                  style: TextStyle(
                    color: colorMonto,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colors.textSecondary.withValues(alpha: 0.7),
                    size: 19,
                  ),
                  tooltip: 'Eliminar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onEliminar,
                ),
              ],
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
