import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/turco_icons.dart';
import '../core/utils/formato.dart';

/// Opción de una [HojaSeleccion].
class OpcionHoja<T> {
  const OpcionHoja({required this.valor, required this.titulo, this.subtitulo, this.inicio});

  final T valor;
  final String titulo;
  final String? subtitulo;
  final Widget? inicio;
}

/// Abre una hoja inferior con una lista de opciones y devuelve la elegida.
Future<T?> elegirEnHoja<T>(
  BuildContext context, {
  required String titulo,
  required List<OpcionHoja<T>> opciones,
  T? seleccionado,
  bool buscable = false,
  String vacio = 'No hay opciones disponibles.',
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => HojaSeleccion<T>(
      titulo: titulo,
      opciones: opciones,
      seleccionado: seleccionado,
      buscable: buscable,
      vacio: vacio,
    ),
  );
}

class HojaSeleccion<T> extends StatefulWidget {
  const HojaSeleccion({
    super.key,
    required this.titulo,
    required this.opciones,
    this.seleccionado,
    this.buscable = false,
    this.vacio = 'No hay opciones disponibles.',
  });

  final String titulo;
  final List<OpcionHoja<T>> opciones;
  final T? seleccionado;
  final bool buscable;
  final String vacio;

  @override
  State<HojaSeleccion<T>> createState() => _HojaSeleccionState<T>();
}

class _HojaSeleccionState<T> extends State<HojaSeleccion<T>> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final q = Texto.normalizar(_filtro);
    final lista = widget.opciones
        .where((o) =>
            q.isEmpty ||
            Texto.normalizar(o.titulo).contains(q) ||
            (o.subtitulo ?? '').replaceAll(' ', '').contains(q.replaceAll(' ', '')))
        .toList();
    final alto = MediaQuery.sizeOf(context).height * 0.7;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alto),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(widget.titulo, style: context.tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (widget.buscable)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _filtro = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o teléfono',
                    prefixIcon: Icon(TurcoIcons.search, size: 20),
                  ),
                ),
              ),
            Flexible(
              child: lista.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.vacio,
                        textAlign: TextAlign.center,
                        style: context.tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: lista.length,
                      itemBuilder: (context, i) {
                        final o = lista[i];
                        final activo = o.valor == widget.seleccionado;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          leading: o.inicio,
                          title: Text(o.titulo),
                          subtitle: o.subtitulo == null ? null : Text(o.subtitulo!),
                          trailing: activo ? Icon(TurcoIcons.check, color: cs.primary, size: 18) : null,
                          onTap: () => Navigator.of(context).pop(o.valor),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
