import 'package:flutter/foundation.dart';

import '../core/utils/formato.dart';
import '../data/models/cliente.dart';
import '../data/models/enums.dart';
import '../data/models/turno.dart';
import '../data/repositories/salon_repository.dart';

/// ViewModel de la pantalla Clientes.
class ClientesViewModel extends ChangeNotifier {
  ClientesViewModel(this.repo) {
    repo.addListener(notifyListeners);
  }

  final SalonRepository repo;

  String _busqueda = '';
  FiltroGenero _filtro = FiltroGenero.todos;

  String get busqueda => _busqueda;
  FiltroGenero get filtro => _filtro;

  /// Búsqueda por nombre o teléfono, sin distinguir mayúsculas ni acentos,
  /// combinada con el filtro de género.
  List<Cliente> get clientes {
    final q = Texto.normalizar(_busqueda);
    final qTel = q.replaceAll(' ', '');
    final lista = repo.clientes.where((c) {
      if (!_filtro.admite(c.genero)) return false;
      if (q.isEmpty) return true;
      return Texto.normalizar(c.nombre).contains(q) || (qTel.isNotEmpty && c.telefono.contains(qTel));
    }).toList()
      ..sort((a, b) => Texto.normalizar(a.nombre).compareTo(Texto.normalizar(b.nombre)));
    return lista;
  }

  int get total => repo.clientes.length;
  int get mujeres => repo.clientes.where((c) => c.genero == Genero.mujer).length;
  int get hombres => repo.clientes.where((c) => c.genero == Genero.hombre).length;

  bool get hayFiltros => _busqueda.trim().isNotEmpty || _filtro != FiltroGenero.todos;

  int cantidadTurnos(int clienteId) => repo.cantidadTurnosCliente(clienteId);
  List<Turno> historial(int clienteId) => repo.turnosDeCliente(clienteId);
  String servicios(Turno t) => repo.nombresServicios(t);
  Cliente? cliente(int id) => repo.clientePorId(id);

  void buscar(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  void filtrar(FiltroGenero f) {
    _filtro = f;
    notifyListeners();
  }

  /// Devuelve error si el cliente tiene turnos programados.
  Resultado<Cliente> eliminar(int clienteId) => repo.eliminarCliente(clienteId);

  /// Primer turno programado del cliente (para la acción "Ver").
  Turno? primerProgramado(int clienteId) {
    final l = repo.programadosDeCliente(clienteId);
    return l.isEmpty ? null : l.first;
  }

  @override
  void dispose() {
    repo.removeListener(notifyListeners);
    super.dispose();
  }
}
