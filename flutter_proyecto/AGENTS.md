# Reglas del proyecto
- App Flutter "Gestor de Gastos Personales", en español.
- Estructura: lib/pages (pantallas), lib/services (Firebase), lib/models, lib/routers.dart.
- Navegación solo con go_router (context.go). Sesión controlada por redirect en routers.dart.
- Autenticación con firebase_auth, datos con cloud_firestore (usuarios/{uid}/gastos).
- Las pantallas no llaman a Firebase directamente: usan clases de lib/services.
- Código simple y comentado en español; que un estudiante pueda explicarlo.
- No crear carpetas views/ ni archivos duplicados.
