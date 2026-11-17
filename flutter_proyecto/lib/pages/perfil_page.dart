import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/perfil_model.dart';
import '../services/auth_service.dart';
import '../services/perfil_service.dart';
import '../theme/app_theme.dart';
import '../widgets/campo_texto.dart';
import '../widgets/user_avatar.dart';

/// Pantalla de perfil de usuario con estética fintech minimalista.
/// Muestra avatar personalizable, nombre, correo, UID, botón de edición
/// y botón de cerrar sesión.
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final PerfilService _perfilService = PerfilService();

  /// Despliega la hoja inferior para editar el nombre y avatar del usuario.
  void _mostrarEditarPerfilSheet(
    BuildContext context,
    PerfilUsuario? perfil,
    String nombreActual,
    String? email,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditarPerfilSheet(
        perfilInicial: perfil,
        nombreInicial: nombreActual,
        email: email,
        onGuardado: () {
          // Fuerza el refresco del estado local tras guardar en FirebaseAuth
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService().usuarioActual;
    final email = usuario?.email ?? 'Sin correo registrado';
    final uid = usuario?.uid ?? 'No disponible';
    final nombreAuth = usuario?.displayName;

    final String nombreMostrado = (nombreAuth != null && nombreAuth.trim().isNotEmpty)
        ? nombreAuth.trim()
        : (email.contains('@') ? email.split('@').first : 'Usuario');

    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<PerfilUsuario>(
          stream: _perfilService.obtenerPerfil(),
          builder: (context, snapshot) {
            final perfil = snapshot.data;

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // Avatar de usuario: foto, predeterminado o inicial
                  UserAvatar(
                    size: 88,
                    fotoBase64: perfil?.fotoBase64,
                    avatarId: perfil?.avatarId,
                    nombre: nombreAuth,
                    email: email,
                  ),
                  const SizedBox(height: 16),

                  // Nombre del usuario
                  Text(
                    nombreMostrado,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Correo o estado
                  Text(
                    email,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Botón para editar perfil (abre la hoja inferior)
                  OutlinedButton.icon(
                    onPressed: () => _mostrarEditarPerfilSheet(
                      context,
                      perfil,
                      nombreAuth ?? '',
                      email,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text(
                      'Editar perfil',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tarjeta con detalles de la cuenta
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.person_outline,
                            color: colors.textSecondary,
                            size: 22,
                          ),
                          title: Text(
                            'Nombre',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            (nombreAuth != null && nombreAuth.trim().isNotEmpty)
                                ? nombreAuth.trim()
                                : 'No configurado',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Divider(color: colors.border, height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.email_outlined,
                            color: colors.textSecondary,
                            size: 22,
                          ),
                          title: Text(
                            'Correo electrónico',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Divider(color: colors.border, height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.fingerprint_outlined,
                            color: colors.textSecondary,
                            size: 22,
                          ),
                          title: Text(
                            'Identificador de usuario (UID)',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            uid,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Botón ancho para cerrar sesión estilizado con color de error/alerta
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await AuthService().salir();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.gasto,
                        side: BorderSide(color: colors.gasto, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout_outlined, size: 20),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Hoja inferior (Bottom Sheet) para editar el nombre y avatar del usuario.
class _EditarPerfilSheet extends StatefulWidget {
  final PerfilUsuario? perfilInicial;
  final String nombreInicial;
  final String? email;
  final VoidCallback onGuardado;

  const _EditarPerfilSheet({
    required this.perfilInicial,
    required this.nombreInicial,
    required this.email,
    required this.onGuardado,
  });

  @override
  State<_EditarPerfilSheet> createState() => _EditarPerfilSheetState();
}

class _EditarPerfilSheetState extends State<_EditarPerfilSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late String _avatarSeleccionado;
  String? _fotoBase64;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial);
    _avatarSeleccionado = widget.perfilInicial?.avatarId ?? 'avatar_1';
    _fotoBase64 = widget.perfilInicial?.fotoBase64;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  /// Permite seleccionar una foto desde la galería usando image_picker,
  /// optimizada a 256x256 y convertida a Base64 sin utilizar dart:io.
  Future<void> _subirFoto() async {
    try {
      final picker = ImagePicker();
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 70,
      );

      if (imagen == null) return;

      final bytes = await imagen.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _fotoBase64 = base64String;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la imagen: $e'),
            backgroundColor: context.appColors.gasto,
          ),
        );
      }
    }
  }

  /// Remueve la foto personalizada para volver a mostrar el avatar predeterminado o inicial.
  void _quitarFoto() {
    setState(() {
      _fotoBase64 = null;
    });
  }

  /// Selecciona uno de los 8 avatares predeterminados y remueve la foto actual.
  void _seleccionarAvatar(String id) {
    setState(() {
      _avatarSeleccionado = id;
      _fotoBase64 = null;
    });
  }

  /// Valida y guarda los cambios en FirebaseAuth y Firestore.
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      await PerfilService().guardarPerfil(
        nombre: _nombreController.text.trim(),
        avatarId: _avatarSeleccionado,
        fotoBase64: _fotoBase64,
      );

      if (mounted) {
        widget.onGuardado();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado correctamente'),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el perfil: $e'),
            backgroundColor: context.appColors.gasto,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra indicadora de hoja modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                'Editar Perfil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Vista previa interactiva del avatar
              Center(
                child: UserAvatar(
                  size: 84,
                  fotoBase64: _fotoBase64,
                  avatarId: _avatarSeleccionado,
                  nombre: _nombreController.text,
                  email: widget.email,
                ),
              ),
              const SizedBox(height: 14),

              // Botones para subir o quitar foto
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _guardando ? null : _subirFoto,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text(
                      'Subir foto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed:
                        (_guardando || _fotoBase64 == null) ? null : _quitarFoto,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.gasto,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: _fotoBase64 != null
                          ? colors.gasto
                          : colors.textSecondary.withValues(alpha: 0.3),
                    ),
                    label: Text(
                      'Quitar foto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _fotoBase64 != null
                            ? colors.gasto
                            : colors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campo de nombre (obligatorio, máximo 30 caracteres)
              CampoTexto(
                controller: _nombreController,
                labelText: 'Nombre completo',
                hintText: 'Ingresa tu nombre',
                prefixIcon: Icons.badge_outlined,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El nombre es obligatorio.';
                  }
                  if (valor.trim().length > 30) {
                    return 'El nombre no puede superar los 30 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cuadrícula de 8 avatares predeterminados
              Text(
                'Avatares predeterminados',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AvatarPredeterminado.lista.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final avatar = AvatarPredeterminado.lista[index];
                  final bool esSeleccionado =
                      _avatarSeleccionado == avatar.id && _fotoBase64 == null;

                  return InkWell(
                    onTap:
                        _guardando ? null : () => _seleccionarAvatar(avatar.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: esSeleccionado
                            ? primary.withValues(alpha: 0.12)
                            : Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: esSeleccionado ? primary : colors.border,
                          width: esSeleccionado ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            avatar.icono,
                            size: 24,
                            color:
                                esSeleccionado ? primary : colors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            avatar.etiqueta,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: esSeleccionado
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: esSeleccionado
                                  ? primary
                                  : colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Botón para guardar cambios
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _guardando
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
