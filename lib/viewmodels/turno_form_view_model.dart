import 'package:flutter/foundation.dart';

import '../core/utils/formato.dart';
import '../data/models/cliente.dart';
import '../data/models/enums.dart';
import '../data/models/estilista.dart';
import '../data/models/horario.dart';
import '../data/models/servicio.dart';
import '../data/models/turno.dart';
import '../data/repositories/salon_repository.dart';

/// ViewModel del formulario de turno (crear y editar).
///
/// Aquí viven las reglas del formulario: filtrado de servicios por público,
/// estilistas válidos, recálculo de franjas y resumen. La vista solo pinta.
class TurnoFormViewModel extends ChangeNotifier {
  TurnoFormViewModel(this.repo, {this.turnoId, NuevoTurnoArgs? args}) {
    final t = repo.turnoPorId(turnoId);
    if (t != null) {
      _clienteId = t.clienteId;
      _servicioIds.addAll(t.servicioIds);
      _estilistaId = t.estilistaId;
      _fecha = Fechas.soloDia(t.inicio);
      _hora = t.inicio;
      _notas = t.notas ?? '';
    } else if (args != null) {
      if (repo.clientePorId(args.clienteId) != null) _clienteId = args.clienteId;
      if (args.servicioId != null && repo.servicioPorId(args.servicioId!) != null) {
        _servicioIds.add(args.servicioId!);
      }
      if (args.fecha != null && fechaPermitida(args.fecha!)) _fecha = Fechas.soloDia(args.fecha!);
    }
    final c = cliente;
    if (c != null) _publico = FiltroPublico.desdeGenero(c.genero);
    _inicial = _instantanea();
    repo.addListener(_alCambiarRepo);
  }

  final SalonRepository repo;

  /// Turno que se edita; null si es un alta.
  final int? turnoId;

  int? _clienteId;
  FiltroPublico _publico = FiltroPublico.todos;
  final Set<int> _servicioIds = <int>{};
  int? _estilistaId;
  DateTime? _fecha;
  DateTime? _hora;
  String _notas = '';
  String? _aviso;
  late String _inicial;

  static const int maxNotas = 500;

  // ---------------------------------------------------------------------------
  // Estado
  // ---------------------------------------------------------------------------

  bool get esEdicion => turnoId != null;

  /// En edición, el turno debe existir y estar programado.
  bool get puedeEditarse {
    if (!esEdicion) return true;
    return repo.turnoPorId(turnoId)?.esProgramado ?? false;
  }

  int? get clienteId => _clienteId;
  FiltroPublico get publico => _publico;
  Set<int> get servicioIds => Set.unmodifiable(_servicioIds);
  int? get estilistaId => _estilistaId;
  DateTime? get fecha => _fecha;
  DateTime? get hora => _hora;
  String get notas => _notas;

  Cliente? get cliente => repo.clientePorId(_clienteId);
  Estilista? get estilista => repo.estilistaPorId(_estilistaId);

  List<Cliente> get clientes => repo.clientes.toList()
    ..sort((a, b) => Texto.normalizar(a.nombre).compareTo(Texto.normalizar(b.nombre)));

  /// Servicios agrupados por categoría según el filtro de público. Los ya
  /// elegidos se muestran siempre para poder quitarlos.
  Map<Categoria, List<Servicio>> get serviciosAgrupados {
    final mapa = <Categoria, List<Servicio>>{};
    for (final c in Categoria.values) {
      final lista = repo.servicios
          .where((s) => s.categoria == c && (_publico.admite(s.publico) || _servicioIds.contains(s.id)))
          .toList();
      if (lista.isNotEmpty) mapa[c] = lista;
    }
    return mapa;
  }

  /// Solo los estilistas que realizan TODOS los servicios elegidos.
  List<Estilista> get estilistasValidos => repo.estilistasPara(_servicioIds);

  int get duracion => repo.duracionDe(_servicioIds);
  int get precio => repo.precioDe(_servicioIds);
  DateTime? get fin => _hora?.add(Duration(minutes: duracion));

  /// Franjas recalculadas con los servicios, el estilista, el cliente y la fecha.
  List<Franja> get franjas {
    if (_fecha == null || !fechaPermitida(_fecha!)) return const [];
    return repo.franjas(
      dia: _fecha!,
      duracionMin: duracion,
      estilistaId: _estilistaId,
      clienteId: _clienteId,
      excluirTurnoId: turnoId,
    );
  }

  bool get hayFranjasLibres => franjas.any((f) => f.disponible);

  bool get hayCambios => _instantanea() != _inicial;

  /// Aviso puntual para la vista (por ejemplo, estilista quitado). Se consume una vez.
  String? consumirAviso() {
    final a = _aviso;
    _aviso = null;
    return a;
  }

