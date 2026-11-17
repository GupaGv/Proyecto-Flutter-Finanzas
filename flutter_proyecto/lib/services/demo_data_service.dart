import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

/// Servicio encargado de generar y limpiar datos de demostración en Cloud Firestore.
/// Permite poblar la aplicación con ingresos y gastos de prueba de los últimos 6 meses,
/// marcados con el campo `demo: true` para poder eliminarlos selectivamente.
class DemoDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Categorías idénticas a las configuradas en gasto_form_page.
  static const List<String> _categoriasGasto = [
    'Alimentación',
    'Transporte',
    'Vivienda',
    'Servicios',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Ropa',
    'Otros',
  ];

  /// Genera y guarda datos de demostración para los últimos 6 meses del usuario actual.
  /// Utiliza WriteBatch en bloques de máximo 500 operaciones para respetar los límites de Firestore.
  Future<int> cargarDemo() async {
    final uid = _authService.usuarioActual?.uid;
    if (uid == null) {
      throw Exception('No hay una sesión activa de usuario para cargar datos.');
    }

    // Limpia datos demo previos para evitar duplicados si se pulsa más de una vez
    await borrarDemo();

    final colGastos = _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('gastos');
    final colIngresos = _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('ingresos');

    // Semilla fija (42) para que los datos sean reproducibles
    final random = Random(42);

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final List<Map<String, dynamic>> ingresosDocs = [];
    final List<Map<String, dynamic>> gastosDocs = [];

    // Generar datos para los últimos 6 meses (5 meses pasados + mes actual)
    for (int m = 5; m >= 0; m--) {
      final mesFecha = DateTime(ahora.year, ahora.month - m, 1);
      final int year = mesFecha.year;
      final int month = mesFecha.month;
      final int ultimoDiaMes = DateTime(year, month + 1, 0).day;
      final int maxDia = (m == 0) ? min(ultimoDiaMes, hoy.day) : ultimoDiaMes;

      if (maxDia < 1) continue;

      // -----------------------------------------------------------------------
      // 1. Ingresos: día 15 y día 30 (último día si el mes no tiene 30)
      //    Montos entre 1.200.000 y 1.800.000 COP
      // -----------------------------------------------------------------------
      if (15 <= maxDia) {
        final double monto1 =
            (1200000 + random.nextInt(61) * 10000).toDouble();
        ingresosDocs.add({
          'monto': monto1,
          'descripcion': 'Primera quincena',
          'fecha': Timestamp.fromDate(DateTime(year, month, 15, 8, 30)),
          'demo': true,
        });
      }

      final int diaFinMes = min(30, ultimoDiaMes);
      if (diaFinMes <= maxDia) {
        final double monto2 =
            (1200000 + random.nextInt(61) * 10000).toDouble();
        ingresosDocs.add({
          'monto': monto2,
          'descripcion': 'Segunda quincena',
          'fecha': Timestamp.fromDate(DateTime(year, month, diaFinMes, 8, 30)),
          'demo': true,
        });
      }

      // -----------------------------------------------------------------------
      // 2. Gastos: entre 25 y 40 por mes, repartidos en días distintos
      // -----------------------------------------------------------------------
      final int cantGastosMes = (m == 0)
          ? max(1, ((25 + random.nextInt(16)) * maxDia / ultimoDiaMes).round())
          : (25 + random.nextInt(16));

      // Arriendo: 700.000 COP entre los días 1 y 5 (pico mensual en Vivienda)
      if (1 <= maxDia) {
        final int diaArriendo = min(maxDia, 1 + random.nextInt(min(5, maxDia)));
        gastosDocs.add({
          'monto': 700000.0,
          'categoria': 'Vivienda',
          'descripcion': 'Pago de arriendo',
          'fecha': Timestamp.fromDate(DateTime(year, month, diaArriendo, 10, 0)),
          'demo': true,
        });
      }

      // Generar los gastos restantes del mes
      for (int i = 0; i < cantGastosMes - 1; i++) {
        final int dia = 1 + random.nextInt(maxDia);
        final int hora = 8 + random.nextInt(13); // 8:00 a 20:00
        final int minuto = random.nextInt(60);
        final fechaGasto = DateTime(year, month, dia, hora, minuto);

        // Selección ponderada de categoría y montos realistas en COP
        final int tipo = random.nextInt(100);

        String categoria;
        String descripcion;
        double monto;

        if (tipo < 35) {
          // Comida: 15.000 a 60.000 COP (con picos ocasionales de supermercado)
          categoria = 'Alimentación';
          final esPicoSupermercado = random.nextInt(6) == 0;
          if (esPicoSupermercado) {
            monto = (80000 + random.nextInt(41) * 1000).toDouble();
            descripcion = 'Supermercado quincenal';
          } else {
            monto = (15000 + random.nextInt(46) * 1000).toDouble();
            const opciones = [
              'Almuerzo ejecutivo',
              'Cafetería y panadería',
              'Cena en restaurante',
              'Frutas y verduras',
              'Compra de mercado',
              'Desayuno de trabajo',
            ];
            descripcion = opciones[random.nextInt(opciones.length)];
          }
        } else if (tipo < 60) {
          // Transporte: 3.000 a 25.000 COP
          categoria = 'Transporte';
          monto = (3000 + random.nextInt(23) * 1000).toDouble();
          const opciones = [
            'Pasaje transporte público',
            'Recarga tarjeta transporte',
            'Gasolina',
            'Carrera de taxi / Uber',
            'Parqueadero',
          ];
          descripcion = opciones[random.nextInt(opciones.length)];
        } else if (tipo < 72) {
          // Servicios: 40.000 a 180.000 COP
          categoria = 'Servicios';
          monto = (40000 + random.nextInt(141) * 1000).toDouble();
          const opciones = [
            'Factura de energía eléctrica',
            'Recibo de internet y telefonía',
            'Factura de agua y acueducto',
            'Recibo de gas natural',
          ];
          descripcion = opciones[random.nextInt(opciones.length)];
        } else if (tipo < 82) {
          // Ocio / Entretenimiento: 40.000 a 180.000 COP
          categoria = 'Entretenimiento';
          monto = (40000 + random.nextInt(141) * 1000).toDouble();
          const opciones = [
            'Salida con amigos',
            'Cine y confitería',
            'Suscripción de streaming',
            'Paseo de fin de semana',
          ];
          descripcion = opciones[random.nextInt(opciones.length)];
        } else if (tipo < 90) {
          // Salud: 40.000 a 180.000 COP
          categoria = 'Salud';
          monto = (40000 + random.nextInt(141) * 1000).toDouble();
          const opciones = [
            'Farmacia y medicamentos',
            'Consulta médica particular',
            'Cuidado personal',
            'Vitaminas y suplementos',
          ];
          descripcion = opciones[random.nextInt(opciones.length)];
        } else if (tipo < 95) {
          // Ropa: 40.000 a 180.000 COP
          categoria = 'Ropa';
          monto = (40000 + random.nextInt(141) * 1000).toDouble();
          const opciones = [
            'Compra de ropa',
            'Calzado nuevo',
            'Prendas y accesorios',
          ];
          descripcion = opciones[random.nextInt(opciones.length)];
        } else if (tipo < 98) {
          // Educación: 40.000 a 180.000 COP
          categoria = 'Educación';
          monto = (40000 + random.nextInt(141) * 1000).toDouble();
          descripcion = 'Libros y materiales educativos';
        } else {
          // Otros: 40.000 a 180.000 COP
          categoria = 'Otros';
          monto = (40000 + random.nextInt(141) * 1000).toDouble();
          descripcion = 'Gasto imprevisto del hogar';
        }

        // Asegurar que la categoría pertenezca a la lista autorizada
        if (!_categoriasGasto.contains(categoria)) {
          categoria = 'Otros';
        }

        gastosDocs.add({
          'monto': monto,
          'categoria': categoria,
          'descripcion': descripcion,
          'fecha': Timestamp.fromDate(fechaGasto),
          'demo': true,
        });
      }
    }

    // -------------------------------------------------------------------------
    // Escritura en Firestore con WriteBatch (máximo 500 ops por lote)
    // -------------------------------------------------------------------------
    WriteBatch batch = _firestore.batch();
    int opsEnBatch = 0;
    int totalRegistros = 0;

    // Escribir ingresos
    for (final docData in ingresosDocs) {
      final docRef = colIngresos.doc();
      batch.set(docRef, docData);
      opsEnBatch++;
      totalRegistros++;
      if (opsEnBatch >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        opsEnBatch = 0;
      }
    }

    // Escribir gastos
    for (final docData in gastosDocs) {
      final docRef = colGastos.doc();
      batch.set(docRef, docData);
      opsEnBatch++;
      totalRegistros++;
      if (opsEnBatch >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        opsEnBatch = 0;
      }
    }

    if (opsEnBatch > 0) {
      await batch.commit();
    }

    return totalRegistros;
  }

  /// Elimina exclusivamente los documentos que tengan el campo `demo == true`
  /// en las colecciones usuarios/{uid}/gastos y usuarios/{uid}/ingresos.
  Future<int> borrarDemo() async {
    final uid = _authService.usuarioActual?.uid;
    if (uid == null) {
      throw Exception('No hay una sesión activa de usuario para borrar datos.');
    }

    final colGastos = _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('gastos');
    final colIngresos = _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('ingresos');

    // Obtener únicamente los documentos marcados como demo
    final snapGastos = await colGastos.where('demo', isEqualTo: true).get();
    final snapIngresos = await colIngresos.where('demo', isEqualTo: true).get();

    WriteBatch batch = _firestore.batch();
    int opsEnBatch = 0;
    int totalEliminados = 0;

    for (final doc in snapGastos.docs) {
      batch.delete(doc.reference);
      opsEnBatch++;
      totalEliminados++;
      if (opsEnBatch >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        opsEnBatch = 0;
      }
    }

    for (final doc in snapIngresos.docs) {
      batch.delete(doc.reference);
      opsEnBatch++;
      totalEliminados++;
      if (opsEnBatch >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        opsEnBatch = 0;
      }
    }

    if (opsEnBatch > 0) {
      await batch.commit();
    }

    return totalEliminados;
  }
}
