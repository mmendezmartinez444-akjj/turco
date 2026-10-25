import 'enums.dart';

/// Turno (cita) de un cliente con un estilista.
///
/// La duración, la hora de fin y el precio total NO se guardan: se calculan a
/// partir de los servicios (ver SalonRepository).
class Turno {
  const Turno({
    required this.id,
    required this.clienteId,
    required this.estilistaId,
    required this.servicioIds,
    required this.inicio,
    this.notas,
    required this.estado,
    required this.creado,
    required this.modificado,
  });

  final int id;
  final int clienteId;
  final int estilistaId;
  final List<int> servicioIds;

  /// Fecha y hora de inicio.
  final DateTime inicio;
  final String? notas;
  final EstadoTurno estado;
  final DateTime creado;
  final DateTime modificado;

  bool get esProgramado => estado == EstadoTurno.programado;

  bool get tieneNotas => notas != null && notas!.trim().isNotEmpty;

  Turno copyWith({
    int? clienteId,
    int? estilistaId,
    List<int>? servicioIds,
    DateTime? inicio,
    String? notas,
    bool borrarNotas = false,
    EstadoTurno? estado,
    DateTime? modificado,
  }) {
    return Turno(
      id: id,
      clienteId: clienteId ?? this.clienteId,
      estilistaId: estilistaId ?? this.estilistaId,
      servicioIds: servicioIds ?? this.servicioIds,
      inicio: inicio ?? this.inicio,
      notas: borrarNotas ? null : (notas ?? this.notas),
      estado: estado ?? this.estado,
      creado: creado,
      modificado: modificado ?? this.modificado,
    );
  }
}

/// Valor que el formulario de turno devuelve con `context.pop(valor)`.
class TurnoGuardado {
  const TurnoGuardado({required this.turnoId, required this.inicio, required this.esNuevo});

  final int turnoId;
  final DateTime inicio;
  final bool esNuevo;
}

/// Datos iniciales del formulario de turno, enviados con `extra`.
class NuevoTurnoArgs {
  const NuevoTurnoArgs({this.clienteId, this.servicioId, this.fecha});

  final int? clienteId;
  final int? servicioId;
  final DateTime? fecha;
}
