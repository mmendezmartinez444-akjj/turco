import '../../core/utils/formato.dart';
import '../models/cliente.dart';
import '../models/enums.dart';
import '../models/estilista.dart';
import '../models/horario.dart';
import '../models/servicio.dart';
import '../models/turno.dart';

class DatosSemilla {
  const DatosSemilla(this.servicios, this.estilistas, this.clientes, this.turnos);

  final List<Servicio> servicios;
  final List<Estilista> estilistas;
  final List<Cliente> clientes;
  final List<Turno> turnos;
}

/// Datos de prueba cargados en memoria al iniciar la app.
///
/// Las fechas de los turnos se calculan a partir de `DateTime.now()` para que
/// nunca queden vencidas: se reparten en siete días laborables alrededor de hoy
/// (tres antes, hoy y tres después). Los turnos que ya pasaron quedan como
/// completados o cancelados y los futuros como programados.
class DatosPrueba {
  DatosPrueba._();

  // --- Servicios: 13 servicios en 5 categorías ------------------------------
  // Solo mujeres: 1, 4, 5, 10 · Solo hombres: 2, 3, 7, 8, 9 · Unisex: 6, 11, 12, 13
  static const List<Servicio> servicios = [
    Servicio(id: 1, nombre: 'Corte mujer', categoria: Categoria.corte, duracionMin: 60, precio: 30, publico: Publico.mujeres),
    Servicio(id: 2, nombre: 'Corte caballero', categoria: Categoria.corte, duracionMin: 45, precio: 25, publico: Publico.hombres),
    Servicio(id: 3, nombre: 'Corte clásico', categoria: Categoria.corte, duracionMin: 30, precio: 18, publico: Publico.hombres),
    Servicio(id: 4, nombre: 'Color completo', categoria: Categoria.color, duracionMin: 120, precio: 70, publico: Publico.mujeres),
    Servicio(id: 5, nombre: 'Mechas', categoria: Categoria.color, duracionMin: 90, precio: 55, publico: Publico.mujeres),
    Servicio(id: 6, nombre: 'Tinte de canas', categoria: Categoria.color, duracionMin: 60, precio: 35, publico: Publico.unisex),
    Servicio(id: 7, nombre: 'Barba', categoria: Categoria.barba, duracionMin: 45, precio: 20, publico: Publico.hombres),
    Servicio(id: 8, nombre: 'Afeitado', categoria: Categoria.barba, duracionMin: 30, precio: 15, publico: Publico.hombres),
    Servicio(id: 9, nombre: 'Arreglo de barba', categoria: Categoria.barba, duracionMin: 30, precio: 12, publico: Publico.hombres),
    Servicio(id: 10, nombre: 'Peinado', categoria: Categoria.peinado, duracionMin: 30, precio: 20, publico: Publico.mujeres),
    Servicio(id: 11, nombre: 'Peinado evento', categoria: Categoria.peinado, duracionMin: 60, precio: 40, publico: Publico.unisex),
    Servicio(id: 12, nombre: 'Hidratación', categoria: Categoria.tratamiento, duracionMin: 45, precio: 28, publico: Publico.unisex),
    Servicio(id: 13, nombre: 'Keratina', categoria: Categoria.tratamiento, duracionMin: 90, precio: 60, publico: Publico.unisex),
  ];

  // --- Estilistas: 5 con especialidades distintas ---------------------------
  static const List<Estilista> estilistas = [
    // Solo servicios de mujeres.
    Estilista(id: 1, nombre: 'Marta Salazar', avatar: 'assets/images/estilistas/estilista_1.png', servicioIds: [1, 4, 5, 10]),
    // Solo servicios de hombres.
    Estilista(id: 2, nombre: 'Pedro Vega', avatar: 'assets/images/estilistas/estilista_2.png', servicioIds: [2, 3, 7, 8, 9]),
    // Servicios de mujeres y de hombres.
    Estilista(id: 3, nombre: 'Lucía Torres', avatar: 'assets/images/estilistas/estilista_3.png', servicioIds: [1, 2, 11, 12, 13]),
    // Barbería y color unisex (sin turnos hoy).
    Estilista(id: 4, nombre: 'Rafael Núñez', avatar: 'assets/images/estilistas/estilista_4.png', servicioIds: [2, 3, 6, 7, 9, 12]),
    // Color, peinado y tratamientos.
    Estilista(id: 5, nombre: 'Elena Ríos', avatar: 'assets/images/estilistas/estilista_5.png', servicioIds: [4, 5, 6, 10, 11, 13]),
  ];

