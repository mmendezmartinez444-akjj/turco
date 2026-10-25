import 'package:flutter/foundation.dart';

import '../data/models/enums.dart';
import '../data/models/servicio.dart';
import '../data/repositories/salon_repository.dart';

/// ViewModel del catálogo de servicios.
class ServiciosViewModel extends ChangeNotifier {
  ServiciosViewModel(this.repo);

  final SalonRepository repo;

  /// null = Todas.
  Categoria? _categoria;
  FiltroPublico _publico = FiltroPublico.todos;

  Categoria? get categoria => _categoria;
  FiltroPublico get publico => _publico;

  List<Servicio> get servicios => repo.servicios
      .where((s) => _categoria == null || s.categoria == _categoria)
      .where((s) => _publico.admite(s.publico))
      .toList();

  void filtrarCategoria(Categoria? c) {
    _categoria = c;
    notifyListeners();
  }

  void filtrarPublico(FiltroPublico p) {
    _publico = p;
    notifyListeners();
  }
}
