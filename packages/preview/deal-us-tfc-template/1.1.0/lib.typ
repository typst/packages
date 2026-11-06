// Definiciones de dimensiones
#import "/etc/variables.typ": *

#let TFC(
  tipo: none,
  contenido-portada: none,
  titulo: "Título del Trabajo",
  alumno: "Nombre del Alumno",
  titulacion: "Grado en Ingeniería Informática - Ingeniería del Software",
  director: "Nombre del profesor tutor",
  departamento: "Lenguajes y Sistemas Informáticos",
  convocatoria: "Convocatoria de junio/julio/diciembre, curso 20XX/YY",
  dedicatoria: "Aquí la dedicatoria del trabajo",
  agradecimientos: [
    Quiero agradecer a X por...

    También quiero agradecer a Y por...
  ],
  resumen: [Incluya aquí un resumen de los aspectos generales de su trabajo, en español],
  palabras-clave: ("palabra clave 1", "palabra clave 2", "...", "palabra clave N"),
  abstract: [This section should contain an English version of the Spanish abstract.],
  keywords: ("keyword 1", "keyword 2", "...", "keyword N"),
  portada-ingles: false,
  secciones-ingles: false,
  margen-externo: 2.75cm,
  margen-interno: 2.75cm,
  font: "Libertinus Sans",
  color-principal: rgb("#8c2437"),
  color-secundario: rgb("#fff1c8"),
  incluye-secciones-encabezados: true,
  bibliografia: [],
  doc,
) = [

  #import "@preview/outrageous:0.4.0"
  #import "@preview/codly:1.3.0": *
  #import "@preview/codly-languages:0.1.1": *
  #import "@preview/hydra:0.6.2": anchor, hydra

  #show: codly-init.with()
  #codly(zebra-fill: rgb(250, 250, 250), languages: codly-languages)

  #set text(lang: if secciones-ingles { "en" } else { "es" }, size: 13pt, font: font, hyphenate: false)
  #set list(indent: 0.75cm, spacing: 0.95em)
  #set enum(indent: 0.45cm, spacing: 0.95em)

  // Numerado como Capitulo.contador
  #set math.equation(numbering: it => numbering("(1.1)", counter(heading).get().at(0), it))
  #set figure(numbering: it => numbering("1.1", counter(heading).get().at(0), it))

  #set outline(depth: 3)
  #set page(margin: margen-externo)
  #set par(
    first-line-indent: (amount: 0.75cm, all: false),
    justify: true,
    justification-limits: (tracking: (min: -0.02em, max: 0.02em)),
  )

  // Portada
  #[
    #set align(center)
    #v(2cm)
    #block(
      fill: color-secundario,
      width: 100%,
      inset: (y: 1cm),
      stroke: (top: 3pt + color-principal, bottom: 3pt + color-principal),
    )[
      #set text(fill: color-principal)

      #[#set text(size: large)
        #if tipo != none {
          tipo
        } else {
          if portada-ingles { "FINAL DEGREE PROJECT" } else { "TRABAJO FIN DE GRADO" }
        }]
      #v(-0.1in)

      #[#set text(size: huge)
        *#titulo*]
      #v(-0.5cm)

      *\*\*\**

      #[#set text(size: large)
        #if portada-ingles { "Presented by" } else { "Realizado por" } \ ]
      #[#set text(size: very-large)
        *#alumno*]
    ]
  ]
  #if contenido-portada != none {
    contenido-portada
    pagebreak()
    pagebreak()
  } else {
    v(2cm)
  }

  // Metadatos
  #[
    #set align(center + horizon)

    *#if portada-ingles { "For the degree of" } else { "Para la obtención del título de" }*\
    #[#set text(size: large)
      #titulacion]
    #v(0.2in)

    *#if portada-ingles { "Directed by" } else { "Dirigido por" }*\
    #[#set text(size: large)
      #director]
    #v(0.2in)

    *#if portada-ingles { "In the department of" } else { "En el departamento de" }*\
    #[#set text(size: large)
      #departamento]
    #v(0.6in)

    #[#set text(size: very-large)
      *#convocatoria*]

    #v(1cm)
    #image("/etsii_us.png")
    #v(3cm)
  ]

  #if contenido-portada == none {
    pagebreak()
  }

  // Dedicatoria

  #pagebreak()
  #place(center + horizon)[_#dedicatoria _]
  #pagebreak()

  #set page(numbering: "I")
  #counter(page).update(1)

  // Estilos de encabezados: tamaños, espacios, etc. Y reseteo de contadores

  #show heading.where(level: 1): it => {
    counter(figure).update(0)
    counter(math.equation).update(0)
    pagebreak(weak: true)
    set align(right)
    set text(size: 24pt, fill: color-principal, weight: "bold")
    v(3cm)
    it.body
    v(-0.6cm)
    line(length: 100%, stroke: stroke(thickness: 3pt, paint: color-principal, cap: "round"))
    v(2cm)
  }

  #show heading.where(level: 2, outlined: true): it => {
    set text(size: very-large)
    block(above: 1.2cm, below: 1cm)[
      #counter(heading).display();
      #h(0.5em)
      #it.body
    ]
  }

  #show heading.where(level: 3, outlined: true): it => {
    set text(size: large)
    block(above: 1.2cm, below: 0.75cm)[
      #counter(heading).display();
      #h(0.5em)
      #it.body
    ]
  }

  #show heading.where(level: 4): it => {
    set text(size: regular)
    block(above: 1.2cm, below: 0.75cm)[
      #it.body
    ]
  }

  #show heading: it => {
    set par(first-line-indent: 0pt)
    it
  }

  // Estilo de tabla de contenidos para el paquete outrageous

  #let presets = (
    outrageous-toc: (
      ..outrageous.presets.typst,
      prefix-transform: (level, prefix) => {
        // Eliminar el '.' después del número
        if level == 1 {
          if prefix == none {
            [#prefix]
          } else {
            [#prefix.text.slice(0, -1)#h(5pt)]
          }
        }
      },
      fill: (repeat(".", gap: 5pt), repeat(".", gap: 5pt)),
    ),
    outrageous-figures: (
      ..outrageous.presets.typst,
      prefix-transform: (level, prefix) => {
        [#prefix.children.at(2)]
      },
      vspace: (none, none),
      fill: (repeat(".", gap: 5pt), repeat(".", gap: 5pt)),
    ),
    typst: (),
  )

  #show outline.entry: outrageous.show-entry.with(
    ..presets.outrageous-toc,
  )

  // Primer nivel en la tabla de contenidos más grande y negrita

  #show outline.entry.where(level: 1): it => {
    set text(weight: "bold", size: large)
    block(above: 18pt)[#it]
  }

  // Estilo de referencias. Incluyendo un enlace azul en el caso de las figuras y ecuaciones

  #show ref: it => {
    // Figuras, equaciones y encabezados
    if it.element != none and it.element.func() in (figure, math.equation, heading) {
      link(locate(it.target))[
        #it]
      // Todo lo demás (bibliografía)
    } else {
      it
    }
  }

  // Estilo de caption

  #show figure.caption: it => context {
    v(1.5mm)
    [*#it.supplement #it.counter.display()#it.separator*#it.body]
    v(3mm)
  }

  // Secciones que no aparecen en la tabla de contenido

  #set heading(outlined: false)

  #let is-odd-page() = calc.rem(counter(page).get().first(), 2) == 1
  #let current-heading = state("current-heading", "")

  #set page(header: context {
    box(width: 100%, [
      #let contenido
      #let posicion
      #let page-heading = hydra(use-last: true, skip-starting: false, 1)
      #let is-title = false
      #if (page-heading != current-heading.get()) {
        // Actualizar el encabezado actual
        [#current-heading.update(page-heading)]
        is-title = true
      }
      #if not is-title {
        if is-odd-page() {
          posicion = left
          contenido = page-heading
        } else {
          posicion = right
          contenido = hydra(skip-starting: false, 2)
        }
        place(left + horizon, line(start: (-5cm, 0cm), end: (100% + 5cm, 0cm), stroke: 3pt + color-secundario))
        place(posicion + horizon, box(outset: 2mm, radius: 1cm, fill: color-secundario, text(
          size: 12pt,
          fill: color-principal,
          style: "italic",
          contenido,
        )))
      }
    ])
  }) if incluye-secciones-encabezados


  #set page(
    margin: (outside: margen-externo, inside: margen-interno),
    numbering: "I",
    footer: context {
      box(width: 100%, [
        #let contenido = [#counter(page).display()]
        #let posicion
        #place(left + horizon, line(start: (-5cm, 0cm), end: (100% + 5cm, 0cm), stroke: 3pt + color-secundario))
        #if is-odd-page() {
          posicion = left
        } else {
          posicion = right
        }
        #place(posicion + horizon, box(outset: 2mm, radius: 1cm, fill: color-secundario, text(
          size: 12pt,
          fill: color-principal,
          contenido,
        )))
      ])
    },
  )

  = #if secciones-ingles { "Acknowledgements" } else { "Agradecimientos" }

  #agradecimientos

  = Resumen
  #resumen

  #v(.5cm)

  *Palabras clave:* #palabras-clave.join(", ")

  = Abstract
  #abstract

  #v(.5cm)

  *Keywords:* #keywords.join(", ")

  #outline(title: if secciones-ingles { "Table of contents" } else { "Índice general" })

  // Estilos para outlines secundarias

  #show outline.entry: outrageous.show-entry.with(
    ..presets.outrageous-figures,
  )

  #show outline.entry.where(level: 1): it => {
    let level = counter(heading).at(it.element.location()).at(0)
    block(above: 6pt)[
      #link(it.element.location())[
        #level.#it.element.counter.at(it.element.location()).at(0).#h(5pt) #it.body()
        #box(width: 1fr, repeat(".", gap: 5pt)) #it.page()
      ]
    ]
  }

  #outline(
    title: if secciones-ingles { "List of figures" } else { "Índice de figuras" },
    target: figure.where(kind: image),
  )
  #outline(
    title: if secciones-ingles { "List of tables" } else { "Índice de tablas" },
    target: figure.where(kind: table),
  )
  #outline(
    title: if secciones-ingles { "List of code extracts" } else { "Índice de extractos de código" },
    target: figure.where(kind: raw),
  )

  // Cambio ahora para que la bibliografía no sea azul

  #show link: it => {
    set text(fill: rgb("#0000ff"))
    it
  }

  #set page(numbering: "1")
  #counter(page).update(1)

  #set heading(outlined: true, numbering: "1.")

  // Aquí comienza el documento normal

  // Encabezados de nivel 1 para secciones principales
  #show heading.where(level: 1): it => {
    pagebreak()
    set align(center)
    set text(size: 24pt, fill: color-principal, weight: "bold", hyphenate: false)
    set par(justify: false)
    v(5cm)
    block(width: 100%, inset: 1cm, stroke: (top: 3pt + color-principal, bottom: 3pt + color-principal))[
      // Número de laboratorio en la esquina superior derecha
      #place(top + right, dy: -1.5cm, box(
        height: 1cm,
        stroke: 1pt + color-principal,
        fill: white,
        radius: 5cm,
        inset: (x: 0.5cm),
        align(center + horizon, [Capítulo #counter(heading).get().at(0)]),
      ))
      // Título centrado
      #it.body
    ]
    v(3cm)
  }

  #doc

  // Vuelta a la normalidad para la bibliografía

  #show heading.where(level: 1): it => {
    counter(figure).update(0)
    counter(math.equation).update(0)
    pagebreak(weak: true)
    set align(right)
    set text(size: 24pt, fill: color-principal, weight: "bold")
    v(3cm)
    it.body
    v(-0.6cm)
    line(length: 100%, stroke: stroke(thickness: 3pt, paint: color-principal, cap: "round"))
    v(2cm)
  }

  #bibliografia

]
