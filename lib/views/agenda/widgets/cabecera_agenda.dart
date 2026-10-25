import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/turco_icons.dart';
import '../../../core/utils/formato.dart';
import '../../../data/models/enums.dart';
import '../../../viewmodels/agenda_view_model.dart';
import '../../../widgets/campos.dart';

/// Cabecera de la Agenda: tira de días, resumen y filtros.
class CabeceraAgenda extends StatelessWidget {
  const CabeceraAgenda({super.key, required this.vm, required this.alElegirFecha});

  final AgendaViewModel vm;
  final VoidCallback alElegirFecha;

  @override
  Widget build(BuildContext context) {
    final gap = context.tokens.espacio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CabeceraSemana(vm: vm, alElegirFecha: alElegirFecha),
        const SizedBox(height: 8),
        _TiraDias(vm: vm),
        const SizedBox(height: 8),
        Text(
          'Domingo: salón cerrado',
          style: context.tt.labelSmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: context.cs.onSurfaceVariant,
          ),
        ),
        if (!vm.diaSinTurnos) ...[
          SizedBox(height: gap),
          _ResumenDia(resumen: vm.resumen),
        ],
        SizedBox(height: gap),
        _FiltroEstilista(vm: vm),
        SizedBox(height: gap),
        SelectorSegmentado<FiltroEstado>(
          valores: FiltroEstado.values,
          seleccionado: vm.filtroEstado,
          etiqueta: (f) => f.etiqueta,
          alCambiar: vm.filtrarEstado,
        ),
      ],
    );
  }
}

class _CabeceraSemana extends StatelessWidget {
  const _CabeceraSemana({required this.vm, required this.alElegirFecha});

  final AgendaViewModel vm;
  final VoidCallback alElegirFecha;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                tooltip: 'Semana anterior',
                visualDensity: VisualDensity.compact,
                onPressed: vm.semanaAnterior,
                icon: Icon(TurcoIcons.chevronLeft, color: cs.onSurfaceVariant),
              ),
              Flexible(
                child: Text(
                  Formato.mesAnio(vm.fecha),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.tt.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Semana siguiente',
                visualDensity: VisualDensity.compact,
                onPressed: vm.semanaSiguiente,
                icon: Icon(TurcoIcons.chevronRight, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: alElegirFecha,
          style: TextButton.styleFrom(
            textStyle: context.tt.labelMedium,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          icon: const Icon(TurcoIcons.calendar, size: 18),
          label: const Text('Elegir fecha'),
        ),
      ],
    );
  }
}

/// Tira horizontal con los siete días de la semana (ListView.builder).
class _TiraDias extends StatelessWidget {
  const _TiraDias({required this.vm});

  final AgendaViewModel vm;

  @override
  Widget build(BuildContext context) {
    final dias = vm.semana;
    const separacion = 4.0;
    return SizedBox(
      height: 60,
      child: LayoutBuilder(
        builder: (context, c) {
          final ancho = (c.maxWidth + separacion) / dias.length;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemExtent: ancho,
            itemCount: dias.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: separacion),
              child: _Dia(
                dia: dias[i],
                seleccionado: Fechas.mismoDia(dias[i], vm.fecha),
                hoy: vm.esHoy(dias[i]),
                alTocar: () => vm.seleccionarFecha(dias[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({required this.dia, required this.seleccionado, required this.hoy, required this.alTocar});

  final DateTime dia;
  final bool seleccionado;
  final bool hoy;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final radio = BorderRadius.circular(context.tokens.radioDia);
    final domingo = Fechas.esDomingo(dia);
    final colorTexto = seleccionado ? cs.onPrimary : cs.onSurface;
    final colorDia = seleccionado ? cs.onPrimary : (hoy ? cs.primary : cs.onSurfaceVariant);
    return Opacity(
      opacity: domingo && !seleccionado ? 0.4 : 1,
      child: Material(
        color: seleccionado ? cs.primary : cs.surface,
        borderRadius: radio,
        child: InkWell(
          borderRadius: radio,
          onTap: alTocar,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(Formato.diaCorto(dia), style: tt.labelSmall?.copyWith(color: colorDia)),
              const SizedBox(height: 2),
              Text(
                '${dia.day}',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorTexto),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenDia extends StatelessWidget {
  const _ResumenDia({required this.resumen});

  final ResumenDia resumen;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Row(
      children: [
        Expanded(child: _Dato(valor: '${resumen.programados}', etiqueta: 'Programados', color: cs.primary)),
        const SizedBox(width: 8),
        Expanded(child: _Dato(valor: '${resumen.completados}', etiqueta: 'Completados', color: cs.tertiary)),
        const SizedBox(width: 8),
        Expanded(child: _Dato(valor: Formato.dinero(resumen.ingreso), etiqueta: 'Ingreso est.', color: cs.onSurface)),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.valor, required this.etiqueta, required this.color});

  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cs.surfaceContainer,
        borderRadius: BorderRadius.circular(context.tokens.radioResumen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor, style: context.textos.cifra.copyWith(color: color)),
          ),
          Text(
            etiqueta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: context.cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chips de filtro por estilista, con la opción Todos.
class _FiltroEstilista extends StatelessWidget {
  const _FiltroEstilista({required this.vm});

  final AgendaViewModel vm;

  @override
  Widget build(BuildContext context) {
    final opciones = <(int?, String)>[
      (null, 'Todos'),
      for (final e in vm.estilistas) (e.id, e.nombreCorto),
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (id, nombre) = opciones[i];
          return FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Text(nombre),
            selected: vm.estilistaId == id,
            onSelected: (_) => vm.filtrarEstilista(id),
          );
        },
      ),
    );
  }
}
