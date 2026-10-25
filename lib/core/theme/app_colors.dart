import 'package:flutter/material.dart';

/// Esquemas de color Material 3 de Turco.
///
/// El diseño original usa seedColor 0xFF00695C (verde azulado). Para esta
/// versión se generó la misma estructura tonal de Material 3 a partir de una
/// semilla azul acero (0xFF1F4E6E) con un terciario bronce, que da un aire
/// más sobrio y masculino sin cambiar la jerarquía de roles del diseño
/// (primary, primaryContainer, secondaryContainer, tertiary, error, surface...).
///
/// Los widgets nunca usan estos valores directamente: siempre leen
/// `Theme.of(context).colorScheme`.
class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF1F4E6E);

  static const ColorScheme claro = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF006495),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCBE6FF),
    onPrimaryContainer: Color(0xFF001E30),
    secondary: Color(0xFF50606F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD4E4F6),
    onSecondaryContainer: Color(0xFF0D1D29),
    tertiary: Color(0xFF7C5734),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFDCC0),
    onTertiaryContainer: Color(0xFF2D1600),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF6F9FC),
    onSurface: Color(0xFF181C20),
    onSurfaceVariant: Color(0xFF41474D),
    surfaceDim: Color(0xFFD7DADE),
    surfaceBright: Color(0xFFF6F9FC),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF0F3F7),
    surfaceContainer: Color(0xFFE9EEF3),
    surfaceContainerHigh: Color(0xFFE4E8ED),
    surfaceContainerHighest: Color(0xFFDEE3E8),
    outline: Color(0xFF72787E),
    outlineVariant: Color(0xFFC1C7CE),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2D3135),
    onInverseSurface: Color(0xFFEEF1F5),
    inversePrimary: Color(0xFF8FCDFF),
  );

  static const ColorScheme oscuro = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8FCDFF),
    onPrimary: Color(0xFF003450),
    primaryContainer: Color(0xFF004B71),
    onPrimaryContainer: Color(0xFFCBE6FF),
    secondary: Color(0xFFB8C8D9),
    onSecondary: Color(0xFF22323F),
    secondaryContainer: Color(0xFF394856),
    onSecondaryContainer: Color(0xFFD4E4F6),
    tertiary: Color(0xFFEEBD93),
    onTertiary: Color(0xFF47290B),
    tertiaryContainer: Color(0xFF613F1F),
    onTertiaryContainer: Color(0xFFFFDCC0),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0F1418),
    onSurface: Color(0xFFDEE3E8),
    onSurfaceVariant: Color(0xFFC1C7CE),
    surfaceDim: Color(0xFF0F1418),
    surfaceBright: Color(0xFF353A3E),
    surfaceContainerLowest: Color(0xFF0A0F12),
    surfaceContainerLow: Color(0xFF171C20),
    surfaceContainer: Color(0xFF1B2024),
    surfaceContainerHigh: Color(0xFF262B2F),
    surfaceContainerHighest: Color(0xFF30353A),
    outline: Color(0xFF8B9198),
    outlineVariant: Color(0xFF41474D),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFDEE3E8),
    onInverseSurface: Color(0xFF2D3135),
    inversePrimary: Color(0xFF006495),
  );
}
