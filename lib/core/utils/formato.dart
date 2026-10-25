/// Formateo de fechas, horas, duraciones, dinero y teléfonos en español.
/// Se implementa a mano para no depender de paquetes externos.
class Formato {
  Formato._();

  static const List<String> _diasLargos = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const List<String> _diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const List<String> _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String _dos(int n) => n.toString().padLeft(2, '0');

  static String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// "Lun", "Mar", ... "Dom".
  static String diaCorto(DateTime d) => _diasCortos[d.weekday - 1];

  /// "Octubre 2026".
  static String mesAnio(DateTime d) => '${_capitalizar(_meses[d.month - 1])} ${d.year}';

  /// "Miércoles 21 de octubre de 2026".
  static String fechaLarga(DateTime d) =>
      '${_diasLargos[d.weekday - 1]} ${d.day} de ${_meses[d.month - 1]} de ${d.year}';

  /// "mié 21 de octubre".
  static String fechaMedia(DateTime d) =>
      '${_diasCortos[d.weekday - 1].toLowerCase()} ${d.day} de ${_meses[d.month - 1]}';

  /// "21/10/2026".
  static String fechaNumerica(DateTime d) => '${_dos(d.day)}/${_dos(d.month)}/${d.year}';

  /// "21/10".
  static String diaMes(DateTime d) => '${_dos(d.day)}/${_dos(d.month)}';

  /// "09:30".
  static String hora(DateTime d) => '${_dos(d.hour)}:${_dos(d.minute)}';

  /// "45 min", "1 h", "1 h 30 min".
  static String duracion(int minutos) {
    if (minutos < 60) return '$minutos min';
    final h = minutos ~/ 60;
    final m = minutos % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  /// "$ 45".
  static String dinero(int monto) => '\$ $monto';

  /// "52 345 678".
  static String telefono(String t) {
    if (t.length != 8) return t;
    return '${t.substring(0, 2)} ${t.substring(2, 5)} ${t.substring(5)}';
  }

  /// Plural sencillo: "1 turno", "3 turnos".
  static String plural(int n, String singular, String plural) =>
      '$n ${n == 1 ? singular : plural}';
}

/// Utilidades de texto.
class Texto {
  Texto._();

  static const Map<String, String> _sinAcentos = {
    'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
    'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
    'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
    'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
    'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
    'ñ': 'n', 'ç': 'c',
  };

  /// Minúsculas y sin acentos, para búsquedas.
  static String normalizar(String s) {
    final b = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      b.write(_sinAcentos[ch] ?? ch);
    }
    return b.toString().trim();
  }

  /// Inicial en mayúscula de un nombre.
  static String inicial(String nombre) =>
      nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();
}

/// Utilidades de fechas sin hora.
class Fechas {
  Fechas._();

  static DateTime soloDia(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool esDomingo(DateTime d) => d.weekday == DateTime.sunday;

  /// Lunes de la semana que contiene a [d].
  static DateTime lunesDe(DateTime d) {
    final dia = soloDia(d);
    return dia.subtract(Duration(days: dia.weekday - DateTime.monday));
  }

  /// Suma días de calendario respetando cambios de horario.
  static DateTime sumarDias(DateTime d, int dias) => DateTime(d.year, d.month, d.day + dias);
}
