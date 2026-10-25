import '../../core/utils/formato.dart';

/// Horario del salón: lunes a sábado de 9:00 a 19:00, franjas de 30 minutos.
class Horario {
  Horario._();

  static const int apertura = 9 * 60;
  static const int cierre = 19 * 60;
  static const int franja = 30;

  static bool abierto(DateTime dia) => !Fechas.esDomingo(dia);

  static int minutosDelDia(DateTime d) => d.hour * 60 + d.minute;

  static DateTime cierreDe(DateTime dia) => DateTime(dia.year, dia.month, dia.day, 19);

  /// Todas las horas de inicio posibles del día: 09:00, 09:30, ... 18:30.
  static List<DateTime> franjasDe(DateTime dia) {
    final lista = <DateTime>[];
    for (var m = apertura; m < cierre; m += franja) {
      lista.add(DateTime(dia.year, dia.month, dia.day, m ~/ 60, m % 60));
    }
    return lista;
  }

  /// Próximo día laborable a partir de [d] (incluido).
  static DateTime proximoLaborable(DateTime d) {
    var dia = Fechas.soloDia(d);
    while (!abierto(dia)) {
      dia = Fechas.sumarDias(dia, 1);
    }
    return dia;
  }

  /// Dos intervalos se solapan si uno empieza antes de que termine el otro.
  /// Un turno que termina a las 10:00 no se solapa con otro que empieza a las 10:00.
  static bool solapan(DateTime aIni, DateTime aFin, DateTime bIni, DateTime bFin) =>
      aIni.isBefore(bFin) && bIni.isBefore(aFin);
}

/// Motivo por el que una franja no está disponible.
enum MotivoFranja { pasada, fueraDeHorario, ocupadaEstilista, ocupadaCliente, cerrado }

/// Franja de inicio calculada para el formulario de turno.
class Franja {
  const Franja(this.inicio, this.motivo);

  final DateTime inicio;
  final MotivoFranja? motivo;

  bool get disponible => motivo == null;
}
