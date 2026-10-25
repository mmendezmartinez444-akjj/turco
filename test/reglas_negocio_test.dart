import 'package:flutter_test/flutter_test.dart';
import 'package:turco/core/utils/formato.dart';
import 'package:turco/data/models/enums.dart';
import 'package:turco/data/models/horario.dart';
import 'package:turco/data/models/turno.dart';
import 'package:turco/data/repositories/salon_repository.dart';
import 'package:turco/viewmodels/agenda_view_model.dart';
import 'package:turco/viewmodels/clientes_view_model.dart';
import 'package:turco/viewmodels/turno_form_view_model.dart';

/// Pruebas de las reglas de negocio y de los datos de prueba.
/// Se ejecutan con: flutter test
void main() {
  // Varios "ahora" para comprobar que los datos nunca quedan vencidos.
  final relojes = <String, DateTime>{
    'sábado tarde': DateTime(2026, 10, 24, 18, 50),
    'domingo': DateTime(2026, 10, 25, 11, 0),
    'lunes temprano': DateTime(2026, 10, 26, 7, 30),
    'miércoles mediodía': DateTime(2026, 10, 21, 12, 15),
    'viernes noche': DateTime(2026, 10, 30, 23, 0),
  };

  relojes.forEach((nombre, ahora) {
    group('Datos de prueba ($nombre)', () {
      final repo = SalonRepository.conDatosDePrueba(reloj: () => ahora);
      final ancla = Horario.proximoLaborable(ahora);

      test('catálogo y estilistas', () {
        expect(repo.servicios.length, greaterThanOrEqualTo(12));
        expect(repo.servicios.map((s) => s.categoria).toSet().length, Categoria.values.length);
        for (final p in Publico.values) {
          expect(repo.servicios.where((s) => s.publico == p).length, greaterThanOrEqualTo(3));
        }
        expect(repo.estilistas.length, greaterThanOrEqualTo(5));
        bool solo(Publico p, List<int> ids) =>
            repo.serviciosDe(ids).every((s) => s.publico == p);
        expect(repo.estilistas.any((e) => solo(Publico.hombres, e.servicioIds)), isTrue);
        expect(repo.estilistas.any((e) => solo(Publico.mujeres, e.servicioIds)), isTrue);
        expect(
          repo.estilistas.any((e) {
            final p = repo.serviciosDe(e.servicioIds).map((s) => s.publico).toSet();
            return p.contains(Publico.hombres) && p.contains(Publico.mujeres);
          }),
          isTrue,
        );
      });

      test('clientes', () {
        expect(repo.clientes.length, greaterThanOrEqualTo(10));
        expect(repo.clientes.where((c) => c.genero == Genero.mujer).length, greaterThanOrEqualTo(5));
        expect(repo.clientes.where((c) => c.genero == Genero.hombre).length, greaterThanOrEqualTo(5));
        expect(repo.clientes.any((c) => repo.cantidadTurnosCliente(c.id) == 0), isTrue);
        expect(repo.clientes.map((c) => c.telefono).toSet().length, repo.clientes.length);
      });

      test('turnos', () {
        final ts = repo.turnos;
        expect(ts.length, greaterThanOrEqualTo(16));
        expect(ts.where((t) => Fechas.mismoDia(t.inicio, ancla)).length, greaterThanOrEqualTo(4));
        final dias = ts.map((t) => Fechas.soloDia(t.inicio)).toSet();
        expect(dias.length, 7);
        for (final t in ts) {
          expect(Horario.abierto(t.inicio), isTrue, reason: 'no hay turnos en domingo');
          expect(repo.finDe(t).isAfter(Horario.cierreDe(t.inicio)), isFalse);
          expect(repo.estilistaPorId(t.estilistaId)!.realizaTodos(t.servicioIds), isTrue);
          if (t.inicio.isBefore(ahora)) {
            expect(t.estado, isNot(EstadoTurno.programado), reason: 'los pasados no están programados');
          } else {
            expect(t.estado, isNot(EstadoTurno.completado));
          }
          expect(t.modificado.isBefore(t.creado), isFalse);
        }
        expect(ts.where((t) => t.estado == EstadoTurno.completado).length, greaterThanOrEqualTo(3));
        expect(ts.where((t) => t.estado == EstadoTurno.cancelado).length, greaterThanOrEqualTo(2));
        expect(ts.any((t) => t.servicioIds.length == 3), isTrue);
        expect(ts.any((t) => !t.tieneNotas), isTrue);
        expect(ts.any((t) => (t.notas ?? '').length > 300), isTrue);
        expect(ts.any((t) => Formato.hora(repo.finDe(t)) == '19:00'), isTrue);
        expect(
          repo.estilistas.any((e) => !ts.any((t) => t.estilistaId == e.id && Fechas.mismoDia(t.inicio, ancla))),
          isTrue,
        );
      });

      test('ningún par de turnos programados se solapa', () {
        final prog = repo.turnos.where((t) => t.esProgramado).toList();
        for (var i = 0; i < prog.length; i++) {
          for (var j = i + 1; j < prog.length; j++) {
            final a = prog[i], b = prog[j];
            if (a.estilistaId != b.estilistaId && a.clienteId != b.clienteId) continue;
            expect(Horario.solapan(a.inicio, repo.finDe(a), b.inicio, repo.finDe(b)), isFalse);
          }
        }
      });
    });
  });

  group('Reglas de turnos', () {
    // Martes 20/10/2026 a las 08:00: todo el día es futuro.
    final ahora = DateTime(2026, 10, 20, 8);
    late SalonRepository repo;
    setUp(() => repo = SalonRepository.conDatosDePrueba(reloj: () => ahora));
    final dia = DateTime(2026, 10, 24); // sábado sin turnos de prueba

    test('un turno que termina a las 10:00 no se solapa con otro que empieza a las 10:00', () {
      expect(Horario.solapan(DateTime(2026, 1, 1, 9), DateTime(2026, 1, 1, 10), DateTime(2026, 1, 1, 10),
          DateTime(2026, 1, 1, 11)), isFalse);
      final a = repo.crearTurno(clienteId: 6, estilistaId: 4, servicioIds: [2, 6], inicio: DateTime(2026, 10, 24, 9, 30));
      expect(a.esOk, isTrue, reason: a.error); // 9:30–11:15
      final b = repo.crearTurno(clienteId: 10, estilistaId: 4, servicioIds: [3], inicio: DateTime(2026, 10, 24, 11, 0));
      expect(b.esOk, isFalse); // 11:00 < 11:15
      final c = repo.crearTurno(clienteId: 10, estilistaId: 4, servicioIds: [3], inicio: DateTime(2026, 10, 24, 11, 30));
      expect(c.esOk, isTrue, reason: c.error);
    });

    test('no se permiten domingos, pasado ni pasar de las 19:00', () {
      expect(repo.crearTurno(clienteId: 6, estilistaId: 2, servicioIds: [2], inicio: DateTime(2026, 10, 25, 10)).esOk,
          isFalse);
      expect(repo.crearTurno(clienteId: 6, estilistaId: 2, servicioIds: [2], inicio: DateTime(2026, 10, 19, 10)).esOk,
          isFalse);
      // Keratina (90 min) a las 18:00 terminaría a las 19:30.
      expect(repo.crearTurno(clienteId: 6, estilistaId: 3, servicioIds: [13], inicio: DateTime(2026, 10, 24, 18)).esOk,
          isFalse);
      expect(repo.crearTurno(clienteId: 6, estilistaId: 3, servicioIds: [13], inicio: DateTime(2026, 10, 24, 17, 30)).esOk,
          isTrue);
    });

    test('el estilista debe realizar todos los servicios', () {
      // Pedro (2) solo hace servicios de hombres.
      expect(repo.crearTurno(clienteId: 6, estilistaId: 2, servicioIds: [1], inicio: DateTime(2026, 10, 24, 10)).esOk,
          isFalse);
      expect(repo.estilistasPara([2, 7]).map((e) => e.id), containsAll([2, 4]));
      expect(repo.estilistasPara([1, 2]).map((e) => e.id), [3]);
    });

    test('franjas: ocupadas, fuera de horario y recálculo al cancelar', () {
      final r = repo.crearTurno(clienteId: 6, estilistaId: 4, servicioIds: [2], inicio: DateTime(2026, 10, 24, 10));
      expect(r.esOk, isTrue);
      List<Franja> fr() => repo.franjas(dia: dia, duracionMin: 60, estilistaId: 4, clienteId: 10);
      Franja f(int h, int m) => fr().firstWhere((x) => x.inicio == DateTime(2026, 10, 24, h, m));
      expect(fr().length, 20);
      expect(f(9, 30).motivo, MotivoFranja.ocupadaEstilista); // 9:30–10:30 pisa 10:00–10:45
      expect(f(10, 30).motivo, MotivoFranja.ocupadaEstilista); // 10:30 < 10:45
      expect(f(11, 0).disponible, isTrue);
      expect(f(18, 30).motivo, MotivoFranja.fueraDeHorario);
      expect(f(18, 0).disponible, isTrue); // termina 19:00 justo
      repo.cancelarTurno(r.valor!.id);
      expect(f(10, 0).disponible, isTrue, reason: 'al cancelar, el horario vuelve a quedar libre');
    });

    test('al editar, el propio turno no cuenta como solape', () {
      final r = repo.crearTurno(clienteId: 6, estilistaId: 4, servicioIds: [2], inicio: DateTime(2026, 10, 24, 10));
      final id = r.valor!.id;
      final e = repo.actualizarTurno(
          turnoId: id, clienteId: 6, estilistaId: 4, servicioIds: [2, 9], inicio: DateTime(2026, 10, 24, 10, 30));
      expect(e.esOk, isTrue, reason: e.error);
      repo.completarTurno(id);
      expect(repo.cancelarTurno(id).esOk, isFalse, reason: 'solo programados');
      expect(
          repo.actualizarTurno(turnoId: id, clienteId: 6, estilistaId: 4, servicioIds: [2], inicio: DateTime(2026, 10, 23, 10))
              .esOk,
          isFalse);
    });
  });

  group('Clientes', () {
    final ahora = DateTime(2026, 10, 20, 8);

    test('teléfono único de 8 dígitos y correo válido', () {
      final repo = SalonRepository.conDatosDePrueba(reloj: () => ahora);
      expect(repo.crearCliente(nombre: 'Al', telefono: '51234567', genero: Genero.hombre).esOk, isFalse);
      expect(repo.crearCliente(nombre: 'Alberto', telefono: '5234', genero: Genero.hombre).esOk, isFalse);
      expect(repo.crearCliente(nombre: 'Alberto', telefono: '52345678', genero: Genero.hombre).esOk, isFalse);
      expect(repo.crearCliente(nombre: 'Alberto', telefono: '51234567', genero: null).esOk, isFalse);
      expect(
          repo.crearCliente(nombre: 'Alberto', telefono: '51234567', genero: Genero.hombre, correo: 'a@b').esOk, isFalse);
      expect(
          repo.crearCliente(nombre: 'Alberto', telefono: '51234567', genero: Genero.hombre, correo: 'a@b.cu').esOk, isTrue);
    });

    test('no se elimina un cliente con turnos programados', () {
      final repo = SalonRepository.conDatosDePrueba(reloj: () => ahora);
      final conProgramados = repo.clientes.firstWhere((c) => repo.programadosDeCliente(c.id).isNotEmpty);
      expect(repo.eliminarCliente(conProgramados.id).esOk, isFalse);
      final sinTurnos = repo.clientes.firstWhere((c) => repo.cantidadTurnosCliente(c.id) == 0);
      expect(repo.eliminarCliente(sinTurnos.id).esOk, isTrue);
    });

    test('búsqueda sin mayúsculas ni acentos combinada con género', () {
      final repo = SalonRepository.conDatosDePrueba(reloj: () => ahora);
      final vm = ClientesViewModel(repo);
      vm.buscar('MARTIN');
      expect(vm.clientes.map((c) => c.nombre), ['Ana Martín']);
      vm.buscar('perez');
      expect(vm.clientes.map((c) => c.nombre), ['Diego Pérez']);
      vm.filtrar(FiltroGenero.mujeres);
      expect(vm.clientes, isEmpty);
      vm.buscar('52 345');
      vm.filtrar(FiltroGenero.todos);
      expect(vm.clientes.map((c) => c.nombre), ['Carlos Ruiz']);
    });
  });

  group('ViewModels', () {
    final ahora = DateTime(2026, 10, 20, 8);

    test('agenda: resumen sin contar cancelados', () {
      final repo = SalonRepository.conDatosDePrueba(reloj: () => ahora);
      final vm = AgendaViewModel(repo);
      final r = vm.resumen;
      final dia = repo.turnosDelDia(vm.fecha);
      final esperado =
          dia.where((t) => t.estado != EstadoTurno.cancelado).fold<int>(0, (s, t) => s + repo.totalDe(t));
      expect(r.ingreso, esperado);
      expect(vm.semana.length, 7);
      expect(vm.semana.first.weekday, DateTime.monday);
    });

    test('formulario: público por género, estilista inválido se limpia y se avisa', () {
      final repo = SalonRepository.conDatosDePrueba(reloj: () => ahora);
      final vm = TurnoFormViewModel(repo, args: const NuevoTurnoArgs(clienteId: 2));
      expect(vm.publico, FiltroPublico.hombres);
      vm.alternarServicio(2); // Corte caballero
      vm.elegirEstilista(2); // Pedro
      vm.alternarServicio(12); // Hidratación: Pedro no la hace
      expect(vm.estilistaId, isNull);
      expect(vm.consumirAviso(), isNotNull);
      expect(vm.estilistasValidos.every((e) => e.realizaTodos(vm.servicioIds)), isTrue);
      expect(vm.hayCambios, isTrue);
      expect(vm.validarFecha(), isNotNull);
      expect(vm.fechaPermitida(DateTime(2026, 10, 25)), isFalse); // domingo
      expect(vm.fechaPermitida(DateTime(2026, 10, 19)), isFalse); // pasado
    });
  });
}
