import 'package:flutter/foundation.dart';

import '../core/utils/formato.dart';
import '../data/models/enums.dart';
import '../data/models/estilista.dart';
import '../data/models/horario.dart';
import '../data/models/turno.dart';
import '../data/repositories/salon_repository.dart';

/// Resumen del día mostrado en la Agenda.
class ResumenDia {
  const ResumenDia({required this.programados, required this.completados, required this.ingreso});

  final int programados;
  final int completados;

  /// Suma de los totales de los turnos programados y completados.
  final int ingreso;
}

/// ViewModel de la pantalla Agenda. Conserva la fecha y los filtros aunque se
/// cambie de pestaña.
class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel(this.repo) {
    _fecha = Horario.proximoLaborable(repo.ahora);
    repo.addListener(notifyListeners);
  }

  final SalonRepository repo;

  late DateTime _fecha;
  int? _estilistaId;
  FiltroEstado _filtroEstado = FiltroEstado.todos;

  DateTime get fecha => _fecha;
  int? get estilistaId => _estilistaId;
  FiltroEstado get filtroEstado => _filtroEstado;

  List<Estilista> get estilistas => repo.estilistas;

  bool get esDomingo => Fechas.esDomingo(_fecha);

  /// Los siete días (lunes a domingo) de la semana de la fecha seleccionada.
  List<DateTime> get semana {
    final lunes = Fechas.lunesDe(_fecha);
    return List.generate(7, (i) => Fechas.sumarDias(lunes, i));
  }

  bool esHoy(DateTime d) => Fechas.mismoDia(d, repo.ahora);

  List<Turno> get _turnosDelDia => repo.turnosDelDia(_fecha);

  /// Turnos del día filtrados por estilista y estado, ordenados por hora.
  List<Turno> get turnos => _turnosDelDia
      .where((t) => _estilistaId == null || t.estilistaId == _estilistaId)
      .where((t) => _filtroEstado.admite(t.estado))
      .toList();

  bool get diaSinTurnos => _turnosDelDia.isEmpty;

  ResumenDia get resumen {
    var p = 0, c = 0, ingreso = 0;
    for (final t in _turnosDelDia) {
      if (t.estado == EstadoTurno.programado) p++;
      if (t.estado == EstadoTurno.completado) c++;
      if (t.estado != EstadoTurno.cancelado) ingreso += repo.totalDe(t);
    }
    return ResumenDia(programados: p, completados: c, ingreso: ingreso);
  }

  // --- Datos derivados para las tarjetas -------------------------------------
  String nombreCliente(Turno t) => repo.clientePorId(t.clienteId)?.nombre ?? 'Cliente eliminado';
  String nombreEstilista(Turno t) => repo.estilistaPorId(t.estilistaId)?.nombreCorto ?? '';
  String servicios(Turno t) => repo.nombresServicios(t);
  DateTime fin(Turno t) => repo.finDe(t);

  // --- Acciones --------------------------------------------------------------
  void seleccionarFecha(DateTime d) {
    _fecha = Fechas.soloDia(d);
    notifyListeners();
  }

  void semanaAnterior() => seleccionarFecha(Fechas.sumarDias(_fecha, -7));
  void semanaSiguiente() => seleccionarFecha(Fechas.sumarDias(_fecha, 7));

  void irAHoy() => seleccionarFecha(Horario.proximoLaborable(repo.ahora));

  void filtrarEstilista(int? id) {
    if (id != null && repo.estilistaPorId(id) == null) id = null;
    _estilistaId = id;
    notifyListeners();
  }

  void filtrarEstado(FiltroEstado f) {
    _filtroEstado = f;
    notifyListeners();
  }

  Resultado<Turno> completar(int turnoId) => repo.completarTurno(turnoId);
  Resultado<Turno> cancelar(int turnoId) => repo.cancelarTurno(turnoId);

  @override
  void dispose() {
    repo.removeListener(notifyListeners);
    super.dispose();
  }
}
