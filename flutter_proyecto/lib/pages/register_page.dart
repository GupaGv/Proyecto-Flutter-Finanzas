import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../services/auth_service.dart';

/// Pantalla para registrar una nueva cuenta de usuario.
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
    // Escucha los cambios en la contraseña para recalcular su fortaleza en tiempo real.
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

  /// Color de la barra de progreso según el nivel alcanzado.
  Color _colorFortaleza() {
    switch (_nivelFortaleza) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber.shade700;
      case 4:
        return Colors.green;
      default:
        return Colors.grey.shade300;
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
          content: Text(mensajeDeError(e)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error inesperado. Intenta de nuevo.'),
          backgroundColor: Colors.red,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  // Ícono superior circular
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green.shade200, width: 2),
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 48,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Registro de Usuario',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Crea tu cuenta para comenzar a registrar tus gastos',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Campo de Correo Electrónico
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                      ),
                    ),
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
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _ocultarPass,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () =>
                            setState(() => _ocultarPass = !_ocultarPass),
                      ),
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

                  // Barra indicadora de fortaleza de contraseña (LinearProgressIndicator)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _nivelFortaleza / 4.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_colorFortaleza()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fortaleza: ${_textoFortaleza()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _colorFortaleza(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_nivelFortaleza de 4 niveles',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campo de Confirmación de Contraseña con botón mostrar/ocultar
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: _ocultarConfirmPass,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_reset),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarConfirmPass
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => setState(
                          () => _ocultarConfirmPass = !_ocultarConfirmPass,
                        ),
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

                  // Botón verde ancho de registro
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _cargando ? null : _registrar,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Registrarme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Enlace para volver al login con context.go
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      '¿Ya tienes una cuenta? Inicia sesión',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
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
