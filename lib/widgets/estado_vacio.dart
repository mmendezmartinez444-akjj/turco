import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Mensaje con ilustración para listas vacías o recursos no encontrados.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.imagen,
    required this.titulo,
    required this.mensaje,
    this.error = false,
    this.accion,
    this.tamano = 120,
    this.margenSuperior = 28,
  });

  final String imagen;
  final String titulo;
  final String mensaje;

  /// Usa la paleta de error (por ejemplo, "turno no encontrado").
  final bool error;
  final Widget? accion;
  final double tamano;
  final double margenSuperior;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final fondo = error ? cs.errorContainer : cs.primaryContainer;
    final tinta = error ? cs.error : cs.primary;
    return Padding(
      padding: EdgeInsets.only(top: margenSuperior, left: 24, right: 24, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: tamano,
            height: tamano,
            padding: EdgeInsets.all(tamano * 0.28),
            decoration: BoxDecoration(color: fondo, shape: BoxShape.circle),
            child: Image.asset(imagen, color: tinta),
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: context.textos.destacado,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              mensaje,
              textAlign: TextAlign.center,
              style: context.textos.secundario.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          if (accion != null) ...[const SizedBox(height: 14), accion!],
        ],
      ),
    );
  }
}
