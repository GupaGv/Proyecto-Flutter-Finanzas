import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'routers.dart';
import 'services/preferencias_service.dart';
import 'theme/app_theme.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Punto de entrada principal de la aplicación Flutter.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase antes de utilizar los servicios de autenticación y base de datos.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('es_CO', null);
  Intl.defaultLocale = 'es_CO';

  // Inicializar Preferencias del usuario persistidas en shared_preferences.
  await PreferenciasService().inicializar();

  runApp(const MyApp());
}

/// Widget raíz de la aplicación que configura GoRouter y el sistema de temas fintech (claro/oscuro).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencias = PreferenciasService();

    // ListenableBuilder permite que la app reaccione inmediatamente cuando
    // el usuario cambia el tema (claro/oscuro) o la moneda en SettingsPage.
    return ListenableBuilder(
      listenable: preferencias,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Gestor de Gastos',
          debugShowCheckedModeBanner: false,
          themeMode: preferencias.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: appRouter,
        );
      },
    );
  }
}
