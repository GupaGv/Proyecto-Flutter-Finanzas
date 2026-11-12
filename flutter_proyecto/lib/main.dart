import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'routers.dart';

/// Punto de entrada principal de la aplicación Flutter.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase antes de utilizar los servicios de autenticación y base de datos.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

/// Widget raíz de la aplicación que configura GoRouter y el tema visual.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestor de Gastos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
