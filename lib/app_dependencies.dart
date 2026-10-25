import 'data/repositories/salon_repository.dart';
import 'viewmodels/agenda_view_model.dart';
import 'viewmodels/clientes_view_model.dart';
import 'viewmodels/estilistas_view_model.dart';
import 'viewmodels/servicios_view_model.dart';
import 'viewmodels/tema_view_model.dart';

/// Contenedor sencillo de dependencias (sin paquetes externos de estado).
///
/// Los ViewModels de las pestañas viven mientras la app está abierta, así
/// cada destino conserva su estado (búsqueda, filtros, fecha) al cambiar de
/// pestaña.
class AppDependencies {
  AppDependencies._(this.repo)
      : tema = TemaViewModel(),
        agenda = AgendaViewModel(repo),
        clientes = ClientesViewModel(repo),
        servicios = ServiciosViewModel(repo),
        estilistas = EstilistasViewModel(repo);

  factory AppDependencies.crear() => AppDependencies._(SalonRepository.conDatosDePrueba());

  final SalonRepository repo;
  final TemaViewModel tema;
  final AgendaViewModel agenda;
  final ClientesViewModel clientes;
  final ServiciosViewModel servicios;
  final EstilistasViewModel estilistas;
}
