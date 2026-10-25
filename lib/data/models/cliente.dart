import 'enums.dart';

/// Cliente del salón.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.genero,
    this.correo,
    required this.fechaRegistro,
  });

  final int id;
  final String nombre;

  /// Exactamente 8 dígitos, único.
  final String telefono;
  final Genero genero;
  final String? correo;
  final DateTime fechaRegistro;

  Cliente copyWith({
    String? nombre,
    String? telefono,
    Genero? genero,
    String? correo,
    bool borrarCorreo = false,
  }) {
    return Cliente(
      id: id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      genero: genero ?? this.genero,
      correo: borrarCorreo ? null : (correo ?? this.correo),
      fechaRegistro: fechaRegistro,
    );
  }
}

/// Reglas de validación de un cliente (modelo, no widgets).
class ReglasCliente {
  ReglasCliente._();

  static final RegExp _correo = RegExp(r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$');
  static final RegExp _ochoDigitos = RegExp(r'^\d{8}$');

  static String? nombre(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'El nombre es obligatorio';
    if (t.length < 3 || t.length > 60) return 'Escribe entre 3 y 60 caracteres';
    return null;
  }

  static String? telefonoFormato(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'El teléfono es obligatorio';
    if (!_ochoDigitos.hasMatch(t)) return 'Debe tener exactamente 8 dígitos';
    return null;
  }

  static String? genero(Genero? g) => g == null ? 'Selecciona un género' : null;

  static String? correo(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    if (!_correo.hasMatch(t)) return 'Escribe un correo válido';
    return null;
  }
}
