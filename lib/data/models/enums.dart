/// Categorías del catálogo de servicios.
enum Categoria {
  corte('Corte', 'assets/images/categorias/corte.png'),
  color('Color', 'assets/images/categorias/color.png'),
  barba('Barba', 'assets/images/categorias/barba.png'),
  peinado('Peinado', 'assets/images/categorias/peinado.png'),
  tratamiento('Tratamiento', 'assets/images/categorias/tratamiento.png');

  const Categoria(this.etiqueta, this.imagen);

  final String etiqueta;

  /// Ruta del recurso gráfico propio de la categoría.
  final String imagen;
}

/// Público al que se dirige un servicio.
enum Publico {
  mujeres('Mujeres'),
  hombres('Hombres'),
  unisex('Unisex');

  const Publico(this.etiqueta);
  final String etiqueta;
}

/// Género del cliente.
enum Genero {
  mujer('Mujer'),
  hombre('Hombre');

  const Genero(this.etiqueta);
  final String etiqueta;

  /// Público por defecto de los servicios para este género.
  Publico get publico => this == Genero.mujer ? Publico.mujeres : Publico.hombres;
}

/// Estado de un turno.
enum EstadoTurno {
  programado('Programado'),
  completado('Completado'),
  cancelado('Cancelado');

  const EstadoTurno(this.etiqueta);
  final String etiqueta;
}

/// Filtro por público usado en Servicios y en el formulario de turno.
enum FiltroPublico {
  todos('Todos'),
  mujeres('Mujeres'),
  hombres('Hombres');

  const FiltroPublico(this.etiqueta);
  final String etiqueta;

  /// Un servicio pasa el filtro si es del público elegido o unisex.
  bool admite(Publico p) {
    switch (this) {
      case FiltroPublico.todos:
        return true;
      case FiltroPublico.mujeres:
        return p == Publico.mujeres || p == Publico.unisex;
      case FiltroPublico.hombres:
        return p == Publico.hombres || p == Publico.unisex;
    }
  }

  static FiltroPublico desdeGenero(Genero g) =>
      g == Genero.mujer ? FiltroPublico.mujeres : FiltroPublico.hombres;
}

/// Filtro por género en Clientes.
enum FiltroGenero {
  todos('Todos'),
  mujeres('Mujeres'),
  hombres('Hombres');

  const FiltroGenero(this.etiqueta);
  final String etiqueta;

  bool admite(Genero g) {
    switch (this) {
      case FiltroGenero.todos:
        return true;
      case FiltroGenero.mujeres:
        return g == Genero.mujer;
      case FiltroGenero.hombres:
        return g == Genero.hombre;
    }
  }
}

/// Filtro por estado en la Agenda.
enum FiltroEstado {
  todos('Todos'),
  programados('Program.'),
  completados('Complet.'),
  cancelados('Cancel.');

  const FiltroEstado(this.etiqueta);
  final String etiqueta;

  bool admite(EstadoTurno e) {
    switch (this) {
      case FiltroEstado.todos:
        return true;
      case FiltroEstado.programados:
        return e == EstadoTurno.programado;
      case FiltroEstado.completados:
        return e == EstadoTurno.completado;
      case FiltroEstado.cancelados:
        return e == EstadoTurno.cancelado;
    }
  }
}
