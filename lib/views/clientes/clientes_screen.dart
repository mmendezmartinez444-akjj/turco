import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/turco_icons.dart';
import '../../core/utils/formato.dart';
import '../../data/models/cliente.dart';
import '../../data/models/enums.dart';
import '../../data/models/turno.dart';
import '../../router/app_router.dart';
import '../../viewmodels/clientes_view_model.dart';
import '../../widgets/avatares.dart';
import '../../widgets/campos.dart';
import '../../widgets/dialogos.dart';
import '../../widgets/estado_vacio.dart';
import '../comun/acciones_turno.dart';
import 'widgets/cliente_detalle_sheet.dart';
import 'widgets/cliente_form_sheet.dart';

/// RF4 · Pantalla Clientes.
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final GlobalKey<ScaffoldMessengerState> _messenger = GlobalKey<ScaffoldMessengerState>();
  late final TextEditingController _busqueda = TextEditingController(text: vm.busqueda);
  final FocusNode _fBusqueda = FocusNode();

  ClientesViewModel get vm => widget.deps.clientes;

  @override
  void dispose() {
    _busqueda.dispose();
    _fBusqueda.dispose();
    super.dispose();
  }

  Future<void> _nuevoCliente() async {
    final c = await mostrarFormularioCliente(context, widget.deps.repo);
    if (c != null) mostrarAviso(_messenger.currentState, 'Cliente ${c.nombre} registrado');
  }

  Future<void> _abrirCliente(Cliente c) async {
    final accion = await mostrarDetalleCliente(context, vm, c);
    if (!mounted || accion == null) return;
    switch (accion) {
      case AccionCliente.nuevoTurno:
        await abrirFormularioTurno(
          context,
          widget.deps,
          args: NuevoTurnoArgs(clienteId: c.id),
          messenger: _messenger.currentState,
        );
      case AccionCliente.editar:
        final editado = await mostrarFormularioCliente(context, widget.deps.repo, cliente: vm.cliente(c.id));
        if (editado != null) mostrarAviso(_messenger.currentState, 'Cliente actualizado');
      case AccionCliente.eliminar:
        await _eliminar(c);
    }
  }

  Future<void> _eliminar(Cliente c) async {
    // No se puede eliminar un cliente con turnos programados.
    final programado = vm.primerProgramado(c.id);
    if (programado != null) {
      final n = widget.deps.repo.programadosDeCliente(c.id).length;
      final router = GoRouter.of(context);
      mostrarAviso(
        _messenger.currentState,
        'No se puede eliminar: ${c.nombre} tiene ${Formato.plural(n, 'turno programado', 'turnos programados')}.',
        accion: 'Ver',
        alPulsar: () => router.push(Rutas.detalleTurno(programado.id)),
      );
      return;
    }
    final ok = await confirmar(
      context,
      titulo: '¿Eliminar a ${c.nombre}?',
      mensaje: 'Se eliminará el cliente junto con su historial de turnos completados y cancelados.',
      confirmarTexto: 'Eliminar',
      cancelarTexto: 'Cancelar',
    );
    if (!ok) return;
    final r = vm.eliminar(c.id);
    mostrarAviso(_messenger.currentState, r.esOk ? 'Cliente ${c.nombre} eliminado' : r.error!);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messenger,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clientes'),
          actions: [
            IconButton(
              tooltip: 'Registrar cliente',
              onPressed: _nuevoCliente,
              icon: const Icon(TurcoIcons.userPlus),
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab-clientes',
          onPressed: _nuevoCliente,
          icon: const Icon(TurcoIcons.userPlus, size: 20),
          label: const Text('Nuevo cliente'),
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final lista = vm.clientes;
            final m = context.tokens.margenPantalla;
            // La cabecera (búsqueda, filtro y totales) es el primer elemento
            // de la lista para que todo se desplace sin overflow, también con
            // el teclado abierto o en horizontal.
            return ListView.separated(
              key: const PageStorageKey<String>('clientes-lista'),
              padding: EdgeInsets.fromLTRB(m, 4, m, 96),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: 1 + (lista.isEmpty ? 1 : lista.length),
              separatorBuilder: (context, i) => i == 0 ? const SizedBox.shrink() : const Divider(),
              itemBuilder: (context, i) {
                if (i == 0) return _cabecera(context);
                if (lista.isEmpty) return _vacio();
                return _FilaCliente(
                  cliente: lista[i - 1],
                  turnos: vm.cantidadTurnos(lista[i - 1].id),
                  alTocar: () => _abrirCliente(lista[i - 1]),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _cabecera(BuildContext context) {
    final cs = context.cs;
    final gap = context.tokens.espacio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _busqueda,
          focusNode: _fBusqueda,
          onChanged: vm.buscar,
          textInputAction: TextInputAction.search,
          style: context.tt.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o teléfono',
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(TurcoIcons.search, size: 20, color: cs.onSurfaceVariant),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: vm.busqueda.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar',
                    icon: const Icon(TurcoIcons.x, size: 18),
                    onPressed: () {
                      _busqueda.clear();
                      vm.buscar('');
                    },
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
          ),
        ),
        SizedBox(height: gap),
        SelectorSegmentado<FiltroGenero>(
          valores: FiltroGenero.values,
          seleccionado: vm.filtro,
          etiqueta: (f) => f.etiqueta,
          alCambiar: vm.filtrar,
        ),
        SizedBox(height: gap),
        Text(
          '${Formato.plural(vm.total, 'cliente', 'clientes')} · '
          '${Formato.plural(vm.mujeres, 'mujer', 'mujeres')} · '
          '${Formato.plural(vm.hombres, 'hombre', 'hombres')}',
          style: context.tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _vacio() {
    if (vm.total == 0) {
      return const EstadoVacio(
        imagen: 'assets/images/ilustraciones/sin_clientes.png',
        titulo: 'Aún no hay clientes',
        mensaje: 'Registra el primero con el botón Nuevo cliente.',
      );
    }
    return const EstadoVacio(
      imagen: 'assets/images/ilustraciones/sin_resultados.png',
      titulo: 'Sin resultados',
      mensaje: 'Ningún cliente coincide con la búsqueda o el filtro.',
    );
  }
}

class _FilaCliente extends StatelessWidget {
  const _FilaCliente({required this.cliente, required this.turnos, required this.alTocar});

  final Cliente cliente;
  final int turnos;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    return InkWell(
      onTap: alTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AvatarCliente(nombre: cliente.nombre, genero: cliente.genero),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cliente.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: tt.titleSmall),
                  const SizedBox(height: 1),
                  Text(
                    '${Formato.telefono(cliente.telefono)} · ${cliente.genero.etiqueta}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Formato.plural(turnos, 'turno', 'turnos'),
              style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
