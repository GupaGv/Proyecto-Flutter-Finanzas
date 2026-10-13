import 'package:flutter/material.dart';

import 'routers.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Gastos',
      routerConfig: appRouter,
      // routerConfig: le pasa a MaterialApp el "mapa de rutas" que
      // definiste en routers.dart, en vez de darle un solo widget "home".
    );
  }
}
