import 'package:flutter/foundation.dart';

import '../../core/utils/formato.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/horario.dart';
import '../models/servicio.dart';
import '../models/turno.dart';
import '../seed/datos_prueba.dart';

/// Resultado de una operación que puede fallar con un mensaje para el usuario.
class Resultado<T> {
  const Resultado.ok(this.valor) : error = null;
  const Resultado.error(this.error) : valor = null;

  final T? valor;
  final String? error;

  bool get esOk => error == null;
}

/// Modelo de la app (capa de datos + reglas de negocio).
///
/// Todos los datos viven en memoria y se cargan de [DatosPrueba] al iniciar.
/// Es un [ChangeNotifier]: cualquier cambio en turnos o clientes se refleja de
/// inmediato en todos los ViewModels que lo escuchan.
class SalonRepository extends ChangeNotifier {
  SalonRepository({
    required List<Servicio> servicios,
    required List<Estilista> estilistas,
    required List<Cliente> clientes,
    required List<Turno> turnos,
    DateTime Function()? reloj,
  })  : servicios = List.unmodifiable(servicios),
        estilistas = List.unmodifiable(estilistas),
        _clientes = List.of(clientes),
        _turnos = List.of(turnos),
        _reloj = reloj ?? DateTime.now {
    _siguienteCliente = _clientes.fold<int>(0, (m, c) => c.id > m ? c.id : m) + 1;
    _siguienteTurno = _turnos.fold<int>(0, (m, t) => t.id > m ? t.id : m) + 1;
  }

  factory SalonRepository.conDatosDePrueba({DateTime Function()? reloj}) {
    final ahora = (reloj ?? DateTime.now)();
    final datos = DatosPrueba.generar(ahora);
    return SalonRepository(
      servicios: datos.servicios,
      estilistas: datos.estilistas,
      clientes: datos.clientes,
      turnos: datos.turnos,
      reloj: reloj,
    );
  }

  /// Catálogo de solo lectura.
  final List<Servicio> servicios;

  /// Estilistas de solo lectura.
  final List<Estilista> estilistas;

  final List<Cliente> _clientes;
  final List<Turno> _turnos;
  final DateTime Function() _reloj;
  late int _siguienteCliente;
  late int _siguienteTurno;

  DateTime get ahora => _reloj();

  List<Cliente> get clientes => List.unmodifiable(_clientes);
  List<Turno> get turnos => List.unmodifiable(_turnos);

  // ---------------------------------------------------------------------------
  // Búsquedas
  // ---------------------------------------------------------------------------

  Servicio? servicioPorId(int id) {
    for (final s in servicios) {
      if (s.id == id) return s;
    }
    return null;
  }

  Estilista? estilistaPorId(int? id) {
    if (id == null) return null;
    for (final e in estilistas) {
      if (e.id == id) return e;
    }
    return null;
  }

