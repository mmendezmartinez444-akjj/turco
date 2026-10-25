import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cliente.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/salon_repository.dart';
import '../../../viewmodels/cliente_form_view_model.dart';
import '../../../widgets/campos.dart';
import '../../../widgets/dialogos.dart';

/// Abre el formulario de alta / edición de cliente en una hoja inferior
/// (showModalBottomSheet con isScrollControlled). Lo usan la pantalla
/// Clientes y el formulario de turno ("Crear cliente nuevo").
Future<Cliente?> mostrarFormularioCliente(
  BuildContext context,
  SalonRepository repo, {
  Cliente? cliente,
}) {
  return showModalBottomSheet<Cliente>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => _HojaCliente(repo: repo, cliente: cliente),
  );
}

class _HojaCliente extends StatefulWidget {
  const _HojaCliente({required this.repo, this.cliente});

  final SalonRepository repo;
  final Cliente? cliente;

  @override
  State<_HojaCliente> createState() => _HojaClienteState();
}

class _HojaClienteState extends State<_HojaCliente> {
  late final ClienteFormViewModel vm = ClienteFormViewModel(widget.repo, cliente: widget.cliente);

  final _formKey = GlobalKey<FormState>();
  final _generoKey = GlobalKey<FormFieldState<Genero>>();

  late final TextEditingController _nombre = TextEditingController(text: widget.cliente?.nombre ?? '');
  late final TextEditingController _telefono = TextEditingController(text: widget.cliente?.telefono ?? '');
  late final TextEditingController _correo = TextEditingController(text: widget.cliente?.correo ?? '');

  final FocusNode _fNombre = FocusNode();
  final FocusNode _fTelefono = FocusNode();
  final FocusNode _fGenero = FocusNode();
  final FocusNode _fCorreo = FocusNode();

  @override
  void dispose() {
    vm.dispose();
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    _fNombre.dispose();
    _fTelefono.dispose();
    _fGenero.dispose();
    _fCorreo.dispose();
    super.dispose();
  }

  void _elegirGenero(Genero g) {
    vm.elegirGenero(g);
    if (_generoKey.currentState?.hasError ?? false) _generoKey.currentState!.validate();
    setState(() {});
  }

  void _guardar() {
    final valido = _formKey.currentState!.validate();
    if (!valido) {
      // El foco va al primer campo con error.
      if (vm.validarNombre(_nombre.text) != null) {
        _fNombre.requestFocus();
      } else if (vm.validarTelefono(_telefono.text) != null) {
        _fTelefono.requestFocus();
      } else if (vm.validarGenero(null) != null) {
        FocusScope.of(context).unfocus();
        _fGenero.requestFocus();
      } else {
        _fCorreo.requestFocus();
      }
      return;
    }
    final r = vm.guardar(nombre: _nombre.text, telefono: _telefono.text, correo: _correo.text);
    if (!r.esOk) {
      mostrarAviso(ScaffoldMessenger.maybeOf(context), r.error!);
      return;
    }
    Navigator.of(context).pop(r.valor);
  }

  @override
  Widget build(BuildContext context) {
    final gap = context.tokens.espacioGrande;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.esEdicion ? 'Editar cliente' : 'Nuevo cliente',
                style: context.textos.tituloHoja,
              ),
              SizedBox(height: gap),
              CampoTexto(
                etiqueta: 'Nombre',
                controller: _nombre,
                focusNode: _fNombre,
                validator: vm.validarNombre,
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                onFieldSubmitted: (_) => _fTelefono.requestFocus(),
              ),
              SizedBox(height: gap),
              CampoTexto(
                etiqueta: 'Teléfono',
                controller: _telefono,
                focusNode: _fTelefono,
                validator: vm.validarTelefono,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _fCorreo.requestFocus(),
              ),
              SizedBox(height: gap),
              FormField<Genero>(
                key: _generoKey,
                validator: (_) => vm.validarGenero(null),
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EtiquetaCampo('Género', error: field.hasError),
                    const SizedBox(height: 4),
                    Focus(
                      focusNode: _fGenero,
                      child: SelectorSegmentado<Genero>(
                        valores: Genero.values,
                        seleccionado: vm.genero,
                        etiqueta: (g) => g.etiqueta,
                        alCambiar: _elegirGenero,
                        error: field.hasError,
                      ),
                    ),
                    if (field.hasError) MensajeError(field.errorText!),
                  ],
                ),
              ),
              SizedBox(height: gap),
              CampoTexto(
                etiqueta: 'Correo (opcional)',
                controller: _correo,
                focusNode: _fCorreo,
                validator: vm.validarCorreo,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _guardar(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      child: const Text('Guardar cliente'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
