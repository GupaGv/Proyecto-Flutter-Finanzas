import 'package:firebase_auth/firebase_auth.dart';

/// Servicio centralizado para gestionar la autenticación con Firebase.
/// Las pantallas del proyecto no acceden a FirebaseAuth directamente,
/// sino que consumen los métodos y propiedades de esta clase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna el usuario actualmente autenticado (o null si no hay sesión).
  User? get usuarioActual => _auth.currentUser;

  /// Stream para escuchar los cambios de estado en la autenticación (login / logout).
  Stream<User?> get cambiosDeAutenticacion => _auth.authStateChanges();

  /// Indica si existe una sesión activa actualmente.
  bool get estaAutenticado => _auth.currentUser != null;

  /// Inicia sesión con correo electrónico y contraseña.
  Future<void> ingresar(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registra una nueva cuenta de usuario con correo electrónico y contraseña.
  Future<void> registrar(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Cierra la sesión activa del usuario.
  Future<void> salir() async {
    await _auth.signOut();
  }
}

/// Traduce las excepciones comunes de FirebaseAuth a mensajes comprensibles en español.
String mensajeDeError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No existe una cuenta con ese correo.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Correo o contraseña incorrectos.';
    case 'email-already-in-use':
      return 'Este correo ya está registrado.';
    case 'invalid-email':
      return 'El correo no es válido.';
    case 'weak-password':
      return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
    default:
      return e.message ?? 'Ocurrió un error. Intenta nuevamente.';
  }
}
