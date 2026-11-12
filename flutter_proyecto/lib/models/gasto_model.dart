import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos que representa un Gasto dentro de la aplicación.
class Gasto {
  final String id;
  final double monto;
  final String categoria;
  final String descripcion;
  final DateTime fecha;

  const Gasto({
    this.id = '',
    required this.monto,
    required this.categoria,
    required this.descripcion,
    required this.fecha,
  });

  /// Convierte la instancia de Gasto a un Map para guardarlo en Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'monto': monto,
      'categoria': categoria,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  /// Crea un objeto Gasto a partir de un Map proveniente de Cloud Firestore.
  factory Gasto.fromMap(Map<String, dynamic> map, String id) {
    // Conversión segura de la fecha (Timestamp de Firestore a DateTime).
    DateTime fechaConvertida = DateTime.now();
    if (map['fecha'] is Timestamp) {
      fechaConvertida = (map['fecha'] as Timestamp).toDate();
    } else if (map['fecha'] is String) {
      fechaConvertida = DateTime.tryParse(map['fecha']) ?? DateTime.now();
    }

    // Conversión segura del monto numérico.
    double montoConvertido = 0.0;
    if (map['monto'] is num) {
      montoConvertido = (map['monto'] as num).toDouble();
    }

    return Gasto(
      id: id,
      monto: montoConvertido,
      categoria: (map['categoria'] as String?) ?? 'Otros',
      descripcion: (map['descripcion'] as String?) ?? '',
      fecha: fechaConvertida,
    );
  }

  /// Permite crear una copia modificada del objeto Gasto.
  Gasto copyWith({
    String? id,
    double? monto,
    String? categoria,
    String? descripcion,
    DateTime? fecha,
  }) {
    return Gasto(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
    );
  }
}