  static DatosSemilla generar(DateTime ahora) {
    final hoy = Fechas.soloDia(ahora);
    // "Hoy" de los datos: si hoy es domingo (salón cerrado) se usa el lunes.
    final ancla = Horario.proximoLaborable(hoy);

    // Tres días laborables antes y tres después del ancla (se saltan domingos).
    DateTime laborable(int desplazamiento) {
      var d = ancla;
      final paso = desplazamiento >= 0 ? 1 : -1;
      var restantes = desplazamiento.abs();
      while (restantes > 0) {
        d = Fechas.sumarDias(d, paso);
        if (Horario.abierto(d)) restantes--;
      }
      return d;
    }

    // --- Clientes: 10 (5 mujeres, 5 hombres). Javier y Andrés sin turnos. ---
    DateTime registro(int dias) => Fechas.sumarDias(hoy, -dias);
    final clientes = <Cliente>[
      Cliente(id: 1, nombre: 'Laura Gómez', telefono: '52111222', genero: Genero.mujer, correo: 'laura.gomez@correo.com', fechaRegistro: registro(210)),
      Cliente(id: 2, nombre: 'Carlos Ruiz', telefono: '52345678', genero: Genero.hombre, correo: 'carlos.ruiz@correo.com', fechaRegistro: registro(180)),
      Cliente(id: 3, nombre: 'Ana Martín', telefono: '53220140', genero: Genero.mujer, fechaRegistro: registro(150)),
      Cliente(id: 4, nombre: 'Diego Pérez', telefono: '55908771', genero: Genero.hombre, fechaRegistro: registro(120)),
      Cliente(id: 5, nombre: 'Sofía Díaz', telefono: '54667310', genero: Genero.mujer, correo: 'sofia.diaz@correo.com', fechaRegistro: registro(95)),
      Cliente(id: 6, nombre: 'Javier Soto', telefono: '52774009', genero: Genero.hombre, fechaRegistro: registro(60)),
      Cliente(id: 7, nombre: 'Marta Peña', telefono: '53441902', genero: Genero.mujer, fechaRegistro: registro(45)),
      Cliente(id: 8, nombre: 'Luis Herrera', telefono: '56123987', genero: Genero.hombre, correo: 'luis.herrera@correo.com', fechaRegistro: registro(30)),
      Cliente(id: 9, nombre: 'Valeria Ortiz', telefono: '58234511', genero: Genero.mujer, fechaRegistro: registro(20)),
      Cliente(id: 10, nombre: 'Andrés Molina', telefono: '59012345', genero: Genero.hombre, fechaRegistro: registro(7)),
    ];

    const notaLarga =
        'Novia: prueba de peinado y color para su boda del sábado. Quiere un tono castaño '
        'claro con reflejos miel, sin aclarar demasiado las puntas porque tiene el cabello '
        'sensibilizado por una keratina anterior. Traerá fotos de referencia y el tocado. '
        'Pidió que el peinado sea un recogido bajo con mechones sueltos al frente. Tiene '
        'alergia leve a algunos tintes con amoníaco: usar línea sin amoníaco y hacer prueba '
        'de sensibilidad detrás de la oreja antes de aplicar. Llegará con el cabello lavado.';

    var siguienteId = 1;
    final turnos = <Turno>[];

    /// Crea un turno de prueba. Si su inicio ya pasó, queda completado (o
    /// cancelado si así se indica); si es futuro, queda programado.
    void turno(int dia, int h, int m, int cliente, int estilista, List<int> svc,
        {String? notas, bool cancelado = false}) {
      final fecha = laborable(dia);
      final inicio = DateTime(fecha.year, fecha.month, fecha.day, h, m);
      final EstadoTurno estado;
      if (cancelado) {
        estado = EstadoTurno.cancelado;
      } else if (inicio.isBefore(ahora)) {
        estado = EstadoTurno.completado;
      } else {
        estado = EstadoTurno.programado;
      }
      var creado = Fechas.sumarDias(inicio, -6).add(const Duration(hours: 2));
      if (creado.isAfter(ahora)) creado = ahora;
      var modificado = creado.add(const Duration(days: 3));
      if (modificado.isAfter(ahora)) modificado = ahora;
      if (modificado.isBefore(creado)) modificado = creado;
      turnos.add(Turno(
        id: siguienteId++,
        clienteId: cliente,
        estilistaId: estilista,
        servicioIds: List.unmodifiable(svc),
        inicio: inicio,
        notas: notas,
        estado: estado,
        creado: creado,
        modificado: modificado,
      ));
    }

    // Tres días antes: siempre en el pasado.
    turno(-3, 10, 0, 1, 1, [1], notas: 'Puntas rectas, sin capas.');
    turno(-3, 11, 0, 2, 2, [7], notas: 'Avisó que no podía venir.', cancelado: true);
    turno(-2, 9, 0, 3, 5, [4, 10], notas: 'Mismo tono que la vez anterior.');
    turno(-2, 16, 0, 4, 4, [3]);
    turno(-1, 12, 0, 5, 3, [12], notas: 'Cabello muy seco en las puntas.');
    turno(-1, 17, 0, 8, 2, [2], notas: 'Canceló por trabajo.', cancelado: true);

    // Hoy (6 turnos). Rafael y Elena no tienen turnos hoy.
    turno(0, 9, 0, 1, 1, [1], notas: 'Quiere probar flequillo cortina.');
    turno(0, 10, 0, 2, 2, [2, 7],
        notas: 'Prefiere la máquina en el número 2 a los lados. Llega siempre diez minutos antes y pide agua.');
    turno(0, 10, 30, 3, 1, [4, 10], notas: 'Trae foto del color que quiere.');
    turno(0, 12, 0, 4, 2, [9], notas: 'Canceló por enfermedad.', cancelado: true);
    turno(0, 14, 0, 5, 3, [12, 1], notas: 'Corte solo de mantenimiento.');
    // Termina exactamente a las 19:00 (17:30 + 90 min).
    turno(0, 17, 30, 7, 3, [13], notas: 'Primera vez con keratina.');

    // Tres días después: futuros.
    turno(1, 9, 0, 9, 5, [4, 10, 13], notas: notaLarga); // 3 servicios, notas > 300
    turno(2, 11, 0, 8, 4, [2, 6]); // sin notas
    turno(3, 10, 0, 2, 2, [2], notas: 'Corte de mantenimiento mensual.');
    turno(3, 15, 30, 5, 5, [11], notas: 'Peinado para una graduación.');

    return DatosSemilla(servicios, estilistas, clientes, turnos);
  }
}
