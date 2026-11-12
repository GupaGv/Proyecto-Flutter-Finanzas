import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gasto_model.dart';
import 'auth_service.dart';

/// Servicio encargado de la persistencia de gastos en Cloud Firestore.
/// Gestiona la colección: usuarios/{uid}/gastos
class GastoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Retorna la referencia a la subcolección de gastos del usuario activo.
  CollectionReference<Map<String, dynamic>>? get _coleccionGastos {
    final uid = _authService.usuarioActual?.uid;
    if (uid == null) return null;
    return _firestore.collection('usuarios').doc(uid).collection('gastos');
  }

  /// Retorna un Stream con la lista de gastos en tiempo real, ordenados por fecha descendente.
  Stream<List<Gasto>> obtenerGastos() {
    final coleccion = _coleccionGastos;
    if (coleccion == null) {
      return Stream.value([]);
    }

    return coleccion
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Gasto.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Agrega un nuevo gasto a la base de datos de Cloud Firestore.
  Future<void> agregar(Gasto gasto) async {
    final coleccion = _coleccionGastos;
    if (coleccion == null) {
      throw Exception('No hay un usuario autenticado para registrar el gasto.');
    }
    await coleccion.add(gasto.toMap());
  }

  /// Edita y actualiza un gasto existente según su id.
  Future<void> editar(Gasto gasto) async {
    final coleccion = _coleccionGastos;
    if (coleccion == null) {
      throw Exception('No hay un usuario autenticado para editar el gasto.');
    }
    if (gasto.id.isEmpty) {
      throw Exception('El id del gasto no puede estar vacío para editarlo.');
    }
    await coleccion.doc(gasto.id).update(gasto.toMap());
  }

  /// Elimina un gasto de la base de datos según su id.
  Future<void> eliminar(String id) async {
    final coleccion = _coleccionGastos;
    if (coleccion == null) {
      throw Exception('No hay un usuario autenticado para eliminar el gasto.');
    }
    await coleccion.doc(id).delete();
  }
}
