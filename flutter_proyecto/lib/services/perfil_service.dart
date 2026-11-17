import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/perfil_model.dart';
import 'auth_service.dart';

/// Servicio encargado de la persistencia y lectura del perfil de usuario.
/// Guarda y lee en tiempo real el documento en Cloud Firestore:
/// usuarios/{uid}/perfil/datos
/// y actualiza el nombre en FirebaseAuth con currentUser.updateDisplayName.
class PerfilService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Referencia al documento 'datos' dentro de la subcolección 'perfil' del usuario autenticado.
  DocumentReference<Map<String, dynamic>>? get _docPerfil {
    final uid = _authService.usuarioActual?.uid;
    if (uid == null) return null;
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('perfil')
        .doc('datos');
  }

  /// Retorna un Stream con los datos del perfil (avatarId y fotoBase64) en tiempo real.
  Stream<PerfilUsuario> obtenerPerfil() {
    final doc = _docPerfil;
    if (doc == null) {
      return Stream.value(const PerfilUsuario());
    }

    return doc.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return const PerfilUsuario();
      }
      return PerfilUsuario.fromMap(snapshot.data());
    });
  }

  /// Guarda y actualiza la información del perfil del usuario:
  /// 1. Actualiza el nombre en FirebaseAuth usando currentUser.updateDisplayName.
  /// 2. Guarda avatarId y fotoBase64 en usuarios/{uid}/perfil/datos en Cloud Firestore.
  Future<void> guardarPerfil({
    required String nombre,
    required String avatarId,
    String? fotoBase64,
  }) async {
    final usuario = _authService.usuarioActual;
    if (usuario == null) {
      throw Exception('No hay una sesión activa de usuario.');
    }

    // 1. Guardar el nombre en FirebaseAuth
    final nombreLimpio = nombre.trim();
    if (nombreLimpio.isNotEmpty) {
      await usuario.updateDisplayName(nombreLimpio);
      await usuario.reload();
    }

    // 2. Guardar avatarId y fotoBase64 en Firestore
    final doc = _docPerfil;
    if (doc == null) {
      throw Exception('No se pudo acceder a la referencia del perfil.');
    }

    await doc.set({
      'avatarId': avatarId,
      'fotoBase64': fotoBase64,
    }, SetOptions(merge: true));
  }
}
