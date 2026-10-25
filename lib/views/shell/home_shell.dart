import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/turco_icons.dart';

/// Contenedor de las cuatro pestañas con la barra de navegación inferior.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _ir(int i) {
    // Tocar la pestaña activa vuelve a su ruta inicial.
    navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final enAgenda = navigationShell.currentIndex == 0;
    // Atrás del sistema: desde otra pestaña vuelve a la Agenda; desde la
    // Agenda sale de la app.
    return PopScope(
      canPop: enAgenda,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !enAgenda) _ir(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _ir,
          destinations: const [
            NavigationDestination(icon: Icon(TurcoIcons.calendarDays), label: 'Agenda'),
            NavigationDestination(icon: Icon(TurcoIcons.users), label: 'Clientes'),
            NavigationDestination(icon: Icon(TurcoIcons.scissors), label: 'Servicios'),
            NavigationDestination(icon: Icon(TurcoIcons.contact), label: 'Estilistas'),
          ],
        ),
      ),
    );
  }
}
