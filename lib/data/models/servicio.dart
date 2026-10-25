import 'enums.dart';

/// Servicio del catálogo (solo lectura).
class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.duracionMin,
    required this.precio,
    required this.publico,
  });

  final int id;
  final String nombre;
  final Categoria categoria;

  /// Duración en minutos.
  final int duracionMin;

  /// Precio en pesos enteros.
  final int precio;
  final Publico publico;

  @override
  bool operator ==(Object other) => other is Servicio && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
