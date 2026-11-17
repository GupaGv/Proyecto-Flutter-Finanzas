import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Define un avatar predeterminado seleccionable dentro de la aplicación.
class AvatarPredeterminado {
  final String id;
  final IconData icono;
  final String etiqueta;

  const AvatarPredeterminado({
    required this.id,
    required this.icono,
    required this.etiqueta,
  });

  /// Lista fija de los 8 avatares predeterminados disponibles en la aplicación.
  static const List<AvatarPredeterminado> lista = [
    AvatarPredeterminado(
      id: 'avatar_1',
      icono: Icons.person_outline,
      etiqueta: 'Clásico',
    ),
    AvatarPredeterminado(
      id: 'avatar_2',
      icono: Icons.face_outlined,
      etiqueta: 'Rostro',
    ),
    AvatarPredeterminado(
      id: 'avatar_3',
      icono: Icons.savings_outlined,
      etiqueta: 'Ahorro',
    ),
    AvatarPredeterminado(
      id: 'avatar_4',
      icono: Icons.account_balance_wallet_outlined,
      etiqueta: 'Billetera',
    ),
    AvatarPredeterminado(
      id: 'avatar_5',
      icono: Icons.trending_up_outlined,
      etiqueta: 'Crecimiento',
    ),
    AvatarPredeterminado(
      id: 'avatar_6',
      icono: Icons.eco_outlined,
      etiqueta: 'Ecológico',
    ),
    AvatarPredeterminado(
      id: 'avatar_7',
      icono: Icons.workspace_premium_outlined,
      etiqueta: 'Insignia',
    ),
    AvatarPredeterminado(
      id: 'avatar_8',
      icono: Icons.auto_awesome_outlined,
      etiqueta: 'Estrella',
    ),
  ];

  /// Busca un avatar en la lista predeterminada según su identificador.
  static AvatarPredeterminado? buscarPorId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final avatar in lista) {
      if (avatar.id == id) return avatar;
    }
    return null;
  }
}

/// Widget reutilizable para mostrar el avatar de usuario según la prioridad:
/// 1. Foto personalizada en Base64 (si existe).
/// 2. Avatar predeterminado (ícono sobre color del tema).
/// 3. Inicial del nombre o correo electrónico.
class UserAvatar extends StatelessWidget {
  final double size;
  final String? fotoBase64;
  final String? avatarId;
  final String? nombre;
  final String? email;

  const UserAvatar({
    super.key,
    this.size = 40.0,
    this.fotoBase64,
    this.avatarId,
    this.nombre,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    // 1. Prioridad: Foto personalizada en Base64
    if (fotoBase64 != null && fotoBase64!.trim().isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(fotoBase64!.trim());
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.border,
              width: size > 60 ? 1.5 : 1.0,
            ),
          ),
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Si la decodificación de imagen falla, pasar al siguiente nivel
                return _buildAvatarPredeterminadoOInicial(context, colors, primary);
              },
            ),
          ),
        );
      } catch (_) {
        // En caso de error al procesar el String base64, continuar con el fallback
      }
    }

    // 2 y 3. Avatar predeterminado o Inicial del nombre
    return _buildAvatarPredeterminadoOInicial(context, colors, primary);
  }

  /// Construye el avatar predeterminado si existe un avatarId válido,
  /// o de lo contrario muestra la inicial del nombre o correo.
  Widget _buildAvatarPredeterminadoOInicial(
    BuildContext context,
    dynamic colors,
    Color primary,
  ) {
    final avatarPredeterminado = AvatarPredeterminado.buscarPorId(avatarId);

    // 2. Prioridad: Avatar predeterminado con ícono
    if (avatarPredeterminado != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.greenSecondary.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.border,
            width: size > 60 ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Icon(
            avatarPredeterminado.icono,
            size: size * 0.52,
            color: primary,
          ),
        ),
      );
    }

    // 3. Prioridad: Inicial del nombre (o parte del correo si no hay nombre)
    String inicial = 'U';
    if (nombre != null && nombre!.trim().isNotEmpty) {
      inicial = nombre!.trim()[0].toUpperCase();
    } else if (email != null && email!.trim().isNotEmpty) {
      inicial = email!.trim()[0].toUpperCase();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.greenSecondary.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.border,
          width: size > 60 ? 1.5 : 1.0,
        ),
      ),
      child: Center(
        child: Text(
          inicial,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
        ),
      ),
    );
  }
}
