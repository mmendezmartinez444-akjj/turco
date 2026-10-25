import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/turco_icons.dart';
import '../../core/utils/formato.dart';
import '../../data/models/enums.dart';
import '../../data/models/turno.dart';
import '../../router/app_router.dart';
import '../../viewmodels/turno_form_view_model.dart';
import '../../widgets/avatares.dart';
import '../../widgets/campos.dart';
import '../../widgets/dialogos.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/hoja_seleccion.dart';
import '../clientes/widgets/cliente_form_sheet.dart';
import 'widgets/cuadricula_franjas.dart';

/// RF3 · Formulario de turno (crear en /turno/nuevo y editar en /turno/:id/editar).
class TurnoFormScreen extends StatefulWidget {
  const TurnoFormScreen({super.key, required this.deps, this.args, this.turnoId});

  final AppDependencies deps;

  /// Datos iniciales enviados con `extra` (cliente, servicio o fecha).
  final NuevoTurnoArgs? args;

  /// Turno a editar (parámetro de ruta).
  final int? turnoId;

  @override
  State<TurnoFormScreen> createState() => _TurnoFormScreenState();
}

class _TurnoFormScreenState extends State<TurnoFormScreen> {
  late final TurnoFormViewModel vm =
      TurnoFormViewModel(widget.deps.repo, turnoId: widget.turnoId, args: widget.args);

  final _formKey = GlobalKey<FormState>();
  final _kCliente = GlobalKey<FormFieldState<Object>>();
  final _kServicios = GlobalKey<FormFieldState<Object>>();
  final _kEstilista = GlobalKey<FormFieldState<Object>>();
  final _kFecha = GlobalKey<FormFieldState<Object>>();
  final _kHora = GlobalKey<FormFieldState<Object>>();
  final _kNotas = GlobalKey();

  final _fCliente = FocusNode(debugLabel: 'cliente');
  final _fServicios = FocusNode(debugLabel: 'servicios');
  final _fEstilista = FocusNode(debugLabel: 'estilista');
  final _fFecha = FocusNode(debugLabel: 'fecha');
  final _fHora = FocusNode(debugLabel: 'hora');
  final _fNotas = FocusNode(debugLabel: 'notas');

  late final TextEditingController _notas = TextEditingController(text: vm.notas);

  bool _intentoGuardar = false;
  bool _permitirSalida = false;

  @override
  void initState() {
    super.initState();
    vm.addListener(_alCambiarVm);
  }

  @override
  void dispose() {
    vm.removeListener(_alCambiarVm);
    vm.dispose();
    _notas.dispose();
    for (final f in [_fCliente, _fServicios, _fEstilista, _fFecha, _fHora, _fNotas]) {
      f.dispose();
    }
    super.dispose();
  }

