import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/campo_texto.dart';

/// Pantalla para registrar una nueva cuenta de usuario.
/// Diseñada con estética fintech minimalista y adaptable a temas claro y oscuro.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _cargando = false;
  bool _ocultarPass = true;
  bool _ocultarConfirmPass = true;

  // Nivel de fortaleza de la contraseña (de 0 a 4)
  int _nivelFortaleza = 0;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_actualizarFortaleza);
  }

  @override
  void dispose() {
    _passCtrl.removeListener(_actualizarFortaleza);
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  /// Calcula la fortaleza de la contraseña evaluando 4 criterios:
  /// 1) Mínimo 8 caracteres
  /// 2) Al menos una letra mayúscula
  /// 3) Al menos un número
  /// 4) Al menos un símbolo o carácter especial
  void _actualizarFortaleza() {
    final pass = _passCtrl.text;
    int nivel = 0;

    if (pass.length >= 8) nivel++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) nivel++;
    if (RegExp(r'[0-9]').hasMatch(pass)) nivel++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>\-_]').hasMatch(pass)) nivel++;

    if (nivel != _nivelFortaleza) {
      setState(() => _nivelFortaleza = nivel);
    }
  }

  /// Color de la barra de progreso adaptado a la paleta del tema.
  Color _colorFortaleza(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    switch (_nivelFortaleza) {
      case 1:
        return colors.gasto;
      case 2:
        return colors.gasto.withValues(alpha: 0.8);
      case 3:
        return colors.greenSecondary;
      case 4:
        return primary;
      default:
        return colors.border;
    }
  }

  /// Mensaje explicativo del estado de la contraseña.
  String _textoFortaleza() {
    switch (_nivelFortaleza) {
      case 1:
        return 'Muy débil';
      case 2:
        return 'Débil';
      case 3:
        return 'Buena';
      case 4:
        return 'Fuerte y segura';
      default:
        return 'Introduce una contraseña';
    }
  }

  /// Procesa el registro con AuthService.
  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      await AuthService().registrar(_emailCtrl.text, _passCtrl.text);
      // Al registrarse, Firebase inicia sesión y GoRouter redirige a /home.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensajeDeError(e),
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: context.appColors.gasto,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error inesperado. Intenta de nuevo.',
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: context.appColors.gasto,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorFortaleza = _colorFortaleza(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícono simple y elegante arriba
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: colors.greenSecondary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.border, width: 1),
                      ),
                      child: Icon(
                        Icons.person_add_outlined,
                        size: 34,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Título en Manrope
                  Text(
                    'Crear Cuenta',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Regístrate para comenzar a gestionar tus finanzas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Campo de Correo Electrónico
                  CampoTexto(
                    controller: _emailCtrl,
                    labelText: 'Correo electrónico',
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa un correo';
                      }
                      if (!valor.contains('@') || !valor.contains('.')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de Contraseña con botón mostrar/ocultar
                  CampoTexto(
                    controller: _passCtrl,
                    labelText: 'Contraseña',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _ocultarPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _ocultarPass = !_ocultarPass),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Ingresa una contraseña';
                      }
                      if (valor.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Barra de progreso de fortaleza de contraseña
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _nivelFortaleza / 4.0,
                      minHeight: 5,
                      backgroundColor: colors.border.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(colorFortaleza),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fortaleza: ${_textoFortaleza()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorFortaleza,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_nivelFortaleza de 4 niveles',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campo de Confirmación de Contraseña con botón mostrar/ocultar
                  CampoTexto(
                    controller: _confirmPassCtrl,
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: _ocultarConfirmPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarConfirmPass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _ocultarConfirmPass = !_ocultarConfirmPass,
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (valor != _passCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Botón principal ancho con color primario del tema
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _cargando ? null : _registrar,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _cargando
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              'Registrarme',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Enlace secundario con color de texto secundario
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      '¿Ya tienes una cuenta? Inicia sesión',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
