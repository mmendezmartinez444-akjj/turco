import 'package:flutter/foundation.dart';

import '../data/models/cliente.dart';
import '../data/models/estilista.dart';
import '../data/models/servicio.dart';
import '../data/models/turno.dart';
import '../data/repositories/salon_repository.dart';

/// ViewModel de la pantalla Detalle de turno.
class TurnoDetalleViewModel extends ChangeNotifier {
  TurnoDetalleViewModel(this.repo, this.turnoId) {
    repo.addListener(notifyListeners);
  }

  final SalonRepository repo;

  /// Identificador recibido por la ruta. Puede ser null si no es un número.
  final int? turnoId;

  Turno? get turno => repo.turnoPorId(turnoId);
  bool get existe => turno != null;

  Cliente? get cliente => repo.clientePorId(turno?.clienteId);
  Estilista? get estilista => repo.estilistaPorId(turno?.estilistaId);
  List<Servicio> get servicios => turno == null ? const [] : repo.serviciosDe(turno!.servicioIds);
  DateTime? get fin => turno == null ? null : repo.finDe(turno!);
  int get duracion => turno == null ? 0 : repo.duracionDe(turno!.servicioIds);
  int get total => turno == null ? 0 : repo.totalDe(turno!);

  /// Solo los turnos programados se pueden editar, completar o cancelar.
  bool get editable => turno?.esProgramado ?? false;

  Resultado<Turno> completar() => repo.completarTurno(turnoId!);
  Resultado<Turno> cancelar() => repo.cancelarTurno(turnoId!);

  @override
  void dispose() {
    repo.removeListener(notifyListeners);
    super.dispose();
  }
}
