import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/models/enums.dart';

/// Colores de cada estado, tomados del ColorScheme (nunca fijos).
class ColoresEstado {
  const ColoresEstado(this.fondo, this.texto, this.barra);

  final Color fondo;
  final Color texto;
  final Color barra;

  static ColoresEstado de(ColorScheme cs, EstadoTurno e) {
    switch (e) {
      case EstadoTurno.programado:
        return ColoresEstado(cs.primaryContainer, cs.onPrimaryContainer, cs.primary);
      case EstadoTurno.completado:
        return ColoresEstado(cs.tertiaryContainer, cs.onTertiaryContainer, cs.tertiary);
      case EstadoTurno.cancelado:
        return ColoresEstado(cs.errorContainer, cs.onErrorContainer, cs.error);
    }
  }
}

/// Etiqueta de estado de un turno.
class EstadoChip extends StatelessWidget {
  const EstadoChip(this.estado, {super.key});

  final EstadoTurno estado;

  @override
  Widget build(BuildContext context) {
    final c = ColoresEstado.de(context.cs, estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.fondo,
        borderRadius: BorderRadius.circular(context.tokens.radioChip),
      ),
      child: Text(
        estado.etiqueta,
        style: context.tt.labelSmall?.copyWith(color: c.texto, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Pastilla informativa (por ejemplo, el público de un servicio).
class Pastilla extends StatelessWidget {
  const Pastilla(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.cs.secondaryContainer,
        borderRadius: BorderRadius.circular(context.tokens.radioChip),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.tt.labelSmall?.copyWith(
          color: context.cs.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
