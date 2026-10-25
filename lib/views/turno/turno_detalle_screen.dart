import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/turco_icons.dart';
import '../../core/utils/formato.dart';
import '../../data/models/enums.dart';
import '../../router/app_router.dart';
import '../../viewmodels/turno_detalle_view_model.dart';
import '../../widgets/avatares.dart';
import '../../widgets/estado_chip.dart';
import '../../widgets/estado_vacio.dart';
import '../comun/acciones_turno.dart';

/// RF2 · Pantalla Detalle de turno (/turno/:id).
class TurnoDetalleScreen extends StatefulWidget {
  const TurnoDetalleScreen({super.key, required this.deps, required this.turnoId});

  final AppDependencies deps;
  final int? turnoId;

  @override
  State<TurnoDetalleScreen> createState() => _TurnoDetalleScreenState();
}

class _TurnoDetalleScreenState extends State<TurnoDetalleScreen> {
  late final TurnoDetalleViewModel vm = TurnoDetalleViewModel(widget.deps.repo, widget.turnoId);

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  void _volver() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.agenda);
    }
  }

  Future<void> _editar() async {
    await abrirFormularioTurno(
      context,
      widget.deps,
      editarId: vm.turnoId,
      messenger: ScaffoldMessenger.maybeOf(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 4,
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: _volver,
              icon: const Icon(TurcoIcons.chevronLeft),
            ),
            title: const Text('Detalle del turno'),
          ),
          body: vm.existe ? _contenido(context) : _noEncontrado(),
          bottomNavigationBar: vm.existe ? _acciones(context) : null,
        );
      },
    );
  }

  Widget _noEncontrado() {
    return SingleChildScrollView(
      child: Center(
        child: EstadoVacio(
          imagen: 'assets/images/ilustraciones/no_encontrado.png',
          titulo: 'No encontramos este turno',
          mensaje: 'El turno no existe o ya no está disponible.',
          error: true,
          tamano: 112,
          margenSuperior: 90,
          accion: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
            onPressed: () => context.go(Rutas.agenda),
            icon: const Icon(TurcoIcons.arrowLeft, size: 18),
            label: const Text('Volver a la agenda'),
          ),
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    final t = vm.turno!;
    final cs = context.cs;
    final tt = context.tt;
    final tk = context.tokens;
    final cliente = vm.cliente;
    final gap = tk.espacio + 2;

    Widget tarjeta({required List<Widget> hijos, double espacio = 10}) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < hijos.length; i++) ...[
                  if (i > 0) SizedBox(height: espacio),
                  hijos[i],
                ],
              ],
            ),
          ),
        );

    Widget dato(IconData icono, String etiqueta, String valor) => Row(
          children: [
            Icon(icono, size: 18, color: cs.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etiqueta,
                      style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w400, color: cs.onSurfaceVariant)),
                  Text(valor, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        );

    final servicios = vm.servicios;
    return ListView(
      padding: EdgeInsets.fromLTRB(tk.margenPantalla, 4, tk.margenPantalla, 16),
      children: [
        tarjeta(hijos: [
          Row(
            children: [
              if (cliente != null)
                AvatarCliente(nombre: cliente.nombre, genero: cliente.genero, tamano: 48)
              else
                const AvatarCliente(nombre: '?', genero: Genero.hombre, tamano: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente?.nombre ?? 'Cliente eliminado',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.destacado,
                    ),
                    const SizedBox(height: 2),
                    if (cliente != null)
                      Row(
                        children: [
                          Icon(TurcoIcons.phone, size: 13, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(Formato.telefono(cliente.telefono),
                              style: context.textos.secundario.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EstadoChip(t.estado),
            ],
          ),
          dato(TurcoIcons.calendar, 'Fecha', Formato.fechaLarga(t.inicio)),
          dato(
            TurcoIcons.clock,
            'Hora',
            '${Formato.hora(t.inicio)} a ${Formato.hora(vm.fin!)} (${Formato.duracion(vm.duracion)})',
          ),
          dato(TurcoIcons.user, 'Estilista', vm.estilista?.nombre ?? '—'),
        ]),
        SizedBox(height: gap),
        tarjeta(hijos: [
          Text('Servicios', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          for (final s in servicios) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nombre, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      Text(Formato.duracion(s.duracionMin),
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(Formato.dinero(s.precio), style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const Divider(),
          ],
          Row(
            children: [
              Expanded(child: Text('Total', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
              Text(
                Formato.dinero(vm.total),
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
              ),
            ],
          ),
        ]),
        SizedBox(height: gap),
        tarjeta(espacio: 6, hijos: [
          Text('Notas', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          // Área de notas con scroll propio: nunca desborda aunque el texto sea largo.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 140),
            child: Scrollbar(
              child: SingleChildScrollView(
                primary: false,
                child: Text(
                  t.tieneNotas ? t.notas! : 'Sin notas',
                  style: context.textos.secundario.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: t.tieneNotas ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ]),
        SizedBox(height: gap),
        Text(
          'Creado el ${Formato.fechaNumerica(t.creado)} · Modificado el ${Formato.fechaNumerica(t.modificado)}',
          style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w400, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _acciones(BuildContext context) {
    final cs = context.cs;
    final t = vm.turno!;
    return Material(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          child: vm.editable
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                        onPressed: _editar,
                        icon: const Icon(TurcoIcons.pencil, size: 18),
                        label: const _Ajustado('Editar'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                        onPressed: () => confirmarCompletar(
                          context,
                          widget.deps,
                          t,
                          messenger: ScaffoldMessenger.maybeOf(context),
                        ),
                        icon: const Icon(TurcoIcons.check, size: 18),
                        label: const _Ajustado('Completar'),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: cs.error, minimumSize: const Size(0, 44)),
                        onPressed: () => confirmarCancelar(
                          context,
                          widget.deps,
                          t,
                          messenger: ScaffoldMessenger.maybeOf(context),
                        ),
                        icon: const Icon(TurcoIcons.ban, size: 18),
                        label: const _Ajustado('Cancelar'),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(TurcoIcons.lock, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Turno ${t.estado.etiqueta.toLowerCase()}: solo lectura',
                          style: context.tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Texto de botón que se reduce en pantallas muy estrechas en vez de desbordar.
class _Ajustado extends StatelessWidget {
  const _Ajustado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) =>
      FittedBox(fit: BoxFit.scaleDown, child: Text(texto, maxLines: 1));
}