  Cliente? clientePorId(int? id) {
    if (id == null) return null;
    for (final c in _clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Turno? turnoPorId(int? id) {
    if (id == null) return null;
    for (final t in _turnos) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Servicio> serviciosDe(Iterable<int> ids) =>
      ids.map(servicioPorId).whereType<Servicio>().toList();

  // ---------------------------------------------------------------------------
  // Cálculos (no se guardan)
  // ---------------------------------------------------------------------------

  /// La duración de un turno es la suma de las duraciones de sus servicios.
  int duracionDe(Iterable<int> servicioIds) =>
      serviciosDe(servicioIds).fold(0, (s, x) => s + x.duracionMin);

  int precioDe(Iterable<int> servicioIds) =>
      serviciosDe(servicioIds).fold(0, (s, x) => s + x.precio);

  DateTime finDe(Turno t) => t.inicio.add(Duration(minutes: duracionDe(t.servicioIds)));

  int totalDe(Turno t) => precioDe(t.servicioIds);

  String nombresServicios(Turno t) => serviciosDe(t.servicioIds).map((s) => s.nombre).join(' + ');

  // ---------------------------------------------------------------------------
  // Consultas
  // ---------------------------------------------------------------------------

  /// Turnos de un día ordenados por hora.
  List<Turno> turnosDelDia(DateTime dia) {
    final lista = _turnos.where((t) => Fechas.mismoDia(t.inicio, dia)).toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  /// Historial de turnos de un cliente, del más reciente al más antiguo.
  List<Turno> turnosDeCliente(int clienteId) {
    final lista = _turnos.where((t) => t.clienteId == clienteId).toList()
      ..sort((a, b) => b.inicio.compareTo(a.inicio));
    return lista;
  }

  int cantidadTurnosCliente(int clienteId) => _turnos.where((t) => t.clienteId == clienteId).length;

  List<Turno> programadosDeCliente(int clienteId) =>
      _turnos.where((t) => t.clienteId == clienteId && t.esProgramado).toList()
        ..sort((a, b) => a.inicio.compareTo(b.inicio));

  /// Turnos programados que un estilista tiene hoy.
  int programadosHoy(int estilistaId) {
    final hoy = ahora;
    return _turnos
        .where((t) => t.estilistaId == estilistaId && t.esProgramado && Fechas.mismoDia(t.inicio, hoy))
        .length;
  }

  /// Estilistas que realizan TODOS los servicios indicados.
  List<Estilista> estilistasPara(Iterable<int> servicioIds) {
    if (servicioIds.isEmpty) return const [];
    return estilistas.where((e) => e.realizaTodos(servicioIds)).toList();
  }

  // ---------------------------------------------------------------------------
  // Disponibilidad
  // ---------------------------------------------------------------------------

  /// ¿Hay un turno programado que se solape? Los cancelados no ocupan horario.
  Turno? _solape({
    required DateTime inicio,
    required DateTime fin,
    int? estilistaId,
    int? clienteId,
    int? excluirTurnoId,
  }) {
    for (final t in _turnos) {
      if (!t.esProgramado || t.id == excluirTurnoId) continue;
      final coincide = (estilistaId != null && t.estilistaId == estilistaId) ||
          (clienteId != null && t.clienteId == clienteId);
      if (!coincide) continue;
      if (Horario.solapan(inicio, fin, t.inicio, finDe(t))) return t;
    }
    return null;
  }

  /// Franjas de 30 minutos de un día con su disponibilidad.
  /// Se deshabilitan: las ocupadas por el estilista o por el cliente, las ya
  /// pasadas si la fecha es hoy y aquellas en las que el turno no terminaría
  /// antes de las 19:00.
  List<Franja> franjas({
    required DateTime dia,
    required int duracionMin,
    int? estilistaId,
    int? clienteId,
    int? excluirTurnoId,
  }) {
    final ahora = this.ahora;
    final dur = duracionMin <= 0 ? Horario.franja : duracionMin;
    final cierre = Horario.cierreDe(dia);
    return Horario.franjasDe(dia).map((ini) {
      final fin = ini.add(Duration(minutes: dur));
      MotivoFranja? motivo;
      if (!Horario.abierto(dia)) {
        motivo = MotivoFranja.cerrado;
      } else if (!ini.isAfter(ahora)) {
        motivo = MotivoFranja.pasada;
      } else if (fin.isAfter(cierre)) {
        motivo = MotivoFranja.fueraDeHorario;
      } else if (estilistaId != null &&
          _solape(inicio: ini, fin: fin, estilistaId: estilistaId, excluirTurnoId: excluirTurnoId) != null) {
        motivo = MotivoFranja.ocupadaEstilista;
      } else if (clienteId != null &&
          _solape(inicio: ini, fin: fin, clienteId: clienteId, excluirTurnoId: excluirTurnoId) != null) {
        motivo = MotivoFranja.ocupadaCliente;
      }
      return Franja(ini, motivo);
    }).toList();
  }

  /// Valida todas las reglas de negocio de un turno. Devuelve el mensaje de
  /// error o null si es válido.
  String? validarTurno({
    required int? clienteId,
    required int? estilistaId,
    required List<int> servicioIds,
    required DateTime? inicio,
    int? excluirTurnoId,
  }) {
    final cliente = clientePorId(clienteId);
    if (cliente == null) return 'Selecciona un cliente';
    if (servicioIds.isEmpty) return 'Elige al menos un servicio';
    final estilista = estilistaPorId(estilistaId);
    if (estilista == null) return 'Selecciona un estilista';
    if (!estilista.realizaTodos(servicioIds)) {
      return '${estilista.nombreCorto} no realiza todos los servicios elegidos';
    }
    if (inicio == null) return 'Elige una hora para el turno';
    if (!Horario.abierto(inicio)) return 'El salón está cerrado los domingos';
    if (!inicio.isAfter(ahora)) return 'No se pueden programar turnos en el pasado';
    final m = Horario.minutosDelDia(inicio);
    if (m < Horario.apertura || m % Horario.franja != 0) {
      return 'Los turnos empiezan en franjas de 30 minutos desde las 09:00';
    }
    final fin = inicio.add(Duration(minutes: duracionDe(servicioIds)));
    if (fin.isAfter(Horario.cierreDe(inicio))) return 'El turno debe terminar a las 19:00 como máximo';
    final conEstilista =
        _solape(inicio: inicio, fin: fin, estilistaId: estilista.id, excluirTurnoId: excluirTurnoId);
    if (conEstilista != null) {
      return '${estilista.nombreCorto} ya tiene un turno de ${Formato.hora(conEstilista.inicio)} a ${Formato.hora(finDe(conEstilista))}';
    }
    final conCliente = _solape(inicio: inicio, fin: fin, clienteId: cliente.id, excluirTurnoId: excluirTurnoId);
    if (conCliente != null) {
      return '${cliente.nombre} ya tiene un turno de ${Formato.hora(conCliente.inicio)} a ${Formato.hora(finDe(conCliente))}';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Turnos: alta, edición, completar y cancelar (no se eliminan)
  // ---------------------------------------------------------------------------

  Resultado<Turno> crearTurno({
    required int? clienteId,
    required int? estilistaId,
    required List<int> servicioIds,
    required DateTime? inicio,
    String? notas,
  }) {
    final error = validarTurno(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicioIds: servicioIds,
      inicio: inicio,
    );
    if (error != null) return Resultado.error(error);
    final ahora = this.ahora;
    final turno = Turno(
      id: _siguienteTurno++,
      clienteId: clienteId!,
      estilistaId: estilistaId!,
      servicioIds: List.unmodifiable(servicioIds),
      inicio: inicio!,
      notas: _limpiar(notas),
      estado: EstadoTurno.programado,
      creado: ahora,
      modificado: ahora,
    );
    _turnos.add(turno);
    notifyListeners();
    return Resultado.ok(turno);
  }

  Resultado<Turno> actualizarTurno({
    required int turnoId,
    required int? clienteId,
    required int? estilistaId,
    required List<int> servicioIds,
    required DateTime? inicio,
    String? notas,
  }) {
    final i = _turnos.indexWhere((t) => t.id == turnoId);
    if (i < 0) return const Resultado.error('El turno no existe');
    final actual = _turnos[i];
    if (!actual.esProgramado) return const Resultado.error('Solo se pueden editar turnos programados');
    final error = validarTurno(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicioIds: servicioIds,
      inicio: inicio,
      excluirTurnoId: turnoId,
    );
    if (error != null) return Resultado.error(error);
    final nuevo = actual.copyWith(
      clienteId: clienteId,
      estilistaId: estilistaId,
      servicioIds: List.unmodifiable(servicioIds),
      inicio: inicio,
      notas: _limpiar(notas),
      borrarNotas: _limpiar(notas) == null,
      modificado: ahora,
    );
    _turnos[i] = nuevo;
    notifyListeners();
    return Resultado.ok(nuevo);
  }

  Resultado<Turno> completarTurno(int turnoId) => _cambiarEstado(turnoId, EstadoTurno.completado);

  /// Al cancelar, su horario vuelve a quedar libre (los cancelados no ocupan).
  Resultado<Turno> cancelarTurno(int turnoId) => _cambiarEstado(turnoId, EstadoTurno.cancelado);

  Resultado<Turno> _cambiarEstado(int turnoId, EstadoTurno estado) {
    final i = _turnos.indexWhere((t) => t.id == turnoId);
    if (i < 0) return const Resultado.error('El turno no existe');
    if (!_turnos[i].esProgramado) {
      return const Resultado.error('Solo se pueden completar o cancelar turnos programados');
    }
    _turnos[i] = _turnos[i].copyWith(estado: estado, modificado: ahora);
    notifyListeners();
    return Resultado.ok(_turnos[i]);
  }

  // ---------------------------------------------------------------------------
  // Clientes
  // ---------------------------------------------------------------------------

  /// El teléfono es único.
  bool telefonoEnUso(String telefono, {int? excluirClienteId}) =>
      _clientes.any((c) => c.telefono == telefono.trim() && c.id != excluirClienteId);

  String? validarCliente({
    required String nombre,
    required String telefono,
    required Genero? genero,
    String? correo,
    int? excluirClienteId,
  }) {
    final e = ReglasCliente.nombre(nombre) ??
        ReglasCliente.telefonoFormato(telefono) ??
        ReglasCliente.genero(genero) ??
        ReglasCliente.correo(correo);
    if (e != null) return e;
    if (telefonoEnUso(telefono, excluirClienteId: excluirClienteId)) {
      return 'Ese teléfono ya pertenece a otro cliente';
    }
    return null;
  }

  Resultado<Cliente> crearCliente({
    required String nombre,
    required String telefono,
    required Genero? genero,
    String? correo,
  }) {
    final error = validarCliente(nombre: nombre, telefono: telefono, genero: genero, correo: correo);
    if (error != null) return Resultado.error(error);
    final c = Cliente(
      id: _siguienteCliente++,
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      genero: genero!,
      correo: _limpiar(correo),
      fechaRegistro: ahora,
    );
    _clientes.add(c);
    notifyListeners();
    return Resultado.ok(c);
  }

  Resultado<Cliente> actualizarCliente({
    required int clienteId,
    required String nombre,
    required String telefono,
    required Genero? genero,
    String? correo,
  }) {
    final i = _clientes.indexWhere((c) => c.id == clienteId);
    if (i < 0) return const Resultado.error('El cliente no existe');
    final error = validarCliente(
      nombre: nombre,
      telefono: telefono,
      genero: genero,
      correo: correo,
      excluirClienteId: clienteId,
    );
    if (error != null) return Resultado.error(error);
    final c = _clientes[i].copyWith(
      nombre: nombre.trim(),
      telefono: telefono.trim(),
      genero: genero,
      correo: _limpiar(correo),
      borrarCorreo: _limpiar(correo) == null,
    );
    _clientes[i] = c;
    notifyListeners();
    return Resultado.ok(c);
  }

  /// No se puede eliminar un cliente con turnos programados. Si no los tiene,
  /// se elimina junto con su historial de turnos completados y cancelados.
  Resultado<Cliente> eliminarCliente(int clienteId) {
    final c = clientePorId(clienteId);
    if (c == null) return const Resultado.error('El cliente no existe');
    final programados = programadosDeCliente(clienteId).length;
    if (programados > 0) {
      return Resultado.error(
        'No se puede eliminar: ${c.nombre} tiene ${Formato.plural(programados, 'turno programado', 'turnos programados')}.',
      );
    }
    _turnos.removeWhere((t) => t.clienteId == clienteId);
    _clientes.removeWhere((x) => x.id == clienteId);
    notifyListeners();
    return Resultado.ok(c);
  }

  static String? _limpiar(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
