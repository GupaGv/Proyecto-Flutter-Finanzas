import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos que representa un Ingreso dentro de la aplicación.
class Ingreso {
  final String id;
  final double monto;
  final String descripcion;
  final DateTime fecha;

  const Ingreso({
    this.id = '',
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  /// Convierte la instancia de Ingreso a un Map para guardarlo en Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'monto': monto,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  /// Crea un objeto Ingreso a partir de un Map proveniente de Cloud Firestore.
  factory Ingreso.fromMap(Map<String, dynamic> map, String id) {
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

    return Ingreso(
      id: id,
      monto: montoConvertido,
      descripcion: (map['descripcion'] as String?) ?? '',
      fecha: fechaConvertida,
    );
  }

  /// Permite crear una copia modificada del objeto Ingreso.
  Ingreso copyWith({
    String? id,
    double? monto,
    String? descripcion,
    DateTime? fecha,
  }) {
    return Ingreso(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
    );
  }
}
