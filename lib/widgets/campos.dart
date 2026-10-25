import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/turco_icons.dart';

/// Etiqueta pequeña sobre un campo. Se pinta en color de error si el campo
/// tiene un error.
class EtiquetaCampo extends StatelessWidget {
  const EtiquetaCampo(this.texto, {super.key, this.error = false});

  final String texto;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: context.tt.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: error ? context.cs.error : context.cs.onSurfaceVariant,
      ),
    );
  }
}

/// Mensaje de error con icono, bajo el campo.
class MensajeError extends StatelessWidget {
  const MensajeError(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(TurcoIcons.circleAlert, size: 13, color: cs.error),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(texto, style: context.tt.bodySmall?.copyWith(color: cs.error)),
          ),
        ],
      ),
    );
  }
}

/// Campo de texto del diseño: etiqueta encima, caja con borde redondeado y
/// mensaje de error con icono debajo. Internamente es un [TextFormField] con
/// su `validator`, por lo que participa en `formKey.currentState!.validate()`.
class CampoTexto extends StatefulWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    this.controller,
    this.focusNode,
    this.validator,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.mostrarContador = false,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  final String etiqueta;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool mostrarContador;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  final GlobalKey<FormFieldState<String>> _campo = GlobalKey<FormFieldState<String>>();
  String? _error;

  String? _validar(String? v) {
    final e = widget.validator?.call(v);
    if (e != _error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _error = e);
      });
    }
    return e;
  }

  void _alCambiar(String v) {
    // Si el campo ya mostraba un error, se vuelve a validar al escribir.
    if (_error != null) _campo.currentState?.validate();
    widget.onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        EtiquetaCampo(widget.etiqueta, error: _error != null),
        const SizedBox(height: 4),
        TextFormField(
          key: _campo,
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: _validar,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: _alCambiar,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          style: context.tt.bodyMedium?.copyWith(color: cs.onSurface),
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
          decoration: InputDecoration(
            hintText: widget.hint,
            // El texto del error se pinta con [MensajeError] (con icono).
            errorStyle: const TextStyle(fontSize: 0, height: 0),
          ),
        ),
        if (_error != null) MensajeError(_error!),
        if (widget.mostrarContador && widget.maxLength != null && widget.controller != null)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller!,
            builder: (context, valor, _) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${valor.text.characters.length} / ${widget.maxLength}',
                textAlign: TextAlign.end,
                style: context.tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Caja de selección (Cliente, Estilista, Fecha): icono, valor o pista y
/// flecha. Es un [FormField] cuyo `validator` consulta al ViewModel.
class CajaSelector extends FormField<Object> {
  CajaSelector({
    super.key,
    required String etiqueta,
    required IconData icono,
    required String? valor,
    required String pista,
    required VoidCallback? alPulsar,
    required String? Function() validar,
    FocusNode? focusNode,
  }) : super(
          validator: (_) => validar(),
          builder: (field) {
            final context = field.context;
            final cs = context.cs;
            final tokens = context.tokens;
            final hayError = field.hasError;
            final vacio = valor == null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                EtiquetaCampo(etiqueta, error: hayError),
                const SizedBox(height: 4),
                _CajaConFoco(
                  focusNode: focusNode,
                  alPulsar: alPulsar,
                  error: hayError,
                  alto: tokens.alturaCampo,
                  child: Row(
                    children: [
                      Icon(icono, size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          valor ?? pista,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.tt.bodyMedium?.copyWith(
                            color: vacio ? cs.onSurfaceVariant : cs.onSurface,
                          ),
                        ),
                      ),
                      Icon(TurcoIcons.chevronDown, size: 18, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
                if (hayError) MensajeError(field.errorText!),
              ],
            );
          },
        );
}

class _CajaConFoco extends StatelessWidget {
  const _CajaConFoco({
    required this.focusNode,
    required this.alPulsar,
    required this.error,
    required this.child,
    required this.alto,
  });

  final FocusNode? focusNode;
  final VoidCallback? alPulsar;
  final bool error;
  final Widget child;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final radio = BorderRadius.circular(context.tokens.radioCampo);
    Widget caja(bool enfocado) {
      final color = error ? cs.error : (enfocado ? cs.primary : cs.outline);
      final ancho = (error || enfocado) ? 2.0 : 1.0;
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          focusNode: focusNode,
          borderRadius: radio,
          onTap: alPulsar,
          child: Container(
            height: alto,
            padding: EdgeInsets.symmetric(horizontal: 14 - (ancho - 1)),
            decoration: BoxDecoration(
              borderRadius: radio,
              border: Border.all(color: color, width: ancho),
            ),
            child: child,
          ),
        ),
      );
    }

    final nodo = focusNode;
    if (nodo == null) return caja(false);
    return ListenableBuilder(listenable: nodo, builder: (context, _) => caja(nodo.hasFocus));
  }
}

/// SegmentedButton de ancho completo con el estilo del diseño.
class SelectorSegmentado<T> extends StatelessWidget {
  const SelectorSegmentado({
    super.key,
    required this.valores,
    required this.seleccionado,
    required this.etiqueta,
    required this.alCambiar,
    this.error = false,
  });

  final List<T> valores;
  final T? seleccionado;
  final String Function(T) etiqueta;
  final ValueChanged<T> alCambiar;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final sel = seleccionado;
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        segments: [
          for (final v in valores)
            ButtonSegment<T>(
              value: v,
              label: Text(etiqueta(v), maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
            ),
        ],
        selected: sel == null ? <T>{} : <T>{sel},
        emptySelectionAllowed: true,
        showSelectedIcon: true,
        selectedIcon: const Icon(TurcoIcons.check, size: 14),
        onSelectionChanged: (s) {
          if (s.isNotEmpty) alCambiar(s.first);
        },
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (e) => e.contains(WidgetState.selected) ? cs.onSecondaryContainer : cs.onSurface,
          ),
          side: error ? WidgetStatePropertyAll(BorderSide(color: cs.error)) : null,
        ),
      ),
    );
  }
}
