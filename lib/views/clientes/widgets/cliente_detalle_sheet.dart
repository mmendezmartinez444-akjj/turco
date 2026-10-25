import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/turco_icons.dart';
import '../../../core/utils/formato.dart';
import '../../../data/models/cliente.dart';
import '../../../viewmodels/clientes_view_model.dart';
import '../../../widgets/avatares.dart';
import '../../../widgets/estado_chip.dart';

/// Acción elegida en la hoja de detalle del cliente.
enum AccionCliente { nuevoTurno, editar, eliminar }

/// Hoja con los datos del cliente, su historial de turnos y las opciones
/// Nuevo turno, Editar y Eliminar.
Future<AccionCliente?> mostrarDetalleCliente(BuildContext context, ClientesViewModel vm, Cliente cliente) {
  return showModalBottomSheet<AccionCliente>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (ctx) => _DetalleCliente(vm: vm, clienteId: cliente.id),
  );
}

class _DetalleCliente extends StatelessWidget {
  const _DetalleCliente({required this.vm, required this.clienteId});

  final ClientesViewModel vm;
  final int clienteId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final c = vm.cliente(clienteId);
        if (c == null) return const SizedBox(height: 120);
        final cs = context.cs;
        final tt = context.tt;
        final historial = vm.historial(c.id);
        final alto = MediaQuery.sizeOf(context).height * 0.75;
        Widget dato(IconData icono, String texto) => Row(
              children: [
                Icon(icono, size: 13, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textos.secundario.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            );
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: alto),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AvatarCliente(nombre: c.nombre, genero: c.genero, tamano: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textos.tituloHoja,
                            ),
                            const SizedBox(height: 2),
                            dato(TurcoIcons.phone, Formato.telefono(c.telefono)),
                            if (c.correo != null) ...[
                              const SizedBox(height: 2),
                              dato(TurcoIcons.mail, c.correo!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Historial de turnos · ${historial.length}',
                    style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: historial.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Todavía no tiene turnos.',
                              style: context.textos.secundario.copyWith(color: cs.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: historial.length,
                            itemBuilder: (context, i) {
                              final t = historial[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${Formato.diaMes(t.inicio)} · ${vm.servicios(t)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textos.secundario,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    EstadoChip(t.estado),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).pop(AccionCliente.nuevoTurno),
                          icon: const Icon(TurcoIcons.plus, size: 18),
                          label: const Text('Nuevo turno'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(AccionCliente.editar),
                        icon: const Icon(TurcoIcons.pencil, size: 16),
                        label: const Text('Editar'),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        tooltip: 'Eliminar',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(46, 46),
                          side: BorderSide(color: cs.outlineVariant),
                        ),
                        onPressed: () => Navigator.of(context).pop(AccionCliente.eliminar),
                        icon: Icon(TurcoIcons.trash, size: 18, color: cs.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
