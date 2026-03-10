#import "@preview/unify:0.7.1": num, numrange, qty, qtyrange
#import "@preview/physica:0.9.8": *
#set text(lang: "es")
#let longitud-abstract = 138
#let unirfisica(
  titulo: "Título de mi TFG",
  alumno: "Mi nombre",
  director: "Nombre de mi director",
  resumen: lorem(longitud-abstract),
  abstract: lorem(longitud-abstract),
  pclave: lorem(6).replace(" ", ", ").replace(",,", ","),
  kwords: lorem(6).replace(" ", ", ").replace(",,", ","),
  logo: image("unir logo.svg", width: 60%),
  agradecimientos: quote(attribution: [Plato], block: true)[#lorem(20)],
  doc,
) = {
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 2cm),
    footer: none,
  )
  set text(font: "calibri", size: 12.5pt, lang: "es")
  set par(linebreaks: "optimized", justify: true, spacing: 1.8em, leading: 1.2em)
  let azulunir = rgb("#0098cd")

  show link: it => {
    if not (it.body.text.contains(it.dest)) {
      text(fill: azulunir, underline(it))
    } else { text(fill: azulunir, font: "IBM Plex Mono", size: 10.2pt, underline(it)) }
  }

  /*
   * Estilo de los captions de las figuras/tablas flotantes
   */

  show figure: set figure.caption(separator: ". ")
  show figure: set figure(gap: 1em)
  show figure.caption: emph

  show figure: it => {
    let sup = it.caption.supplement.text
    let sup-and-num = sup + "\\s\\d+\\.\\s+"
    let first-part = sup + "([^.]+\\.){2}"
    let keep-first-part(doc) = {
      show regex(sup + ".+"): it => {
        it.text.match(regex(first-part)).text
      }

      doc
    }
    let remove-first-part(doc) = {
      show regex(sup + ".+"): it => {
        it.text.replace(regex(first-part + "\\s*"), "")
      }
      set text(fill: gray.darken(50%))
      doc
    }
    {
      set align(left)
      set block(below: it.gap)
      show ref: none
      show sup: strong
      show regex(sup-and-num): emph
      show: keep-first-part
      it.caption
    }
    show figure.caption: emph
    show figure.caption: it => {
      show: remove-first-part
      it
    }
    it
  }

  set math.equation(numbering: "(1)")


  /*
    Longitur del abstract de ejemplo
  */
  let longitud_abstract = 130

  /*
  Estilo de los títulos de cabecera de nivel 1 (sección )
  */
  set heading(numbering: "1.")

  show heading.where(level: 1): it => {
    pagebreak()
    v(20%)
    set text(azulunir, weight: "light", size: 20pt)
    it
  }
  show heading.where(level: 2): set text(azulunir, weight: "light", size: 15pt)
  show heading: set block(above: 3em, below: 1em, sticky: true)


  /*
  Definición de la portada
  */

  align(center)[
    #logo

    #text(font: "calibri", size: 24pt)[Universidad Internacional de La Rioja (UNIR)
    ]

    #v(-10pt)
    #text(font: "calibri", size: 20pt)[Escuela Superior de Ingeniería y Tecnología]

    /*
    Nombre del estudio y título del trabajo
    */
    #align(center + horizon)[
      #text(size: 18pt)[Grado en Física]
      #v(-10pt)
      #text(size: 26pt, fill: azulunir, weight: "bold")[#titulo]
    ]

    #let fecha = datetime.today()

    /*
     Tabla inferior con los datos del TFG
    */
    #align(center + bottom)[
      #table(
        columns: (1fr, 1fr),
        stroke: 0.1pt,
        align: left,
        table.header[Trabajo de fin de estudio presentado por: ][#alumno],
        [Director/a:], [#director],
        [Fecha:], [#fecha.display()],
      )
    ]
  ]


  if (agradecimientos != none) {
    if (
      agradecimientos.func() == quote and agradecimientos.has("attribution") and agradecimientos.attribution == [Plato]
    ) [] else [
      #pagebreak()
      #align(center + horizon, text(size: 18pt, [#agradecimientos]))
    ]
  }

  pagebreak()

  align(top)[
    #text(fill: azulunir, size: 18pt, weight: "regular", font: "calibri")[Resumen]

    #resumen

    #text(weight: "bold")[Palabras clave:]
    #pclave
  ]
  align(bottom)[
    #text(fill: azulunir, size: 18pt)[Abstract]

    #abstract

    #text(weight: "bold")[Keywords]:
    #kwords
  ]


  outline(title: "Índice de contenidos")
  set page(
    footer: context [
      #set align(right)
      #text(13pt, fill: gray.darken(30%))[#counter(page).display()]
    ],
    header: [
      #set text(size: 10pt, weight: "extralight", fill: gray.darken(30%))
      #align(right)[
        #alumno
        #v(-1.2em)
        #titulo
      ]
    ],
  )
  counter(page).update(1)
  doc
}
