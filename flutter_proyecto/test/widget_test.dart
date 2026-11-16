import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ejemplo/routers.dart';

void main() {
  test('Verificar configuración de rutas de la aplicación', () {
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.register, '/register');
    expect(AppRoutes.home, '/home');
    expect(AppRoutes.perfil, '/perfil');
    expect(AppRoutes.settings, '/settings');
    expect(AppRoutes.gastoForm, '/gasto-form');
    expect(AppRoutes.ingresoForm, '/ingreso-form');
  });
}
