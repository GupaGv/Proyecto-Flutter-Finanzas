import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar las preferencias del usuario persistidas en el dispositivo
/// mediante shared_preferences (moneda seleccionada y modo oscuro).
class PreferenciasService extends ChangeNotifier {
  static final PreferenciasService _instancia = PreferenciasService._interno();
  factory PreferenciasService() => _instancia;
  PreferenciasService._interno();

  static const String _claveMoneda = 'pref_moneda';
  static const String _claveModoOscuro = 'pref_modo_oscuro';

  SharedPreferences? _prefs;

  String _moneda = r'COP ($)';
  bool _modoOscuro = false;

  /// Retorna la moneda configurada por el usuario.
  String get moneda => _moneda;

  /// Retorna si el modo oscuro está habilitado.
  bool get modoOscuro => _modoOscuro;

  /// Retorna el ThemeMode correspondiente para MaterialApp.
  ThemeMode get themeMode => _modoOscuro ? ThemeMode.dark : ThemeMode.light;

  /// Retorna únicamente el símbolo de la moneda para formateo en la interfaz.
  String get simboloMoneda {
    if (_moneda.contains('EUR')) return '€';
    if (_moneda.contains('USD')) return r'US$';
    return r'$';
  }

  /// Inicializa el servicio leyendo los valores almacenados en SharedPreferences.
  Future<void> inicializar() async {
    _prefs = await SharedPreferences.getInstance();
    _moneda = _prefs?.getString(_claveMoneda) ?? r'COP ($)';
    _modoOscuro = _prefs?.getBool(_claveModoOscuro) ?? false;
    notifyListeners();
  }

  /// Actualiza la moneda preferida y la guarda en SharedPreferences.
  Future<void> setMoneda(String nuevaMoneda) async {
    if (_moneda == nuevaMoneda) return;
    _moneda = nuevaMoneda;
    await _prefs?.setString(_claveMoneda, nuevaMoneda);
    notifyListeners();
  }

  /// Alterna o establece el modo oscuro y lo guarda en SharedPreferences.
  Future<void> setModoOscuro(bool activo) async {
    if (_modoOscuro == activo) return;
    _modoOscuro = activo;
    await _prefs?.setBool(_claveModoOscuro, activo);
    notifyListeners();
  }
}
