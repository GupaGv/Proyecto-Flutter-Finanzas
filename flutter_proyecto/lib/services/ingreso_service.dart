import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ingreso_model.dart';
import 'auth_service.dart';

/// Servicio encargado de la persistencia de ingresos en Cloud Firestore.
/// Gestiona la colección: usuarios/{uid}/ingresos
class IngresoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Retorna la referencia a la subcolección de ingresos del usuario activo.
  CollectionReference<Map<String, dynamic>>? get _coleccionIngresos {
    final uid = _authService.usuarioActual?.uid;
    if (uid == null) return null;
    return _firestore.collection('usuarios').doc(uid).collection('ingresos');
  }

  /// Retorna un Stream con la lista de ingresos en tiempo real, ordenados por fecha descendente.
  Stream<List<Ingreso>> obtenerIngresos() {
    final coleccion = _coleccionIngresos;
    if (coleccion == null) {
      return Stream.value([]);
    }

    return coleccion
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Ingreso.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Agrega un nuevo ingreso a la base de datos de Cloud Firestore.
  Future<void> agregar(Ingreso ingreso) async {
    final coleccion = _coleccionIngresos;
    if (coleccion == null) {
      throw Exception('No hay un usuario autenticado para registrar el ingreso.');
    }
    await coleccion.add(ingreso.toMap());
  }

  /// Edita y actualiza un ingreso existente según su id.
  Future<void> editar(Ingreso ingreso) async {
    final coleccion = _coleccionIngresos;
    if (coleccion == null) {
      throw Exception('No hay un usuario autenticado para editar el ingreso.');
    }
    if (ingreso.id.isEmpty) {
      throw Exception('El id del ingreso no puede estar vacío para editarlo.');
    }
    await coleccion.doc(ingreso.id).update(ingreso.toMap());
  }

  /// Elimina un ingreso de la base de datos según su id.
  Future<void> eliminar(String id) async {
    final coleccion = _coleccionIngresos;
    if (coleccion == null) {
      throw Exception('No hay un usuario autenticado para eliminar el ingreso.');
    }
    await coleccion.doc(id).delete();
  }
}