  /// Tras cada cambio: muestra avisos del ViewModel y, si ya se intentó
  /// guardar, revalida los campos para actualizar los mensajes.
  void _alCambiarVm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final aviso = vm.consumirAviso();
      if (aviso != null) mostrarAviso(ScaffoldMessenger.maybeOf(context), aviso);
      if (_intentoGuardar) {
        for (final k in [_kCliente, _kServicios, _kEstilista, _kFecha, _kHora]) {
          k.currentState?.validate();
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Selectores
  // ---------------------------------------------------------------------------

  Future<void> _elegirCliente() async {
    final id = await elegirEnHoja<int>(
      context,
      titulo: 'Elegir cliente',
      buscable: true,
      seleccionado: vm.clienteId,
      vacio: 'No hay clientes que coincidan.',
      opciones: [
        for (final c in vm.clientes)
          OpcionHoja(
            valor: c.id,
            titulo: c.nombre,
            subtitulo: '${Formato.telefono(c.telefono)} · ${c.genero.etiqueta}',
            inicio: AvatarCliente(nombre: c.nombre, genero: c.genero, tamano: 40),
          ),
      ],
    );
    if (id != null) {
      vm.elegirCliente(id);
      _fServicios.requestFocus();
    }
  }

  Future<void> _crearCliente() async {
    final nuevo = await mostrarFormularioCliente(context, widget.deps.repo);
    if (nuevo != null) {
      vm.elegirCliente(nuevo.id);
      if (mounted) mostrarAviso(ScaffoldMessenger.maybeOf(context), 'Cliente ${nuevo.nombre} registrado');
    }
  }

  Future<void> _elegirEstilista() async {
    if (vm.servicioIds.isEmpty) {
      mostrarAviso(ScaffoldMessenger.maybeOf(context), 'Primero elige los servicios');
      return;
    }
    final id = await elegirEnHoja<int>(
      context,
      titulo: 'Elegir estilista',
      seleccionado: vm.estilistaId,
      vacio: 'Ningún estilista realiza todos los servicios elegidos.',
      opciones: [
        for (final e in vm.estilistasValidos)
          OpcionHoja(
            valor: e.id,
            titulo: e.nombre,
            inicio: AvatarEstilista(avatar: e.avatar, tamano: 40),
          ),
      ],
    );
    if (id != null) {
      vm.elegirEstilista(id);
      _fFecha.requestFocus();
    }
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final inicial = (vm.fecha != null && vm.fechaPermitida(vm.fecha!)) ? vm.fecha! : vm.primeraFechaPermitida;
    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
      // No permite fechas pasadas ni domingos.
      selectableDayPredicate: vm.fechaPermitida,
      helpText: 'Fecha del turno',
    );
    if (elegida != null) {
      vm.elegirFecha(elegida);
      _fHora.requestFocus();
    }
  }

  // ---------------------------------------------------------------------------
  // Guardar / salir
  // ---------------------------------------------------------------------------

  void _salir([TurnoGuardado? resultado]) {
    setState(() => _permitirSalida = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        // El resultado viaja de vuelta con context.pop(valor).
        context.pop(resultado);
      } else {
        context.go(Rutas.agenda);
      }
    });
  }

  Future<void> _confirmarSalida() async {
    final descartar = await confirmar(
      context,
      titulo: '¿Descartar los cambios?',
      mensaje: 'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.',
      confirmarTexto: 'Descartar',
      cancelarTexto: 'Seguir editando',
    );
    if (descartar && mounted) _salir();
  }

  void _guardar() {
    setState(() => _intentoGuardar = true);
    final valido = _formKey.currentState!.validate();
    if (!valido) {
      _enfocarPrimerError();
      return;
    }
    final r = vm.guardar();
    if (!r.esOk) {
      mostrarAviso(ScaffoldMessenger.maybeOf(context), r.error!);
      return;
    }
    _salir(r.valor);
  }

  /// Al fallar la validación, el foco va al primer campo con error.
  void _enfocarPrimerError() {
    final orden = <(String? Function(), FocusNode, GlobalKey)>[
      (vm.validarCliente, _fCliente, _kCliente),
      (vm.validarServicios, _fServicios, _kServicios),
      (vm.validarEstilista, _fEstilista, _kEstilista),
      (vm.validarFecha, _fFecha, _kFecha),
      (vm.validarHora, _fHora, _kHora),
      (() => vm.validarNotas(_notas.text), _fNotas, _kNotas),
    ];
    for (final (validar, nodo, clave) in orden) {
      if (validar() != null) {
        nodo.requestFocus();
        final ctx = clave.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.1);
        }
        return;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Vista
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (!vm.puedeEditarse) return _noEditable(context);
        return PopScope(
          // Aviso de confirmación si se intenta salir con cambios sin guardar.
          canPop: _permitirSalida || !vm.hayCambios,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _confirmarSalida();
          },
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 4,
              leading: IconButton(
                tooltip: 'Volver',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(TurcoIcons.chevronLeft),
              ),
              title: Text(vm.esEdicion ? 'Editar turno' : 'Nuevo turno'),
            ),
            body: Column(
              children: [
                Expanded(child: _formulario(context)),
                _BarraInferior(vm: vm, alCancelar: () => Navigator.maybePop(context), alGuardar: _guardar),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _noEditable(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        leading: IconButton(onPressed: () => _salir(), icon: const Icon(TurcoIcons.chevronLeft)),
        title: const Text('Editar turno'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: EstadoVacio(
            imagen: 'assets/images/ilustraciones/no_encontrado.png',
            titulo: 'No se puede editar este turno',
            mensaje: 'El turno no existe o ya no está programado. Solo los turnos programados se pueden editar.',
            error: true,
            margenSuperior: 90,
            accion: FilledButton.icon(
              onPressed: () => context.go(Rutas.agenda),
              icon: const Icon(TurcoIcons.arrowLeft, size: 18),
              label: const Text('Volver a la agenda'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    final tk = context.tokens;
    final gap = tk.espacio;

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(tk.margenPantalla, 4, tk.margenPantalla, 16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          // --- Cliente ---------------------------------------------------------
          CajaSelector(
            key: _kCliente,
            etiqueta: 'Cliente',
            icono: TurcoIcons.user,
            valor: vm.cliente?.nombre,
            pista: 'Selecciona un cliente',
            alPulsar: _elegirCliente,
            validar: vm.validarCliente,
            focusNode: _fCliente,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                textStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              onPressed: _crearCliente,
              icon: const Icon(TurcoIcons.userPlus, size: 16),
              label: const Text('Crear cliente nuevo'),
            ),
          ),
          // --- Público ---------------------------------------------------------
          const EtiquetaCampo('Servicios para'),
          const SizedBox(height: 4),
          SelectorSegmentado<FiltroPublico>(
            valores: FiltroPublico.values,
            seleccionado: vm.publico,
            etiqueta: (p) => p.etiqueta,
            alCambiar: vm.elegirPublico,
          ),
          SizedBox(height: gap + 2),
          // --- Servicios (selección múltiple agrupada por categoría) -----------
          Text('Servicios', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          FormField<Object>(
            key: _kServicios,
            validator: (_) => vm.validarServicios(),
            builder: (field) => Focus(
              focusNode: _fServicios,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final grupo in vm.serviciosAgrupados.entries) ...[
                    Text(
                      grupo.key.etiqueta.toUpperCase(),
                      style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in grupo.value)
                          FilterChip(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            label: Text(s.nombre),
                            selected: vm.servicioIds.contains(s.id),
                            onSelected: (_) => vm.alternarServicio(s.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (field.hasError) MensajeError(field.errorText!),
                ],
              ),
            ),
          ),
          SizedBox(height: gap),
          // --- Estilista -------------------------------------------------------
          CajaSelector(
            key: _kEstilista,
            etiqueta: 'Estilista',
            icono: TurcoIcons.scissors,
            valor: vm.estilista?.nombre,
            pista: vm.servicioIds.isEmpty ? 'Primero elige los servicios' : 'Selecciona un estilista',
            alPulsar: _elegirEstilista,
            validar: vm.validarEstilista,
            focusNode: _fEstilista,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(TurcoIcons.info, size: 14, color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Solo se muestran estilistas que realizan todos los servicios elegidos.',
                  style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w400, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          SizedBox(height: gap + 6),
          // --- Fecha -----------------------------------------------------------
          CajaSelector(
            key: _kFecha,
            etiqueta: 'Fecha',
            icono: TurcoIcons.calendar,
            valor: vm.fecha == null ? null : Formato.fechaLarga(vm.fecha!),
            pista: 'Selecciona una fecha',
            alPulsar: _elegirFecha,
            validar: vm.validarFecha,
            focusNode: _fFecha,
          ),
          SizedBox(height: gap + 2),
          // --- Hora (cuadrícula de franjas) -------------------------------------
          Text('Hora de inicio', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const LeyendaFranjas(),
          const SizedBox(height: 8),
          FormField<Object>(
            key: _kHora,
            validator: (_) => vm.validarHora(),
            builder: (field) {
              final franjas = vm.franjas;
              return Focus(
                focusNode: _fHora,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vm.fecha == null)
                      const _Nota(texto: 'Elige una fecha para ver las horas disponibles.')
                    else ...[
                      CuadriculaFranjas(
                        franjas: franjas,
                        elegida: vm.hora,
                        error: field.hasError,
                        alElegir: (h) {
                          vm.elegirHora(h);
                          _fNotas.requestFocus();
                        },
                      ),
                      if (!vm.hayFranjasLibres)
                        const _Nota(
                          texto: 'No quedan horas libres para esta fecha. Prueba con otro día, otro estilista u otros servicios.',
                        ),
                    ],
                    if (field.hasError) MensajeError(field.errorText!),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: gap + 2),
          // --- Notas -----------------------------------------------------------
          CampoTexto(
            key: _kNotas,
            etiqueta: 'Notas (opcional)',
            controller: _notas,
            focusNode: _fNotas,
            validator: vm.validarNotas,
            maxLength: TurnoFormViewModel.maxNotas,
            mostrarContador: true,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 5,
            onChanged: vm.cambiarNotas,
            onFieldSubmitted: (_) => _fNotas.unfocus(),
          ),
        ],
      ),
    );
  }
}

class _Nota extends StatelessWidget {
  const _Nota({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(TurcoIcons.info, size: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(texto, style: context.tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

/// Resumen siempre visible (duración, fin y precio) y botones.
class _BarraInferior extends StatelessWidget {
  const _BarraInferior({required this.vm, required this.alCancelar, required this.alGuardar});

  final TurnoFormViewModel vm;
  final VoidCallback alCancelar;
  final VoidCallback alGuardar;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final tt = context.tt;
    // Con el teclado abierto se mantiene visible el resumen y se ocultan los
    // botones para no quitar espacio al formulario.
    final teclado = MediaQuery.viewInsetsOf(context).bottom > 0;
    final estilo = tt.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onPrimaryContainer);
    Widget dato(IconData icono, String texto, {bool negrita = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 14, color: cs.primary),
            const SizedBox(width: 4),
            Text(texto, style: negrita ? estilo?.copyWith(fontWeight: FontWeight.w700) : estilo),
          ],
        );
    final fin = vm.fin;
    return Material(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, teclado ? 12 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(context.tokens.radioCampo),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: dato(TurcoIcons.clock, Formato.duracion(vm.duracion))),
                    Flexible(child: dato(TurcoIcons.flag, fin == null ? 'Fin --:--' : 'Fin ${Formato.hora(fin)}')),
                    Flexible(child: dato(TurcoIcons.badgeDollarSign, Formato.dinero(vm.precio), negrita: true)),
                  ],
                ),
              ),
              if (!teclado) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: alCancelar, child: const Text('Cancelar'))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: alGuardar,
                        icon: const Icon(TurcoIcons.check, size: 18),
                        label: const Text('Guardar turno'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
