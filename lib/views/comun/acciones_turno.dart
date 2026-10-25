import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/utils/formato.dart';
import '../../data/models/turno.dart';
import '../../router/app_router.dart';
import '../../widgets/dialogos.dart';

/// Abre el formulario de turno (crear o editar). El formulario devuelve el
/// resultado con `context.pop(valor)`; al volver, la Agenda se ubica en la
/// fecha del turno guardado y se muestra un SnackBar de confirmación.
Future<TurnoGuardado?> abrirFormularioTurno(
  BuildContext context,
  AppDependencies deps, {
  NuevoTurnoArgs? args,
  int? editarId,
  ScaffoldMessengerState? messenger,
}) async {
  final router = GoRouter.of(context);
  final ruta = editarId == null ? Rutas.nuevoTurno : Rutas.editarTurno(editarId);
  final resultado = await router.push<TurnoGuardado>(ruta, extra: args);
  if (resultado == null) return null;
  deps.agenda.seleccionarFecha(resultado.inicio);
  mostrarAviso(
    messenger,
    'Turno guardado para el ${Formato.fechaMedia(resultado.inicio)}',
    accion: 'Ver',
    alPulsar: () => router.push(Rutas.detalleTurno(resultado.turnoId)),
  );
  return resultado;
}

/// Pide confirmación y marca el turno como completado.
Future<void> confirmarCompletar(
  BuildContext context,
  AppDependencies deps,
  Turno t, {
  ScaffoldMessengerState? messenger,
}) async {
  final repo = deps.repo;
  final cliente = repo.clientePorId(t.clienteId)?.nombre ?? 'el cliente';
  final ok = await confirmar(
    context,
    titulo: '¿Completar este turno?',
    mensaje:
        'El turno de $cliente (${Formato.hora(t.inicio)} a ${Formato.hora(repo.finDe(t))}) se marcará como completado.',
    confirmarTexto: 'Completar',
    destructivo: false,
  );
  if (!ok) return;
  final r = repo.completarTurno(t.id);
  mostrarAviso(messenger, r.esOk ? 'Turno marcado como completado' : r.error!);
}

/// Pide confirmación y cancela el turno. Su horario vuelve a quedar libre.
Future<void> confirmarCancelar(
  BuildContext context,
  AppDependencies deps,
  Turno t, {
  ScaffoldMessengerState? messenger,
}) async {
  final repo = deps.repo;
  final cliente = repo.clientePorId(t.clienteId)?.nombre ?? 'el cliente';
  final ok = await confirmar(
    context,
    titulo: '¿Cancelar este turno?',
    mensaje:
        'El horario de $cliente (${Formato.hora(t.inicio)} a ${Formato.hora(repo.finDe(t))}) quedará libre. Esta acción no se puede deshacer.',
    confirmarTexto: 'Cancelar turno',
  );
  if (!ok) return;
  final r = repo.cancelarTurno(t.id);
  mostrarAviso(messenger, r.esOk ? 'Turno cancelado. El horario quedó libre.' : r.error!);
}
