# Complete UNSAAC

<p align="center"><em>
  Unofficial collection of Typst templates for academic
  documents at the Universidad Nacional de San Antonio Abad del Cusco.
</em></p>

Coleccion no oficial de plantillas [Typst](https://typst.app/) para
documentos academicos de la Universidad Nacional de San Antonio Abad del Cusco
(UNSAAC). Incluye plantillas para tesis, prácticas pre-profesionales,
diapositivas y tareas.

Todas las funciones a ser utilizadas como _show rule_ comienzan con `doc-` y
tambien se provee funciones auxiliares simples:

- `src-block`: Bloque estilizado para `raw`
- `src-file`: Mismo que `src-block` pero acepta la ruta de un archivo
- `get-mes`: Obtener el mes de un objeto `datetime` en español
- `fecha-str`: Obtener una cuerda formateada en español
- `definicion`, `teorema`, `corolario`: Custom `figures` para mostrar eso mismo

## Tesis / Plan de tesis / Trabajo de Investigación

Basada en la
[plantilla de overleaf](https://www.overleaf.com/latex/templates/plantilla-tesis-unsaac/psghqhfpnhpm).

```typst
#import "@preview/complete-unsaac:0.2.3": doc-tesis

#show: doc-tesis.with(
  titulo: [Titulo del trabajo de Tesis],
  asesor: [Nombre completo Asesor],
  co-asesor: [Nombre completo Co-Asesor],
  autores: (
    "Nombre Completo Autor 1",
    "Nombre Completo Autor 2",
  ),
  // titulo-documento: upper[Trabajo de investigación],
  // titulo-academico-label: [Para optar al Grado Académico de],
  // titulo-academico: [Bachiller en Ingeniería],
  // facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  // escuela: [Ingeniería Informática y de Sistemas],
  // duplex: true,       // activa márgenes para impresión doble cara
  // binding-margin: 2%, // margen extra en el lado de encuadernado
)
```

## Prácticas pre-profesionales
Estas dos plantillas tienen la ventaja de que no tienes que especificar otra
fecha mas que la fecha inicial de tus practicas. Siguiendo el formato de la
lista de `actividades` la plantilla ya calcula la fecha de inicio y la fecha
final de cada actividad automaticamente (ignorando fines de semana y feriados).

### Plan de prácticas

```typst
#import "@preview/complete-unsaac:0.2.3": doc-practica-plan-actividades, actividades-tabla

#show: doc-practica-plan-actividades.with(
  titulo: [Plan de Prácticas Pre Profesionales],
  autor: [Nombre Completo Autor],
  codigo: 100001,
  asesor: [Nombre completo Asesor],
  empresa: [Nombre de la empresa],
  jefe: [Nombre del jefe inmediato],
  area: [Soporte y tecnología de la información],
  fecha-inicio: datetime(day: 02, month: 01, year: 2001),
  horario: [Lunes a viernes, 09:00 – 13:00 hrs y 18:00 – 20:00],
  horas-por-dia: 6,
  actividades: (
    (
      nombre: [Nombre de la actividad],
      descripcion: [Descripcion de la actividad],
      duracion: 30,
    ),
  ),
  // facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  // escuela: [Ingeniería Informática y de Sistemas],
  // escuela-logo: image("logo.png"),
)

#actividades-tabla()
```

### Informe parcial

```typst
#import "@preview/complete-unsaac:0.2.3": doc-practica-informe-parcial, actividades-contenidos, actividades-gantt

#show: doc-practica-informe-parcial.with(
  titulo: [Informe $N degree$ 01 - Prácticas Pre Profesionales],
  autor: [Nombre Completo Autor],
  codigo: 100001,
  asesor: [Nombre completo Asesor],
  empresa: [Nombre de la empresa],
  jefe: [Nombre del jefe inmediato],
  area: [Soporte y tecnología de la información],
  fecha-inicio: datetime(day: 03, month: 03, year: 2003),
  horas-por-dia: 6,
  actividades: (
    (
      nombre: [Nombre de la actividad],
      contenido: [
        Contenido de la actividad desarrollada

        #lorem(30)

        + #lorem(10)
        + #lorem(10)
        + #lorem(10)
      ],
      gantt: (
        (nombre: [Subtarea 1]),
        (nombre: [Subtarea 2]),
        (nombre: [Subtarea 3]),
      ),
      duracion: 30,
    ),
  ),
  // facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  // escuela: [Ingeniería Informática y de Sistemas],
  // escuela-logo: image("logo.png"),
  // duplex: true,
  // binding-margin: 5%,
)

#actividades-gantt()
#actividades-contenidos()
```

## Tareas
````typst
#import "@preview/complete-unsaac:0.2.3": doc-tarea

#show: doc-tarea.with(
  titulo: [Laboratorio 01: Nombre de la tarea],
  curso: [Nombre del Curso],
  docente: [Nombre Completo Docente],
  autores: (
    (
      nombre: "Nombre Completo Autor 1",
      codigo: "100001",
    ),
    (
      nombre: "Nombre Completo Autor 2",
      codigo: "200002",
    ),
  ),
  // facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  // escuela: [Ingeniería Informática y de Sistemas],
  // escuela-logo: image("logo.png"),
  // duplex: true,
  // binding-margin: 2%,
)
````

## Diapositivas

Basado en [Touying](https://typst.app/universe/package/touying). Para opciones
avanzadas de personalización, consulta su
[documentación oficial](https://touying-typ.github.io/docs/reference).

```typst
#import "@preview/complete-unsaac:0.2.3": diapo-funcs
#import diapo-funcs: *

#show: doc-diapo.with(
  titulo: [Titulo de la presentacion],
  subtitulo: [Subtitulo],
  curso: [Nombre del Curso],
  docente: [Nombre Completo Docente],
  autores: (
    (
      nombre: "Nombre Completo Autor 1",
      codigo: "100001",
    ),
    (
      nombre: "Nombre Completo Autor 2",
      codigo: "200002",
    ),
  ),
  // facultad: [Ingeniería Eléctrica, Electrónica, Informática y Mecánica],
  // escuela: [Ingeniería Informática y de Sistemas],
  // escuela-logo: image("logo.png"),
)
```

## License
Code is licensed under [MIT](LICENSE). The UNSAAC logos are property of the
Universidad Nacional de San Antonio Abad del Cusco and are not covered by this
license.
