import 'package:flutter/foundation.dart';

import '../data/models/cliente.dart';
import '../data/models/enums.dart';
import '../data/repositories/salon_repository.dart';

/// ViewModel del formulario de alta / edición de cliente (hoja inferior).
class ClienteFormViewModel extends ChangeNotifier {
  ClienteFormViewModel(this.repo, {this.cliente}) : _genero = cliente?.genero;

  final SalonRepository repo;

  /// Cliente a editar; null si es un alta.
  final Cliente? cliente;

  Genero? _genero;
  bool _guardando = false;

  bool get esEdicion => cliente != null;
  Genero? get genero => _genero;
  bool get guardando => _guardando;

  void elegirGenero(Genero? g) {
    _genero = g;
    notifyListeners();
  }

  // Validadores que usan los TextFormField.
  String? validarNombre(String? v) => ReglasCliente.nombre(v);

  String? validarTelefono(String? v) {
    final e = ReglasCliente.telefonoFormato(v);
    if (e != null) return e;
    if (repo.telefonoEnUso(v!.trim(), excluirClienteId: cliente?.id)) {
      return 'Ese teléfono ya está registrado';
    }
    return null;
  }

  String? validarGenero(Genero? g) => ReglasCliente.genero(g ?? _genero);

  String? validarCorreo(String? v) => ReglasCliente.correo(v);

  Resultado<Cliente> guardar({required String nombre, required String telefono, String? correo}) {
    _guardando = true;
    final r = esEdicion
        ? repo.actualizarCliente(
            clienteId: cliente!.id,
            nombre: nombre,
            telefono: telefono,
            genero: _genero,
            correo: correo,
          )
        : repo.crearCliente(nombre: nombre, telefono: telefono, genero: _genero, correo: correo);
    _guardando = false;
    return r;
  }
}
