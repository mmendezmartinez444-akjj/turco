import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formato.dart';
import '../data/models/enums.dart';

/// Avatar circular con la inicial del cliente. Mujeres en primaryContainer y
/// hombres en tertiaryContainer, como en el diseño.
class AvatarCliente extends StatelessWidget {
  const AvatarCliente({super.key, required this.nombre, required this.genero, this.tamano = 44});

  final String nombre;
  final Genero genero;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final mujer = genero == Genero.mujer;
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: mujer ? cs.primaryContainer : cs.tertiaryContainer,
      ),
      child: Text(
        Texto.inicial(nombre),
        style: context.tt.titleSmall?.copyWith(
          fontSize: tamano * 0.4,
          color: mujer ? cs.onPrimaryContainer : cs.onTertiaryContainer,
        ),
      ),
    );
  }
}

/// Avatar de estilista a partir de su recurso gráfico (assets/images/estilistas).
class AvatarEstilista extends StatelessWidget {
  const AvatarEstilista({super.key, required this.avatar, this.tamano = 56});

  final String avatar;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      width: tamano,
      height: tamano,
      padding: EdgeInsets.all(tamano * 0.27),
      decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryContainer),
      child: Image.asset(avatar, color: cs.onPrimaryContainer, fit: BoxFit.contain),
    );
  }
}

/// Logo de Turco: tijeras sobre un cuadrado redondeado del color primario.
class LogoTurco extends StatelessWidget {
  const LogoTurco({super.key, this.tamano = 32});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      width: tamano,
      height: tamano,
      padding: EdgeInsets.all(tamano * 0.22),
      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(tamano * 0.31)),
      child: Image.asset('assets/images/logo.png', color: cs.onPrimary),
    );
  }
}
