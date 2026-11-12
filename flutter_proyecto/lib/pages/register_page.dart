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

  // Controladores para capturar los datos del nuevo usuario.
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _cargando = false;
  bool _ocultarPass = true;
  bool _ocultarConfirmPass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  /// Método para procesar el registro con AuthService.
  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      // Registra el usuario en Firebase a través de AuthService.
      await AuthService().registrar(_emailCtrl.text, _passCtrl.text);
      // Al registrarse, Firebase inicia sesión automáticamente y GoRouter
      // redirige hacia /home mediante el redirect configurado en routers.dart.
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
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 70,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Registro de Usuario',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Crea tu cuenta para comenzar a registrar tus gastos',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),

                  // Campo de Correo Electrónico
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
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

                  // Campo de Contraseña
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _ocultarPass,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPass ? Icons.visibility_off : Icons.visibility,
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
                  const SizedBox(height: 16),

                  // Campo de Confirmación de Contraseña
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: _ocultarConfirmPass,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_reset),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarConfirmPass
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                  const SizedBox(height: 24),

                  // Botón de Registro
                  FilledButton(
                    onPressed: _cargando ? null : _registrar,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Botón para volver a Iniciar Sesión con context.go
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
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
