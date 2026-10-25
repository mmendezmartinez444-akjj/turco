import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/turco_icons.dart';
import '../../core/utils/formato.dart';
import '../../data/models/estilista.dart';
import '../../router/app_router.dart';
import '../../viewmodels/estilistas_view_model.dart';
import '../../widgets/avatares.dart';

/// RF6 · Pantalla Estilistas (CustomScrollView + SliverAppBar + SliverList).
class EstilistasScreen extends StatelessWidget {
  const EstilistasScreen({super.key, required this.deps});

  final AppDependencies deps;

  EstilistasViewModel get vm => deps.estilistas;

  /// Va a la Agenda con el filtro del estilista. El identificador viaja como
  /// parámetro de consulta: /agenda?estilista=3
  void _abrirAgenda(BuildContext context, Estilista e) {
    deps.agenda.irAHoy();
    deps.agenda.filtrarEstilista(e.id);
    context.go(Rutas.agendaDeEstilista(e.id));
  }

  @override
  Widget build(BuildContext context) {
    final m = context.tokens.margenPantalla;
    return Scaffold(
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final lista = vm.estilistas;
          return CustomScrollView(
            key: const PageStorageKey<String>('estilistas-lista'),
            slivers: [
              _Cabecera(
                subtitulo:
                    '${Formato.plural(lista.length, 'profesional', 'profesionales')} · '
                    '${Formato.plural(vm.totalProgramadosHoy, 'turno programado', 'turnos programados')} hoy',
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(m, 14, m, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: EdgeInsets.only(bottom: context.tokens.espacio),
                      child: _TarjetaEstilista(
                        vm: vm,
                        estilista: lista[i],
                        alTocar: () => _abrirAgenda(context, lista[i]),
                      ),
                    ),
                    childCount: lista.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// SliverAppBar plegable (pinned + expandedHeight).
class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.subtitulo});

  final String subtitulo;

  static const double _expandida = 170;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final arriba = MediaQuery.paddingOf(context).top;
    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandida,
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      surfaceTintColor: cs.primary,
      flexibleSpace: LayoutBuilder(
        builder: (context, c) {
          final minimo = kToolbarHeight + arriba;
          final rango = (_expandida + arriba) - minimo;
          final t = rango <= 0 ? 0.0 : ((c.maxHeight - minimo) / rango).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Título pequeño cuando la barra está plegada.
              Positioned(
                left: 20,
                right: 20,
                top: arriba,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: (1 - t * 2).clamp(0.0, 1.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Estilistas',
                      style: context.textos.tituloBarra.copyWith(color: cs.onPrimary),
                    ),
                  ),
                ),
              ),
              // Contenido grande cuando está desplegada.
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: Opacity(
                  opacity: ((t - 0.35) / 0.65).clamp(0.0, 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(TurcoIcons.contact, size: 28, color: cs.onPrimary),
                      const SizedBox(height: 4),
                      Text('Estilistas', style: tt.headlineMedium?.copyWith(color: cs.onPrimary)),
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textos.secundario.copyWith(color: cs.onPrimary.withAlpha(220)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaEstilista extends StatelessWidget {
  const _TarjetaEstilista({required this.vm, required this.estilista, required this.alTocar});

  final EstilistasViewModel vm;
  final Estilista estilista;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final hoy = vm.turnosHoy(estilista.id);
    final grupos = vm.serviciosPorCategoria(estilista);
    return Card(
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarEstilista(avatar: estilista.avatar),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estilista.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    // Servicios que realiza, agrupados por categoría.
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final g in grupos.entries)
                          Tooltip(
                            message: g.value.map((s) => s.nombre).join(', '),
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(context.tokens.radioChip),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: Text(
                                g.key.etiqueta,
                                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hoy == 0 ? 'Sin turnos hoy' : '${Formato.plural(hoy, 'turno', 'turnos')} hoy',
                      style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: hoy == 0 ? cs.onSurfaceVariant : cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(TurcoIcons.chevronRight, size: 22, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
