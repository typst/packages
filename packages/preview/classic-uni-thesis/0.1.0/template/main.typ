// ============================================================================
//  Tesis de Pregrado — documento principal
//
//  Compilar con:   typst compile main.typ
//  Vista previa:   typst watch main.typ
//
//  Este archivo conecta el material preliminar + capítulos + material final a
//  través de la plantilla `classic-uni-thesis`. Reemplaza el contenido de
//  ejemplo por el tuyo; el orden de las secciones lo fija la plantilla, así que
//  solo editas contenido aquí (y en los archivos de chapters/).
// ============================================================================

#import "@preview/classic-uni-thesis:0.1.0": abbrev-table, flex-caption, thesis

#show: thesis.with(
  // ---- metadatos ----
  titulo: "Título de la Tesis",
  // subtitulo: "Subtítulo de Tesis", (opcional)
  autor: "Nombre Apellido",
  tipo-tesis: "Tesis de Pregrado",
  programa: "Escuela Profesional de Ciencias de la Computación",
  facultad: "Facultad de Ciencias",
  asesor: "Dr. Nombre Apellido",
  ubicacion: "Lima",
  fecha: datetime(day: 12, month: 9, year: 2026),

  // ---- material preliminar ----
  certificate: [
    #v(1fr)
    #align(center)[#text(size: 18pt, weight: "bold")[Certificado de Dirección]]
    #v(1.2cm)

    *Dr. Nombre Apellido*, en calidad de Asesor, certifica que la presente tesis
    titulada "*Título de la Tesis*", ha sido desarrollada por *Nombre Apellido*
    bajo su dirección y cumple con los requisitos para ser presentada y
    sustentada para optar el título profesional de Ciencias de la Computación.

    #v(0.4cm)
    Lima, 12 de septiembre de 2026
    #v(1.4cm)

    #align(center)[
      #table(
        columns: 12cm,
        rows: (auto, 2.6cm, auto, 2.6cm),
        // la línea de firma es la regla inferior de las filas altas (índices impares)
        stroke: (x, y) => if calc.odd(y) { (bottom: 0.6pt + black) } else { none },
        align: left + horizon,
        inset: (x: 0pt, top: 16pt, bottom: 4pt),
        [*Asesor* #h(0.6em) #text(size: 10pt, fill: luma(110))[Dr. Nombre Apellido]], [],
        [*Autor* #h(0.6em) #text(size: 10pt, fill: luma(110))[Nombre Apellido]], [],
      )
    ]
    #v(1fr)
  ],

  agradecimientos: [
    Usa esta sección para agradecer a las personas e instituciones que apoyaron
    tu trabajo: tu asesor y tutor, tu grupo de investigación o departamento, las
    entidades financiadoras y a cualquiera que haya ayudado en el camino.
    Mantenlo cálido pero conciso, unos pocos párrafos cortos son suficientes.

    Un segundo párrafo puede reconocer a tu familia y amigos. Este bloque es
    opcional: pon `agradecimientos: none` en `main.typ` para omitirlo por
    completo.
  ],

  abstract: [
    El resumen es un compendio autónomo de toda la tesis, normalmente entre 200 y
    350 palabras. Expón el problema y su contexto, lo que hiciste, los resultados
    principales y por qué importan, en un pasaje único y continuo que un lector
    pueda entender sin el resto del documento.

    Abre con la motivación y el vacío que aborda tu trabajo. Luego describe tu
    enfoque a alto nivel, lo suficiente para que el lector comprenda el método
    sin el detalle del capítulo de Metodología. Cierra con tus hallazgos
    principales, expresados de forma concreta, y una oración sobre su
    importancia. Evita citas, abreviaturas sin definir y figuras aquí; el resumen
    debe sostenerse por sí solo.
  ],
  keywords: [palabra uno, palabra dos, palabra tres],

  // Lista de Abreviaciones (opcional): pares (corto, largo).
  abreviaciones: (
    ("DNA", "Ácido desoxirribonucleico"),
    ("API", "Interfaz de programación de aplicaciones"),
  ),

  // ---- interruptores (todos activados por defecto) ----
  mostrar-tdc: true,
  mostrar-lista-figuras: true,
  show-lista-tablas: true,
  numeracion-encabezados: true,

  // ---- material final ----
  bibliografia: bibliography("references.bib", style: "apa"),
  apendices: include "chapters/05-appendix.typ",
)

// ---- capítulos del cuerpo principal (numeración arábiga) ----
#include "chapters/01-introduction.typ"
#include "chapters/02-methodology.typ"
#include "chapters/03-results.typ"
#include "chapters/04-discussion.typ"
