import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/turco_icons.dart';
import '../../../core/utils/formato.dart';
import '../../../data/models/enums.dart';
import '../../../widgets/estado_chip.dart';

/// Tarjeta de un turno en la lista de la Agenda.
class TarjetaTurno extends StatelessWidget {
  const TarjetaTurno({
    super.key,
    required this.inicio,
    required this.fin,
    required this.cliente,
    required this.servicios,
    required this.estilista,
    required this.estado,
    required this.alTocar,
    this.alMantener,
  });

  final DateTime inicio;
  final DateTime fin;
  final String cliente;
  final String servicios;
  final String estilista;
  final EstadoTurno estado;
  final VoidCallback alTocar;
  final VoidCallback? alMantener;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final colores = ColoresEstado.de(cs, estado);
    final radio = BorderRadius.circular(context.tokens.radioTarjeta);
    return Opacity(
      opacity: estado == EstadoTurno.cancelado ? 0.75 : 1,
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: radio,
        child: InkWell(
          borderRadius: radio,
          onTap: alTocar,
          onLongPress: alMantener,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(color: colores.barra, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Formato.hora(inicio), style: tt.titleSmall),
                        const SizedBox(height: 2),
                        Text(Formato.hora(fin), style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente, maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          servicios,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(TurcoIcons.user, size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                estilista,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            EstadoChip(estado),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
