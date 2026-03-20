#import "@preview/unify:0.7.1": num, numrange, qty, qtyrange
#import "@preview/physica:0.9.8": *
#import "@preview/t4t:0.4.3": get, is-arr, is-func, is-str
#set text(lang: "es")
#let longitud-abstract = 150
#let longitud-abstract-caracteres = 1100

// Adds period at the end if not already present.
#let with-period(body) = body + if get.text(body).trim().last() != "." [.]

// Reimplements `figure` caption with custom styling.
#let new-caption(it, body) = block({
  strong(it.supplement)
  if it.numbering != none { [~] + it.counter.display(it.numbering) }
  it.separator
  emph(body)
})

// Returns (caption data, true), or (`otherwise` content, false).
#let get-caption-data(it, otherwise) = {
  let sequence = [].func()
  if type(otherwise) != function { otherwise = it => otherwise }
  if it.body.func() != sequence or it.body.children.len() == 0 {
    return (otherwise(it), false)
  }
  let data = it.body.children.last()
  if data.func() != metadata { return otherwise(it) }
  return (data.value, true)
}

// `figure` caption with optional `source` argument.
#let caption(description, ..source) = {
  if source.pos().len() == 0 { return description }
  source = source.pos().first()
  source = [Fuente: #source]
  description
  [ ]
  metadata((
    description: with-period(description),
    source: with-period(source),
  ))
}
#let azulunir = rgb("#0098cd")
#let anejos(body) = {
  pagebreak()
  set heading(numbering: "A.1", supplement: [Anejo])
  counter(heading).update(0)
  show heading: it => {
    assert.eq(it.level, 1, message: "Un anejo no debe tener estructura!")
    v(20%)
    set text(azulunir, weight: "light", size: 20pt)
    [#it.supplement #counter(heading).display():]
    h(0.3em)
    it.body
    linebreak()
  }
  body
}

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
  assert(get.text(resumen).len() <= longitud-abstract-caracteres, message: "Resumen demasiado largo!")
  assert(get.text(abstract).len() <= longitud-abstract-caracteres, message: "Abstract demasiado largo!")
  assert(get.text(titulo).len() > 0, message: "Falt el título del TFG!")
  if is-arr(alumno) { alumno = alumno.join(", ").rev().replace(" ,", " y ", count: 1).rev() }
  if is-arr(director) { director = director.join(", ").rev().replace(" ,", " y ", count: 1).rev() }
  assert(get.text(alumno).len() > 0, message: "Falta tu nombre!")
  assert(get.text(director).len() > 0, message: "Falta el director!")

  if is-arr(pclave) { pclave = pclave.join(", ") + "." }
  if is-arr(kwords) { kwords = kwords.join(", ") + "." }

  set page(
    paper: "a4",
    margin: (left: 3cm, right: 2cm),
    footer: none,
  )
  set text(font: "calibri", size: 12.5pt, lang: "es")
  set par(linebreaks: "optimized", justify: true, spacing: 1.8em, leading: 1.2em)


  show link: it => {
    if not (it.body.text.contains(it.dest)) {
      text(fill: azulunir, underline(it))
    } else { text(fill: azulunir, font: "IBM Plex Mono", size: 10pt, underline(it), tracking: -.4pt) }
  }

  /*
   * Estilo de los captions de las figuras/tablas flotantes
   */
  show table.cell: set par(leading: 0.2cm)
  show figure: set figure(placement: none)
  show figure: set figure.caption(separator: ". ")
  show figure: set figure(gap: 1em)
  show figure.caption: emph
  show figure.where(kind: table): set block(breakable: true)
  show figure: it => {
    let sequence = [].func()
    {
      set block(below: it.gap, sticky: true)
      show figure.caption: set align(left)
      show figure.caption: it => {
        let (result, ok) = get-caption-data.with(it)(
          it => new-caption(it, with-period(it.body)),
        )
        if not ok { return result }
        new-caption(it, result.description)
      }
      it.caption
    }
    show figure.caption: set text(black.lighten(30%))
    show figure.caption: it => {
      let (result, ok) = get-caption-data(it, none)
      if not ok { return result }
      set par(leading: 0.2cm)
      block(result.source)
    }
    it
  }

  set math.equation(numbering: "(1)")

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
  show heading.where(level: 3): it => {
    set text(weight: "light", style: "normal", size: 12.5pt)
    it
    v(.3cm)
  }
  show heading: it => {
    if it.level > 3 { panic("No se permiten títulos de sección de 4o nivel!") }
    set block(above: 3em, below: 1em, sticky: true)
    set par(leading: 0.6em)
    it
  }

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
      #set table.cell(align: horizon)
      #table(
        columns: (1fr, 1fr),
        stroke: 0.1pt,
        align: left,
        table.header[Trabajo de fin de estudio presentado por: ][#alumno],
        [Director/a/es:], [#director],
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
    #linebreak()
    #resumen #linebreak()
    #text(weight: "bold")[Palabras clave:]
    #pclave
  ]
  align(bottom)[
    #text(fill: azulunir, size: 18pt)[Abstract]
    #linebreak()
    #abstract #linebreak()
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
