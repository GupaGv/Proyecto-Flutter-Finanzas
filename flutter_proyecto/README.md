# Gestor de Gastos Personales

Aplicación móvil desarrollada en **Flutter** para la administración, registro y seguimiento de finanzas personales. Permite a los usuarios llevar un control integral de sus ingresos y gastos mensuales mediante sincronización en la nube en tiempo real, categorización visual, cálculo de balance disponible y opciones de personalización.

---

## 🚀 Funcionalidades Principales

### 1. Autenticación y Seguridad
- **Inicio de Sesión y Registro** de usuarios con correo electrónico y contraseña.
- **Medidor interactivo de fortaleza de contraseña** en 4 niveles (longitud mínima de 8 caracteres, mayúsculas, números y caracteres especiales) mediante barra de progreso visual.
- **Mostrar / Ocultar contraseñas** en campos seguros.
- Mensajes de error amigables en español traducidos directamente desde Firebase Auth.

### 2. Gestión de Gastos e Ingresos (CRUD en Tiempo Real)
- **Registro y Edición de Gastos**: Formulario interactivo para capturar monto, categoría (Alimentación, Transporte, Servicios, etc.), descripción y fecha con `DatePicker` nativo.
- **Registro y Edición de Ingresos**: Formulario para registrar entradas de dinero (monto, descripción como "Quincena 15", y fecha).
- **Sincronización en la Nube**: Persistencia en **Cloud Firestore** bajo las subcolecciones `usuarios/{uid}/gastos` y `usuarios/{uid}/ingresos`.
- **Eliminación con Deslizamiento (`Dismissible`) y Botón Visible**: Ícono de papelera en cada ítem y botón de eliminación en formularios, ambos con confirmación y manejo de errores.

### 3. Dashboard Financiero y Resumen Mensual
- **Tres Tarjetas Principales**:
  - **Ingresos**: total acumulado de entradas del mes.
  - **Gastos**: total acumulado de salidas del mes.
  - **Disponible**: balance resultante (`ingresos - gastos`), resaltado en color rojo en caso de balance negativo.
- **Selector de Meses**: Navegación intuitiva entre meses con botón de retorno al mes actual. Aplica simultáneamente a ingresos y gastos.
- **Resumen por Categoría**: Totales y porcentajes de gastos por categoría con barras de progreso visuales.
- **Menú en Botón Flotante**: Permite elegir entre registrar un "Nuevo Gasto" o un "Nuevo Ingreso".

### 4. Personalización y Preferencias
- **Selector de Moneda Principal**: Soporte para `COP ($)`, `USD ($)` y `EUR (€)`, reflejado en balances, resúmenes y formularios.
- **Modo Claro / Modo Oscuro**: Alternancia de tema visual aplicado dinámicamente en toda la aplicación.
- **Persistencia Local**: Preferencias guardadas en el dispositivo mediante `shared_preferences`.

### 5. Navegación y Perfil
- Enrutamiento centralizado y declarativo con **GoRouter**.
- Redirección automática de sesión: si no hay usuario autenticado redirige a `/login`, y al autenticarse redirige a `/home`.
- Pantalla de **Perfil** con datos de la cuenta activa (correo, UID) y cierre de sesión seguro.

---

## 🛠️ Tecnologías y Librerías

- **[Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)**: Framework multiplataforma de desarrollo móvil.
- **[Firebase Authentication](https://pub.dev/packages/firebase_auth)**: Gestión de identidad y credenciales de usuario.
- **[Cloud Firestore](https://pub.dev/packages/cloud_firestore)**: Base de datos NoSQL escalable y en tiempo real.
- **[GoRouter](https://pub.dev/packages/go_router)**: Sistema de rutas y navegación declarativa con control de sesión (`redirect`).
- **[Shared Preferences](https://pub.dev/packages/shared_preferences)**: Almacenamiento clave-valor en disco para configuración local.

---

## 📂 Estructura del Código

El proyecto sigue una arquitectura limpia y modular respetando las pautas del curso:

```text
lib/
├── models/
│   ├── gasto_model.dart          # Modelo de datos de gastos (toMap, fromMap, copyWith)
│   └── ingreso_model.dart        # Modelo de datos de ingresos (toMap, fromMap, copyWith)
├── services/
│   ├── auth_service.dart         # Métodos de autenticación y estado del usuario
│   ├── gasto_service.dart        # Operaciones CRUD en Cloud Firestore (usuarios/{uid}/gastos)
│   ├── ingreso_service.dart      # Operaciones CRUD en Cloud Firestore (usuarios/{uid}/ingresos)
│   └── preferencias_service.dart # Persistencia de tema y moneda con SharedPreferences
├── pages/
│   ├── login_page.dart           # Pantalla de inicio de sesión
│   ├── register_page.dart        # Pantalla de registro con medidor de fortaleza
│   ├── home_page.dart            # Panel principal con selector de mes, tarjetas y listas
│   ├── gasto_form_page.dart      # Formulario para crear y editar gastos
│   ├── ingreso_form_page.dart    # Formulario para crear y editar ingresos
│   ├── perfil_page.dart          # Consulta de perfil y logout
│   └── settings_page.dart        # Configuración de moneda y tema
├── firebase_options.dart         # Configuración multiplataforma de Firebase
├── routers.dart                  # Configuración de GoRouter y redirección de sesión
└── main.dart                     # Inicialización de servicios y widget raíz MyApp
```

---

## ⚙️ Cómo Ejecutar el Proyecto

### Requisitos previos
- Tener instalado [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.13 o superior).
- Un emulador de Android/iOS o un dispositivo físico conectado con depuración USB habilitada.

### Pasos de ejecución

1. **Clonar o abrir el repositorio**:
   ```bash
   cd flutter_proyecto
   ```

2. **Obtener las dependencias del proyecto**:
   ```bash
   flutter pub get
   ```

3. **Verificar el análisis estático de código**:
   ```bash
   flutter analyze
   ```

4. **Ejecutar las pruebas unitarias**:
   ```bash
   flutter test
   ```

5. **Iniciar la aplicación en tu emulador o dispositivo**:
   ```bash
   flutter run
   ```
