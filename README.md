# Turco · Gestión de turnos de una peluquería

**Autor:** Manuel
**Asignatura:** Programación para Dispositivos Móviles · Ingeniería Informática, 3er año
**Primer Examen Parcial** · Tecnología: Flutter para Android

Turco es la app que usa la recepción de una peluquería mixta para registrar clientes,
programar turnos con un estilista y llevar la agenda diaria. No usa servidor, base de
datos, almacenamiento local ni autenticación: todo vive en memoria y se carga desde
datos de prueba al iniciar.

---

## Datos del proyecto

| | |
|---|---|
| Nombre visible | **Turco** |
| Application id | `com.manuel.turco` |
| Versión de Flutter | 3.27 o superior (canal stable). Versión usada: _completar con `flutter --version`_ |
| Dart | 3.6 o superior |
| Paquetes | `go_router` (navegación) y `flutter_localizations` (SDK). Sin paquetes de estado ni de almacenamiento. |
| Fuente | Poppins (incluida en `assets/fonts`) |
| Iconos | Lucide, los mismos del diseño, empaquetados como fuente propia (`assets/fonts/Lucide.ttf`) |

> Si el profesor exige nombre **y primer apellido** en el id (por ejemplo `com.manuelperez.turco`),
> cambiar `com.manuel.turco` en `android/app/build.gradle.kts` (`namespace` y `applicationId`)
> y mover `MainActivity.kt` a la carpeta del nuevo paquete, actualizando su línea `package`.

## Cómo inicializar y ejecutar

1. Instalar Flutter (stable) y Android Studio con los plugins **Flutter** y **Dart**.
2. Clonar el repositorio y abrir la carpeta en Android Studio (*File › Open*).
3. Descargar dependencias:
   ```bash
   flutter pub get
   ```
4. Iniciar un emulador o conectar un teléfono Android y ejecutar:
   ```bash
   flutter run
   ```
   (o el botón *Run* de Android Studio).
5. Pruebas de las reglas de negocio:
   ```bash
   flutter test
   ```

Si Gradle no sincroniza por la versión del SDK de Android instalada, ejecutar una vez
`flutter doctor --android-licenses` y volver a sincronizar.

## Cómo generar el APK release

```bash
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Copiarlo a `entrega/`
y publicarlo en *Releases* de GitHub. El release se firma con la llave de depuración para
poder instalarlo directamente; no se sube ninguna llave al repositorio.

## Arquitectura (MVVM)

- **Modelos** (`lib/data/models`): `Servicio`, `Estilista`, `Cliente`, `Turno`, enumeraciones y horario.
- **Modelo de datos / reglas** (`lib/data/repositories/salon_repository.dart`): `ChangeNotifier` con
  los datos en memoria y todas las reglas de negocio (solapes, franjas libres, duración y precio
  calculados, horario 9:00–19:00 de lunes a sábado, teléfono único, eliminación de clientes).
- **ViewModels** (`lib/viewmodels`): un `ChangeNotifier` por pantalla. Los de las pestañas viven toda
  la sesión, por eso cada destino conserva búsqueda, filtros y fecha.
- **Vistas** (`lib/views`): solo pintan y delegan; escuchan a su ViewModel con `ListenableBuilder`.
- **Widgets reutilizables** (`lib/widgets`): campos de formulario, chips de estado, avatares, diálogos.
- **Tema** (`lib/core/theme`): tema global claro y oscuro Material 3 con Poppins; radios y espacios en
  una `ThemeExtension`. Ningún widget usa colores fijos: todo sale del `ColorScheme`.

### Paleta

El diseño original usa la semilla `0xFF00695C` (verde azulado). En esta versión se mantuvo la misma
estructura tonal de Material 3 (mismos roles: primary, primaryContainer, secondaryContainer,
tertiary, error, surface…) pero con una semilla **azul acero `0xFF1F4E6E`** y un terciario
**bronce**, para un aspecto más sobrio. Los valores están en `lib/core/theme/app_colors.dart`.

## Navegación (go_router)

`StatefulShellRoute.indexedStack` con `NavigationBar` de cuatro destinos. Detalle y formulario se
abren por encima de la barra con `parentNavigatorKey`.

| Ruta | Pantalla | Mecanismo |
|---|---|---|
| `/agenda` | Agenda (inicial) | `?estilista=3` (queryParameters) |
| `/clientes` | Clientes | |
| `/servicios` | Servicios | |
| `/estilistas` | Estilistas | |
| `/turno/nuevo` | Formulario (crear) | datos iniciales con `extra` |
| `/turno/:id` | Detalle de turno | `pathParameters` |
| `/turno/:id/editar` | Formulario (editar) | `pathParameters` |

El formulario devuelve el turno guardado con `context.pop(valor)`; la Agenda muestra un SnackBar y
se ubica en la fecha del turno.

## Estructura de carpetas

```
turco/
├── android/                    Proyecto Android (application id com.manuel.turco, nombre Turco)
├── assets/
│   ├── fonts/                  Poppins (400, 500, 600, 700) y Lucide (iconos)
│   └── images/
│       ├── logo.png
│       ├── categorias/         Imagen de cada categoría (corte, color, barba, peinado, tratamiento)
│       ├── estilistas/         Avatares de los estilistas
│       └── ilustraciones/      Ilustraciones de listas vacías y "no encontrado"
├── capturas/                   Capturas reales de la app
├── entrega/                    APK release
├── lib/
│   ├── main.dart               MaterialApp.router, tema y localización
│   ├── app_dependencies.dart   Creación del modelo y los ViewModels
│   ├── core/
│   │   ├── theme/              Colores, tema, tokens e iconos
│   │   └── utils/              Formato de fechas, dinero, teléfono y texto
│   ├── data/
│   │   ├── models/             Entidades y reglas simples
│   │   ├── repositories/       SalonRepository (datos en memoria + reglas de negocio)
│   │   └── seed/               Datos de prueba calculados desde DateTime.now()
│   ├── router/                 Rutas de go_router
│   ├── viewmodels/             ViewModels (ChangeNotifier)
│   ├── views/                  Pantallas: agenda, turno, clientes, servicios, estilistas, shell
│   └── widgets/                Widgets reutilizables
├── test/                       Pruebas de reglas de negocio y datos de prueba
├── analysis_options.yaml
└── pubspec.yaml
```

## Datos de prueba

13 servicios en 5 categorías (4 solo mujeres, 5 solo hombres, 4 unisex), 5 estilistas (Marta solo
mujeres, Pedro solo hombres, Lucía ambos, Rafael sin turnos hoy, Elena), 10 clientes (5 y 5; Javier y
Andrés sin turnos) y 16 turnos en siete días laborables alrededor de hoy (6 hoy). Los pasados quedan
completados o cancelados y los futuros programados; hay un turno con 3 servicios, uno sin notas, uno
con notas de más de 300 caracteres y uno que termina exactamente a las 19:00. Si la app se abre un
domingo (salón cerrado), el "hoy" de los datos y de la Agenda es el lunes siguiente.
