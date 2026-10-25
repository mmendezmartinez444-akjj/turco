import 'package:flutter/foundation.dart';

import '../data/models/enums.dart';
import '../data/models/estilista.dart';
import '../data/models/servicio.dart';
import '../data/repositories/salon_repository.dart';

/// ViewModel de la pantalla Estilistas.
class EstilistasViewModel extends ChangeNotifier {
  EstilistasViewModel(this.repo) {
    repo.addListener(notifyListeners);
  }

  final SalonRepository repo;

  List<Estilista> get estilistas => repo.estilistas;

  int turnosHoy(int estilistaId) => repo.programadosHoy(estilistaId);

  int get totalProgramadosHoy => estilistas.fold(0, (s, e) => s + turnosHoy(e.id));

  /// Servicios que realiza el estilista, agrupados por categoría.
  Map<Categoria, List<Servicio>> serviciosPorCategoria(Estilista e) {
    final mapa = <Categoria, List<Servicio>>{};
    for (final s in repo.serviciosDe(e.servicioIds)) {
      mapa.putIfAbsent(s.categoria, () => []).add(s);
    }
    return mapa;
  }

  @override
  void dispose() {
    repo.removeListener(notifyListeners);
    super.dispose();
  }
}
