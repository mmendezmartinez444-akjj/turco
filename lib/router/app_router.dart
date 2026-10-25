import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_dependencies.dart';
import '../data/models/turno.dart';
import '../views/agenda/agenda_screen.dart';
import '../views/clientes/clientes_screen.dart';
import '../views/estilistas/estilistas_screen.dart';
import '../views/servicios/servicios_screen.dart';
import '../views/shell/home_shell.dart';
import '../views/turno/turno_detalle_screen.dart';
import '../views/turno/turno_form_screen.dart';

/// Rutas de la app.
class Rutas {
  Rutas._();

  static const agenda = '/agenda';
  static const clientes = '/clientes';
  static const servicios = '/servicios';
  static const estilistas = '/estilistas';
  static const nuevoTurno = '/turno/nuevo';

  static String detalleTurno(int id) => '/turno/$id';
  static String editarTurno(int id) => '/turno/$id/editar';
  static String agendaDeEstilista(int id) => '/agenda?estilista=$id';
}

final GlobalKey<NavigatorState> navegadorRaiz = GlobalKey<NavigatorState>(debugLabel: 'raiz');
final GlobalKey<NavigatorState> _navAgenda = GlobalKey<NavigatorState>(debugLabel: 'agenda');
final GlobalKey<NavigatorState> _navClientes = GlobalKey<NavigatorState>(debugLabel: 'clientes');
final GlobalKey<NavigatorState> _navServicios = GlobalKey<NavigatorState>(debugLabel: 'servicios');
final GlobalKey<NavigatorState> _navEstilistas = GlobalKey<NavigatorState>(debugLabel: 'estilistas');

GoRouter crearRouter(AppDependencies deps) {
  return GoRouter(
    navigatorKey: navegadorRaiz,
    initialLocation: Rutas.agenda,
    routes: [
      // Barra inferior con cuatro destinos. indexedStack conserva el estado
      // (y la posición de scroll) de cada pestaña.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _navAgenda,
            routes: [
              GoRoute(
                path: Rutas.agenda,
                builder: (context, state) => AgendaScreen(
                  deps: deps,
                  // Parámetro de consulta: /agenda?estilista=3
                  estilistaId: int.tryParse(state.uri.queryParameters['estilista'] ?? ''),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _navClientes,
            routes: [
              GoRoute(path: Rutas.clientes, builder: (context, state) => ClientesScreen(deps: deps)),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _navServicios,
            routes: [
              GoRoute(path: Rutas.servicios, builder: (context, state) => ServiciosScreen(deps: deps)),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _navEstilistas,
            routes: [
              GoRoute(path: Rutas.estilistas, builder: (context, state) => EstilistasScreen(deps: deps)),
            ],
          ),
        ],
      ),
      // Formulario de turno (crear). Recibe datos iniciales con `extra`.
      // Se declara antes de /turno/:id para que "nuevo" no se tome como id.
      GoRoute(
        path: Rutas.nuevoTurno,
        parentNavigatorKey: navegadorRaiz,
        builder: (context, state) {
          final extra = state.extra;
          return TurnoFormScreen(deps: deps, args: extra is NuevoTurnoArgs ? extra : null);
        },
      ),
      // Detalle de turno (parámetro de ruta) y su edición.
      GoRoute(
        path: '/turno/:id',
        parentNavigatorKey: navegadorRaiz,
        builder: (context, state) =>
            TurnoDetalleScreen(deps: deps, turnoId: int.tryParse(state.pathParameters['id'] ?? '')),
        routes: [
          GoRoute(
            path: 'editar',
            parentNavigatorKey: navegadorRaiz,
            builder: (context, state) =>
                TurnoFormScreen(deps: deps, turnoId: int.tryParse(state.pathParameters['id'] ?? '')),
          ),
        ],
      ),
    ],
    // Cualquier ruta desconocida muestra el mensaje de "no encontrado".
    errorBuilder: (context, state) => TurnoDetalleScreen(deps: deps, turnoId: null),
  );
}
