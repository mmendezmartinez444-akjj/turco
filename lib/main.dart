import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Turco · Gestión de turnos de una peluquería mixta.
/// Primer Examen Parcial · Programación para Dispositivos Móviles.
/// Autor: Manuel.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TurcoApp(deps: AppDependencies.crear()));
}

class TurcoApp extends StatefulWidget {
  const TurcoApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<TurcoApp> createState() => _TurcoAppState();
}

class _TurcoAppState extends State<TurcoApp> {
  late final GoRouter _router = crearRouter(widget.deps);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.deps.tema,
      builder: (context, _) => MaterialApp.router(
        title: 'Turco',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro(),
        darkTheme: AppTheme.oscuro(),
        themeMode: widget.deps.tema.modo,
        routerConfig: _router,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
