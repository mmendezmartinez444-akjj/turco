import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/turco_icons.dart';
import '../../core/utils/formato.dart';
import '../../data/models/enums.dart';
import '../../data/models/servicio.dart';
import '../../data/models/turno.dart';
import '../../viewmodels/servicios_view_model.dart';
import '../../widgets/campos.dart';
import '../../widgets/estado_chip.dart';
import '../../widgets/estado_vacio.dart';
import '../comun/acciones_turno.dart';

/// RF5 · Pantalla Servicios (catálogo en cuadrícula).
class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final GlobalKey<ScaffoldMessengerState> _messenger = GlobalKey<ScaffoldMessengerState>();

  ServiciosViewModel get vm => widget.deps.servicios;

  /// Al tocar un servicio se abre el formulario con ese servicio ya
  /// seleccionado. El dato viaja con `extra`.
  void _reservar(Servicio s) {
    abrirFormularioTurno(
      context,
      widget.deps,
      args: NuevoTurnoArgs(servicioId: s.id),
      messenger: _messenger.currentState,
    );
  }

  /// 2 columnas en menos de 600 dp, 3 entre 600 y 840 dp y 4 en más de 840 dp.
  static int columnas(double ancho) {
    if (ancho < 600) return 2;
    if (ancho <= 840) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final m = context.tokens.margenPantalla;
    return ScaffoldMessenger(
      key: _messenger,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Servicios'),
              Text(
                'Toca un servicio para reservar',
                style: context.tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final servicios = vm.servicios;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                _FiltroCategoria(vm: vm),
                SizedBox(height: context.tokens.espacio + 2),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: m),
                  child: SelectorSegmentado<FiltroPublico>(
                    valores: FiltroPublico.values,
                    seleccionado: vm.publico,
                    etiqueta: (p) => p.etiqueta,
                    alCambiar: vm.filtrarPublico,
                  ),
                ),
                SizedBox(height: context.tokens.espacio + 2),
                Expanded(
                  child: servicios.isEmpty
                      ? const SingleChildScrollView(
                          child: EstadoVacio(
                            imagen: 'assets/images/ilustraciones/sin_resultados.png',
                            titulo: 'No hay servicios',
                            mensaje: 'Ningún servicio coincide con los filtros elegidos.',
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, c) => GridView.builder(
                            key: const PageStorageKey<String>('servicios-grid'),
                            padding: EdgeInsets.fromLTRB(m, 0, m, 16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columnas(c.maxWidth),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              // Alto de la tarjeta: imagen fija + texto escalable
                              // (evita overflow con tamaños de letra grandes).
                              mainAxisExtent: 104 + 92 * MediaQuery.textScalerOf(context).scale(10) / 10,
                            ),
                            itemCount: servicios.length,
                            itemBuilder: (context, i) =>
                                _TarjetaServicio(servicio: servicios[i], alTocar: () => _reservar(servicios[i])),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FiltroCategoria extends StatelessWidget {
  const _FiltroCategoria({required this.vm});

  final ServiciosViewModel vm;

  @override
  Widget build(BuildContext context) {
    final opciones = <Categoria?>[null, ...Categoria.values];
    final m = context.tokens.margenPantalla;
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m),
        itemCount: opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = opciones[i];
          return FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Text(c?.etiqueta ?? 'Todas'),
            selected: vm.categoria == c,
            onSelected: (_) => vm.filtrarCategoria(c),
          );
        },
      ),
    );
  }
}

class _TarjetaServicio extends StatelessWidget {
  const _TarjetaServicio({required this.servicio, required this.alTocar});

  final Servicio servicio;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final tk = context.tokens;
    return Card(
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la categoría.
              Container(
                height: 84,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(tk.radioCampo),
                ),
                child: Image.asset(servicio.categoria.imagen, width: 36, height: 36, color: cs.primary),
              ),
              const SizedBox(height: 6),
              Text(
                servicio.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(TurcoIcons.clock, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      Formato.duracion(servicio.duracionMin),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                  Text(
                    Formato.dinero(servicio.precio),
                    style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(width: double.infinity, child: Pastilla(servicio.publico.etiqueta)),
            ],
          ),
        ),
      ),
    );
  }
}
