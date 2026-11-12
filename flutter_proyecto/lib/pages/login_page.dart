import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../routers.dart';
import '../services/auth_service.dart';

/// Pantalla de inicio de sesión de la aplicación "Gestor de Gastos Personales".
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Clave global para validar el formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para capturar el correo y la contraseña.
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // Bandera para mostrar un indicador de carga mientras se procesa la solicitud.
  bool _cargando = false;

  // Bandera para ocultar o mostrar el texto de la contraseña.
  bool _ocultarPass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Método para iniciar sesión con AuthService.
  Future<void> _ingresar() async {
    // Si los campos no cumplen las validaciones, no se envía nada.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      // Llamada al servicio de autenticación (no se accede a Firebase directamente).
      await AuthService().ingresar(_emailCtrl.text, _passCtrl.text);
      // Al autenticarse con éxito, GoRouter redirige automáticamente a /home.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Muestra un mensaje amigable al usuario con el error.
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícono representativo de finanzas/gastos
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gestor de Gastos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia sesión para gestionar tus finanzas',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

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
                        return 'Ingresa tu correo';
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
                        return 'Ingresa tu contraseña';
                      }
                      if (valor.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón de Inicio de Sesión
                  FilledButton(
                    onPressed: _cargando ? null : _ingresar,
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
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Enlace a la pantalla de registro usando context.go
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text('¿No tienes una cuenta? Regístrate'),
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
