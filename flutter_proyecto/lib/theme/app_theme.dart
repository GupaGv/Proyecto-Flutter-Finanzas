import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Extension para colores personalizados del sistema de diseño fintech minimalista.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color saldoCardBackground;
  final Color saldoCardText;
  final Color saldoCardSubtext;
  final Color ingreso;
  final Color gasto;
  final Color textSecondary;
  final Color greenSecondary;
  final Color border;

  const AppColorsExtension({
    required this.saldoCardBackground,
    required this.saldoCardText,
    required this.saldoCardSubtext,
    required this.ingreso,
    required this.gasto,
    required this.textSecondary,
    required this.greenSecondary,
    required this.border,
  });

  @override
  AppColorsExtension copyWith({
    Color? saldoCardBackground,
    Color? saldoCardText,
    Color? saldoCardSubtext,
    Color? ingreso,
    Color? gasto,
    Color? textSecondary,
    Color? greenSecondary,
    Color? border,
  }) {
    return AppColorsExtension(
      saldoCardBackground: saldoCardBackground ?? this.saldoCardBackground,
      saldoCardText: saldoCardText ?? this.saldoCardText,
      saldoCardSubtext: saldoCardSubtext ?? this.saldoCardSubtext,
      ingreso: ingreso ?? this.ingreso,
      gasto: gasto ?? this.gasto,
      textSecondary: textSecondary ?? this.textSecondary,
      greenSecondary: greenSecondary ?? this.greenSecondary,
      border: border ?? this.border,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      saldoCardBackground:
          Color.lerp(saldoCardBackground, other.saldoCardBackground, t)!,
      saldoCardText: Color.lerp(saldoCardText, other.saldoCardText, t)!,
      saldoCardSubtext: Color.lerp(saldoCardSubtext, other.saldoCardSubtext, t)!,
      ingreso: Color.lerp(ingreso, other.ingreso, t)!,
      gasto: Color.lerp(gasto, other.gasto, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      greenSecondary: Color.lerp(greenSecondary, other.greenSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// Extensión para acceder rápidamente a los colores personalizados desde el contexto.
extension AppThemeContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

/// Formateador de moneda con intl según la preferencia del usuario.
/// Por defecto COP: sin decimales y con punto como separador de miles.
String formatearMoneda(double monto, String monedaPref) {
  if (monedaPref.contains('EUR')) {
    final f = NumberFormat('#,##0.00', 'es_ES');
    return '€ ${f.format(monto)}';
  } else if (monedaPref.contains('USD')) {
    final f = NumberFormat('#,##0.00', 'en_US');
    return '\$ ${f.format(monto)}';
  } else {
    // COP por defecto: sin decimales, separador de miles con punto
    final f = NumberFormat('#,##0', 'es_CO');
    return '\$ ${f.format(monto.round())}';
  }
}

/// Definición del sistema de temas claro y oscuro con estética fintech minimalista.
class AppTheme {
  // Paleta Claro
  static const Color lightPrimary = Color(0xFF174C3C);
  static const Color lightBackground = Color(0xFFF6F7F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF18251F);
  static const Color lightTextSecondary = Color(0xFF738078);
  static const Color lightGreenSecondary = Color(0xFFC4D8C9);
  static const Color lightBorder = Color(0xFFE4E9E3);
  static const Color lightGasto = Color(0xFFDC665D);
  static const Color lightSaldoCard = Color(0xFF174C3C);

  // Paleta Oscuro
  static const Color darkPrimary = Color(0xFFA8D5BA);
  static const Color darkBackground = Color(0xFF101814);
  static const Color darkSurface = Color(0xFF1C2922);
  static const Color darkText = Color(0xFFF0F5F1);
  static const Color darkTextSecondary = Color(0xFFA1B3A7);
  static const Color darkGreenSecondary = Color(0xFF345544);
  static const Color darkBorder = Color(0xFF304238);
  static const Color darkGasto = Color(0xFFF08A80);
  static const Color darkSaldoCard = Color(0xFF244A37);

  /// Configuración del tema claro.
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: lightGreenSecondary,
      onPrimaryContainer: lightPrimary,
      surface: lightSurface,
      onSurface: lightText,
      error: lightGasto,
      onError: Colors.white,
      outline: lightBorder,
      outlineVariant: lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: lightText,
              displayColor: lightText,
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
      extensions: const [
        AppColorsExtension(
          saldoCardBackground: lightSaldoCard,
          saldoCardText: Colors.white,
          saldoCardSubtext: Color(0xFFD0DDD6),
          ingreso: lightPrimary,
          gasto: lightGasto,
          textSecondary: lightTextSecondary,
          greenSecondary: lightGreenSecondary,
          border: lightBorder,
        ),
      ],
    );
  }

  /// Configuración del tema oscuro.
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: Color(0xFF101814),
      primaryContainer: darkGreenSecondary,
      onPrimaryContainer: darkPrimary,
      surface: darkSurface,
      onSurface: darkText,
      error: darkGasto,
      onError: Color(0xFF101814),
      outline: darkBorder,
      outlineVariant: darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.dark().textTheme.apply(
              bodyColor: darkText,
              displayColor: darkText,
            ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      extensions: const [
        AppColorsExtension(
          saldoCardBackground: darkSaldoCard,
          saldoCardText: darkText,
          saldoCardSubtext: darkTextSecondary,
          ingreso: darkPrimary,
          gasto: darkGasto,
          textSecondary: darkTextSecondary,
          greenSecondary: darkGreenSecondary,
          border: darkBorder,
        ),
      ],
    );
  }
}
