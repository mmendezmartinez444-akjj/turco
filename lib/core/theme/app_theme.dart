import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Radios y espacios del diseño. Se exponen como extensión del tema para que
/// ningún widget use valores sueltos.
@immutable
class TurcoTokens extends ThemeExtension<TurcoTokens> {
  const TurcoTokens({
    this.radioTarjeta = 16,
    this.radioCampo = 12,
    this.radioChip = 8,
    this.radioFranja = 10,
    this.radioResumen = 14,
    this.radioDia = 18,
    this.radioHoja = 28,
    this.margenPantalla = 16,
    this.espacio = 10,
    this.espacioGrande = 14,
    this.alturaCampo = 52,
    this.alturaBoton = 46,
  });

  final double radioTarjeta;
  final double radioCampo;
  final double radioChip;
  final double radioFranja;
  final double radioResumen;
  final double radioDia;
  final double radioHoja;
  final double margenPantalla;
  final double espacio;
  final double espacioGrande;
  final double alturaCampo;
  final double alturaBoton;

  @override
  TurcoTokens copyWith({double? radioTarjeta}) =>
      TurcoTokens(radioTarjeta: radioTarjeta ?? this.radioTarjeta);

  @override
  TurcoTokens lerp(ThemeExtension<TurcoTokens>? other, double t) => this;
}

/// Estilos de texto propios del diseño que no tienen un rol directo en
/// TextTheme. Forman parte del tema global (no se usan tamaños sueltos).
@immutable
class TurcoTextos extends ThemeExtension<TurcoTextos> {
  const TurcoTextos({
    required this.tituloBarra,
    required this.tituloHoja,
    required this.destacado,
    required this.cifra,
    required this.secundario,
  });

  /// 20 · SemiBold: títulos de pantalla y de diálogos.
  final TextStyle tituloBarra;

  /// 18 · SemiBold: títulos de hojas inferiores.
  final TextStyle tituloHoja;

  /// 17 · SemiBold: nombres destacados y títulos de mensajes vacíos.
  final TextStyle destacado;

  /// 20 · SemiBold: cifras del resumen del día.
  final TextStyle cifra;

  /// 13 · Regular: textos secundarios (teléfonos, descripciones).
  final TextStyle secundario;

  @override
  TurcoTextos copyWith() => this;

  @override
  TurcoTextos lerp(ThemeExtension<TurcoTextos>? other, double t) => this;
}

class AppTheme {
  AppTheme._();

  static ThemeData claro() => _construir(AppColors.claro);
  static ThemeData oscuro() => _construir(AppColors.oscuro);

  static const String fuente = 'Poppins';

  static TextTheme _texto(ColorScheme cs) {
    const base = TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    );
    return base.apply(
      fontFamily: fuente,
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );
  }

  static ThemeData _construir(ColorScheme cs) {
    const tokens = TurcoTokens();
    final tt = _texto(cs);
    final campo = BorderRadius.circular(tokens.radioCampo);
    const pastilla = StadiumBorder();
    final tamBoton = Size(64, tokens.alturaBoton);
    final textos = TurcoTextos(
      tituloBarra: tt.titleLarge!.copyWith(fontSize: 20),
      tituloHoja: tt.titleLarge!.copyWith(fontSize: 18),
      destacado: tt.titleLarge!.copyWith(fontSize: 17),
      cifra: tt.titleLarge!.copyWith(fontSize: 20),
      secundario: tt.bodyMedium!.copyWith(fontSize: 13),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: cs.brightness,
      fontFamily: fuente,
      textTheme: tt,
      scaffoldBackgroundColor: cs.surface,
      extensions: [tokens, textos],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        titleSpacing: 16,
        titleTextStyle: textos.tituloBarra.copyWith(color: cs.onSurface),
        iconTheme: IconThemeData(color: cs.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: cs.onSurfaceVariant, size: 22),
      ),
      iconTheme: IconThemeData(color: cs.onSurfaceVariant, size: 22),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radioTarjeta),
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamBoton,
          shape: pastilla,
          textStyle: tt.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tamBoton,
          shape: pastilla,
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          textStyle: tt.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 40),
          shape: pastilla,
          textStyle: tt.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 3,
        extendedTextStyle: tt.labelLarge,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        border: OutlineInputBorder(borderRadius: campo, borderSide: BorderSide(color: cs.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: campo, borderSide: BorderSide(color: cs.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: campo, borderSide: BorderSide(color: cs.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: campo, borderSide: BorderSide(color: cs.error, width: 2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: campo, borderSide: BorderSide(color: cs.error, width: 2)),
        errorStyle: tt.bodySmall?.copyWith(color: cs.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surface,
        selectedColor: cs.secondaryContainer,
        checkmarkColor: cs.onSecondaryContainer,
        labelStyle: tt.labelMedium?.copyWith(
          color: WidgetStateColor.resolveWith(
            (e) => e.contains(WidgetState.selected) ? cs.onSecondaryContainer : cs.onSurfaceVariant,
          ),
        ),
        secondaryLabelStyle: tt.labelMedium?.copyWith(color: cs.onSecondaryContainer),
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radioChip)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        showCheckmark: true,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(tt.labelMedium),
          visualDensity: VisualDensity.standard,
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          side: WidgetStatePropertyAll(BorderSide(color: cs.outline)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: cs.surfaceContainer,
        indicatorColor: cs.secondaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final sel = estados.contains(WidgetState.selected);
          return tt.bodySmall?.copyWith(
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? cs.onSurface : cs.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final sel = estados.contains(WidgetState.selected);
          return IconThemeData(size: 22, color: sel ? cs.onSecondaryContainer : cs.onSurfaceVariant);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        actionTextColor: cs.inversePrimary,
        contentTextStyle: tt.bodyMedium?.copyWith(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radioHoja)),
        titleTextStyle: textos.tituloBarra.copyWith(color: cs.onSurface),
        contentTextStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        modalBackgroundColor: cs.surface,
        showDragHandle: true,
        dragHandleColor: cs.outlineVariant,
        dragHandleSize: const Size(36, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radioHoja)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainerHighest,
        surfaceTintColor: cs.surfaceContainerHighest,
        textStyle: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: cs.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radioCampo)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        titleTextStyle: tt.titleSmall?.copyWith(color: cs.onSurface),
        subtitleTextStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary),
    );
  }
}

/// Atajos de lectura del tema.
extension TemaContexto on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  TurcoTokens get tokens => Theme.of(this).extension<TurcoTokens>() ?? const TurcoTokens();
  TurcoTextos get textos => Theme.of(this).extension<TurcoTextos>()!;
}
