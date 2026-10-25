import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formato.dart';
import '../../../data/models/horario.dart';

/// Cuadrícula de franjas de 30 minutos (GridView.builder dentro del scroll del
/// formulario, con shrinkWrap y NeverScrollableScrollPhysics).
class CuadriculaFranjas extends StatelessWidget {
  const CuadriculaFranjas({
    super.key,
    required this.franjas,
    required this.elegida,
    required this.alElegir,
    this.error = false,
  });

  final List<Franja> franjas;
  final DateTime? elegida;
  final ValueChanged<DateTime> alElegir;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final columnas = c.maxWidth < 500 ? 4 : (c.maxWidth < 800 ? 6 : 8);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 40,
          ),
          itemCount: franjas.length,
          itemBuilder: (context, i) {
            final f = franjas[i];
            return _BotonFranja(
              franja: f,
              elegida: elegida != null && f.inicio == elegida,
              error: error,
              alTocar: f.disponible ? () => alElegir(f.inicio) : null,
            );
          },
        );
      },
    );
  }
}

class _BotonFranja extends StatelessWidget {
  const _BotonFranja({required this.franja, required this.elegida, required this.error, required this.alTocar});

  final Franja franja;
  final bool elegida;
  final bool error;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final radio = BorderRadius.circular(context.tokens.radioFranja);
    final disponible = franja.disponible;
    final Color fondo;
    final Color texto;
    final BoxBorder? borde;
    if (elegida) {
      fondo = cs.primary;
      texto = cs.onPrimary;
      borde = null;
    } else if (!disponible) {
      fondo = cs.surfaceContainerHighest;
      texto = cs.outline;
      borde = null;
    } else {
      fondo = cs.surface;
      texto = cs.onSurface;
      borde = Border.all(color: error ? cs.error : cs.outline);
    }
    return Opacity(
      opacity: !disponible && !elegida ? 0.55 : 1,
      child: Material(
        color: fondo,
        borderRadius: radio,
        child: InkWell(
          borderRadius: radio,
          onTap: alTocar,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: radio, border: borde),
            child: Text(
              Formato.hora(franja.inicio),
              style: context.tt.labelMedium?.copyWith(
                color: texto,
                fontWeight: elegida ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Leyenda de la cuadrícula: Libre · No disponible · Elegida.
class LeyendaFranjas extends StatelessWidget {
  const LeyendaFranjas({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    Widget item(String texto, {Color? relleno, Color? borde}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: relleno,
                borderRadius: BorderRadius.circular(3),
                border: borde == null ? null : Border.all(color: borde),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              texto,
              style: context.tt.labelSmall?.copyWith(fontWeight: FontWeight.w400, color: cs.onSurfaceVariant),
            ),
          ],
        );
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        item('Libre', borde: cs.outline),
        item('No disponible', relleno: cs.surfaceContainerHighest),
        item('Elegida', relleno: cs.primary),
      ],
    );
  }
}
