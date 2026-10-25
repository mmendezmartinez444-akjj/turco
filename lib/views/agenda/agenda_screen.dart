import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/turco_icons.dart';
import '../../core/utils/formato.dart';
import '../../data/models/turno.dart';
import '../../router/app_router.dart';
import '../../viewmodels/agenda_view_model.dart';
import '../../viewmodels/tema_view_model.dart';
import '../../widgets/avatares.dart';
import '../../widgets/estado_vacio.dart';
import '../comun/acciones_turno.dart';
import 'widgets/cabecera_agenda.dart';
import 'widgets/tarjeta_turno.dart';

enum _AccionRapida { completar, cancelar }

/// RF1 · Pantalla Agenda (inicial).
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, required this.deps, this.estilistaId});

  final AppDependencies deps;

  /// Filtro recibido por parámetro de consulta (/agenda?estilista=3).
  final int? estilistaId;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final GlobalKey<ScaffoldMessengerState> _messenger = GlobalKey<ScaffoldMessengerState>();

  AgendaViewModel get vm => widget.deps.agenda;

  @override
  void initState() {
    super.initState();
    _aplicarFiltroDeRuta(widget.estilistaId);
  }

  @override
  void didUpdateWidget(covariant AgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.estilistaId != widget.estilistaId) _aplicarFiltroDeRuta(widget.estilistaId);
  }

  void _aplicarFiltroDeRuta(int? id) {
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) vm.filtrarEstilista(id);
    });
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: vm.fecha,
      firstDate: DateTime(hoy.year - 2),
      lastDate: DateTime(hoy.year + 2, 12, 31),
      helpText: 'Elegir fecha',
    );
    if (elegida != null) vm.seleccionarFecha(elegida);
  }

  void _nuevoTurno() {
    abrirFormularioTurno(
      context,
      widget.deps,
      args: NuevoTurnoArgs(fecha: vm.fecha),
      messenger: _messenger.currentState,
    );
  }

  Future<void> _accionesRapidas(Turno t) async {
    if (!t.esProgramado) return;
    final accion = await showModalBottomSheet<_AccionRapida>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        final cs = ctx.cs;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${vm.nombreCliente(t)} · ${Formato.hora(t.inicio)}',
                  style: ctx.textos.destacado,
                ),
                const SizedBox(height: 4),
                Text(
                  '${vm.servicios(t)} · ${vm.nombreEstilista(t)}',
                  style: ctx.textos.secundario.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(TurcoIcons.circleCheck, color: cs.tertiary),
                  title: Text('Marcar como completado',
                      style: ctx.tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  onTap: () => Navigator.of(ctx).pop(_AccionRapida.completar),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(TurcoIcons.ban, color: cs.error),
                  title: Text('Cancelar turno',
                      style: ctx.tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: cs.error)),
                  onTap: () => Navigator.of(ctx).pop(_AccionRapida.cancelar),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || accion == null) return;
    if (accion == _AccionRapida.completar) {
      await confirmarCompletar(context, widget.deps, t, messenger: _messenger.currentState);
    } else {
      await confirmarCancelar(context, widget.deps, t, messenger: _messenger.currentState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messenger,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const LogoTurco(),
              const SizedBox(width: 12),
              Text('Turco', style: context.tt.titleLarge),
            ],
          ),
          actions: [
            _MenuTema(tema: widget.deps.tema),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-agenda',
          onPressed: _nuevoTurno,
          icon: const Icon(TurcoIcons.plus, size: 20),
          label: const Text('Nuevo turno'),
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final turnos = vm.turnos;
            final m = context.tokens.margenPantalla;
            return ListView.builder(
              key: const PageStorageKey<String>('agenda-turnos'),
              padding: EdgeInsets.fromLTRB(m, 4, m, 96),
              itemCount: 1 + (turnos.isEmpty ? 1 : turnos.length),
              itemBuilder: (context, i) {
                if (i == 0) return CabeceraAgenda(vm: vm, alElegirFecha: _elegirFecha);
                if (turnos.isEmpty) return _vacio();
                final t = turnos[i - 1];
                return Padding(
                  padding: EdgeInsets.only(top: context.tokens.espacio),
                  child: TarjetaTurno(
                    inicio: t.inicio,
                    fin: vm.fin(t),
                    cliente: vm.nombreCliente(t),
                    servicios: vm.servicios(t),
                    estilista: vm.nombreEstilista(t),
                    estado: t.estado,
                    alTocar: () => context.push(Rutas.detalleTurno(t.id)),
                    alMantener: t.esProgramado ? () => _accionesRapidas(t) : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _vacio() {
    if (vm.esDomingo) {
      return const EstadoVacio(
        imagen: 'assets/images/ilustraciones/agenda_vacia.png',
        titulo: 'El salón está cerrado',
        mensaje: 'Los domingos no se atiende. Elige otro día de la semana.',
      );
    }
    if (vm.diaSinTurnos) {
      return const EstadoVacio(
        imagen: 'assets/images/ilustraciones/agenda_vacia.png',
        titulo: 'No hay turnos para este día',
        mensaje: 'Crea el primer turno con el botón de abajo o cambia los filtros.',
      );
    }
    return const EstadoVacio(
      imagen: 'assets/images/ilustraciones/agenda_vacia.png',
      titulo: 'No hay turnos con estos filtros',
      mensaje: 'Cambia el estilista o el estado para ver otros turnos del día.',
    );
  }
}

/// Botón de la barra superior para elegir el modo de tema.
class _MenuTema extends StatelessWidget {
  const _MenuTema({required this.tema});

  final TemaViewModel tema;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    PopupMenuItem<ThemeMode> opcion(ThemeMode modo, IconData icono, String texto) {
      final activo = tema.modo == modo;
      return PopupMenuItem<ThemeMode>(
        value: modo,
        height: 44,
        child: Row(
          children: [
            Icon(icono, size: 18, color: activo ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(texto)),
            if (activo) Icon(TurcoIcons.check, size: 16, color: cs.primary),
          ],
        ),
      );
    }

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Tema',
      icon: Icon(TurcoIcons.sunMoon, color: cs.onSurfaceVariant, size: 22),
      offset: const Offset(0, 48),
      constraints: const BoxConstraints(minWidth: 180),
      onSelected: tema.cambiar,
      itemBuilder: (context) => [
        opcion(ThemeMode.system, TurcoIcons.smartphone, 'Sistema'),
        opcion(ThemeMode.light, TurcoIcons.sun, 'Claro'),
        opcion(ThemeMode.dark, TurcoIcons.moon, 'Oscuro'),
      ],
    );
  }
}