  /// Fechas válidas: hoy o futuras, de lunes a sábado.
  bool fechaPermitida(DateTime d) {
    final hoy = Fechas.soloDia(repo.ahora);
    return Horario.abierto(d) && !Fechas.soloDia(d).isBefore(hoy);
  }

  DateTime get primeraFechaPermitida => Horario.proximoLaborable(repo.ahora);

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  void elegirCliente(int? id) {
    _clienteId = id;
    final c = cliente;
    // El filtro por público se ajusta por defecto al género del cliente.
    if (c != null) _publico = FiltroPublico.desdeGenero(c.genero);
    _revisarHora();
    notifyListeners();
  }

  void elegirPublico(FiltroPublico p) {
    _publico = p;
    notifyListeners();
  }

  void alternarServicio(int id) {
    if (!_servicioIds.remove(id)) _servicioIds.add(id);
    final e = estilista;
    if (e != null && !e.realizaTodos(_servicioIds)) {
      _estilistaId = null;
      _aviso = 'Se quitó a ${e.nombreCorto}: no realiza todos los servicios elegidos.';
    }
    _revisarHora();
    notifyListeners();
  }

  void elegirEstilista(int? id) {
    _estilistaId = id;
    _revisarHora();
    notifyListeners();
  }

  void elegirFecha(DateTime d) {
    _fecha = Fechas.soloDia(d);
    if (_hora != null) {
      _hora = DateTime(d.year, d.month, d.day, _hora!.hour, _hora!.minute);
    }
    _revisarHora();
    notifyListeners();
  }

  void elegirHora(DateTime h) {
    _hora = h;
    notifyListeners();
  }

  void cambiarNotas(String texto) {
    final antes = hayCambios;
    _notas = texto;
    if (antes != hayCambios) notifyListeners();
  }

  /// Si la hora elegida deja de estar disponible, se limpia y se avisa.
  void _revisarHora() {
    final h = _hora;
    if (h == null) return;
    final franja = franjas.where((f) => f.inicio == h).toList();
    if (franja.isEmpty || !franja.first.disponible) {
      _hora = null;
      _aviso ??= 'La hora ${Formato.hora(h)} ya no está disponible. Elige otra.';
    }
  }

  void _alCambiarRepo() => notifyListeners();

  // ---------------------------------------------------------------------------
  // Validación de campos (mensajes bajo cada campo)
  // ---------------------------------------------------------------------------

  String? validarCliente() => cliente == null ? 'Selecciona un cliente' : null;

  String? validarServicios() => _servicioIds.isEmpty ? 'Elige al menos un servicio' : null;

  String? validarEstilista() {
    final e = estilista;
    if (e == null) return 'Selecciona un estilista';
    if (!e.realizaTodos(_servicioIds)) return 'Este estilista no realiza todos los servicios';
    return null;
  }

  String? validarFecha() =>
      (_fecha == null || !fechaPermitida(_fecha!)) ? 'Elige una fecha válida (no domingos)' : null;

  String? validarHora() {
    if (_hora == null) return 'Elige una hora para el turno';
    final f = franjas.where((x) => x.inicio == _hora).toList();
    if (f.isEmpty || !f.first.disponible) return 'Esa hora ya no está disponible';
    return null;
  }

  String? validarNotas(String? v) =>
      (v ?? '').length > maxNotas ? 'Máximo $maxNotas caracteres' : null;

  /// Guarda el turno aplicando todas las reglas de negocio del modelo.
  Resultado<TurnoGuardado> guardar() {
    final ids = _servicioIds.toList();
    final r = esEdicion
        ? repo.actualizarTurno(
            turnoId: turnoId!,
            clienteId: _clienteId,
            estilistaId: _estilistaId,
            servicioIds: ids,
            inicio: _hora,
            notas: _notas,
          )
        : repo.crearTurno(
            clienteId: _clienteId,
            estilistaId: _estilistaId,
            servicioIds: ids,
            inicio: _hora,
            notas: _notas,
          );
    if (!r.esOk) return Resultado.error(r.error);
    _inicial = _instantanea();
    final t = r.valor!;
    return Resultado.ok(TurnoGuardado(turnoId: t.id, inicio: t.inicio, esNuevo: !esEdicion));
  }

  String _instantanea() {
    final ids = _servicioIds.toList()..sort();
    return [
      _clienteId,
      ids.join(','),
      _estilistaId,
      _fecha?.toIso8601String(),
      _hora?.toIso8601String(),
      _notas.trim(),
    ].join('|');
  }

  @override
  void dispose() {
    repo.removeListener(_alCambiarRepo);
    super.dispose();
  }
}
