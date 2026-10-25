import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/turco_icons.dart';

/// Diálogo de confirmación con el estilo del diseño (icono de alerta,
/// título, mensaje y dos acciones de texto).
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String confirmarTexto,
  String cancelarTexto = 'Volver',
  bool destructivo = true,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = ctx.cs;
      return AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(TurcoIcons.triangleAlert, color: destructivo ? cs.error : cs.primary, size: 24),
            const SizedBox(height: 14),
            Text(titulo),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelarTexto),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: destructivo ? cs.error : cs.primary),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmarTexto),
          ),
        ],
      );
    },
  );
  return r ?? false;
}

/// Muestra un SnackBar flotante con acción opcional.
void mostrarAviso(
  ScaffoldMessengerState? messenger,
  String texto, {
  String? accion,
  VoidCallback? alPulsar,
}) {
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        action: (accion != null && alPulsar != null)
            ? SnackBarAction(label: accion, onPressed: alPulsar)
            : null,
      ),
    );
}
