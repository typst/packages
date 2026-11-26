// =====================================================================
// plantilla.typ — Plantilla de tesis de Maestría / Doctorado
// Universidad Nacional de Ingeniería · Unidad de Posgrado
// ---------------------------------------------------------------------
// Versión Typst de la plantilla LaTeX del Grupo de Estudio de
// Inferencia Causal UNI Perú, rediseñada con criterio editorial:
// composición clásica de libro, aperturas de capítulo, entornos
// matemáticos con numeración compartida, cabeceras vivas, tablas al
// estilo «booktabs» y bibliografía APA.
//
// Uso (en tesis.typ):
//   #import "plantilla.typ": *
//   #show: tesis.with(meta)
//   #portada(meta)
//   #show: frontmatter     … preliminares (numeración romana)
//   #show: mainmatter      … cuerpo (numeración arábiga)
//   #show: apendices       … apéndices (numeración A, B, …)
// =====================================================================

// ---------------------------------------------------------------------
// 1 · Paleta y constantes
// ---------------------------------------------------------------------
#let tinta = rgb("#212121")          // texto principal
#let negro = rgb("#1c1c1c")          // títulos
#let acento = rgb("#1f3a5f")         // azul académico profundo
#let acento-claro = rgb("#5a7a9a")   // azul atenuado
#let gris = rgb("#6a6a6a")           // texto secundario
#let regla = rgb("#c9c9c9")          // filetes finos
#let papel = rgb("#f7f6f2")          // fondo cálido de cajas

#let estado-apendice = state("plantilla.apendice", false)

// ---------------------------------------------------------------------
// 2 · Operadores matemáticos personalizados
// ---------------------------------------------------------------------
#let E = math.op("E")
#let Var = math.op("Var")
#let Cov = math.op("Cov")
#let Corr = math.op("Corr")
#let argmax = math.op("arg max", limits: true)
#let argmin = math.op("arg min", limits: true)

#let vect(x) = $bold(#x)$
#let mat(x) = $bold(#x)$

// ---------------------------------------------------------------------
// 3 · Plantilla principal
// ---------------------------------------------------------------------
#let tesis(meta, body) = {
  // --- metadatos del PDF ---
  set document(
    title: meta.titulo,
    author: (meta.autor),
    keywords: meta.palabras-clave,
    description: meta.resumen-corto,
  )

  // --- geometría de página ---
  set page(
    paper: "a4",
    margin: (left: 3.4cm, right: 2.6cm, top: 3.1cm, bottom: 3cm),
  )

  // --- tipografía ---
  set text(
    font: "New Computer Modern",
    size: 12pt,
    lang: "es",
    region: "pe",
    fill: tinta,
    hyphenate: true,
  )
  set par(
    justify: true,
    leading: 0.76em,
    spacing: 0.68em,
    first-line-indent: (amount: 1.25cm, all: false),
  )
  set list(spacing: 0.7em, indent: 1em)
  set enum(spacing: 0.7em, indent: 1em)
  show link: set text(fill: acento)

  // Referencias cruzadas a figuras/entornos: el prefijo de capítulo se
  // evalúa en el DESTINO de la referencia, no en el punto de cita.
  show ref: it => context {
    let el = it.element
    if el != none and el.func() == figure {
      let loc = el.location()
      let cap = counter(heading).at(loc).at(0, default: 0)
      let nv = counter(figure.where(kind: el.kind)).at(loc).at(0, default: 0)
      let previos = query(heading.where(level: 1).before(loc))
      let u = previos.at(-1, default: none)
      let en-ap = u != none and u.numbering == "A.1"
      let patron = if en-ap { "A.1" } else { "1.1" }
      link(loc, text(fill: acento)[#el.supplement #numbering(patron, cap, nv)])
    } else {
      it
    }
  }

  // --- jerarquía de títulos ---
  set heading(numbering: "1.1")

  // Numeración por capítulo (y por letra en apéndices), validada en Typst 0.15
  set figure(numbering: (..nums) => context {
    let patron = if estado-apendice.get() { "A.1" } else { "1.1" }
    numbering(patron, counter(heading).get().at(0, default: 0), ..nums)
  })
  set math.equation(numbering: (..nums) => context {
    let patron = if estado-apendice.get() { "(A.1)" } else { "(1.1)" }
    numbering(patron, counter(heading).get().at(0, default: 0), ..nums)
  })

  // Apertura de capítulo
  show heading.where(level: 1): it => context [
    // Reinicio de numeraciones al comenzar cada capítulo
    #counter(math.equation).update(0)
    #counter(figure.where(kind: image)).update(0)
    #counter(figure.where(kind: table)).update(0)
    #counter(figure.where(kind: raw)).update(0)
    #counter(figure.where(kind: "algoritmo")).update(0)
    #counter(figure.where(kind: "enunciado")).update(0)
    #counter(figure.where(kind: "enunciado-obs")).update(0)
    #pagebreak(weak: true)
    #v(1.6cm)
    #align(center)[
      #if it.numbering != none [
        #let es-ap = estado-apendice.get()
        #let rotulo = if es-ap [Apéndice] else [Capítulo]
        #let patron = if es-ap { "A" } else { "1" }
        #text(size: 11pt, fill: acento, tracking: 0.22em)[
          #smallcaps[#rotulo #counter(heading).display(patron)]
        ]
        #v(0.85em)
      ]
      #text(size: 24pt, weight: "bold", fill: negro)[#it.body]
      #v(1.3em)
      #line(length: 24%, stroke: 1.2pt + acento)
    ]
    #v(1.5em)
  ]

  // Sección
  show heading.where(level: 2): it => context block(
    above: 1.5em,
    below: 0.65em,
  )[
    #if it.numbering != none [
      #text(fill: acento, weight: "bold")[#counter(heading).display(it.numbering)]
      #h(0.75em)
    ]
    #text(size: 14pt, weight: "bold", fill: negro)[#it.body]
  ]

  // Subsección
  show heading.where(level: 3): it => context block(
    above: 1.2em,
    below: 0.5em,
  )[
    #if it.numbering != none [
      #text(fill: acento)[#counter(heading).display(it.numbering)]
      #h(0.65em)
    ]
    #text(size: 12pt, style: "italic", weight: "bold", fill: negro)[#it.body]
  ]

  // --- figuras, tablas, códigos, algoritmos y enunciados ---
  set figure(gap: 0.75em)
  set figure.caption(separator: [. ])

  show figure.where(kind: image): set figure(supplement: [Figura])
  show figure.where(kind: table): set figure(supplement: [Tabla])
  show figure.where(kind: raw): set figure(supplement: [Código])
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: set text(size: 10pt, fill: negro)
  show figure.caption: set par(justify: true, first-line-indent: 0cm)

  // Tablas al estilo «booktabs»: sin trazos verticales ni guiones
  set table(stroke: none, inset: (x: 9pt, y: 5.5pt))
  show table: set text(hyphenate: false)

  // Código fuente
  show raw.where(block: true): it => block(
    width: 100%,
    breakable: true,
    fill: rgb("#f4f3ee"),
    stroke: (left: 2.5pt + acento-claro),
    radius: (top-right: 3pt, bottom-right: 3pt),
    inset: (x: 12pt, y: 10pt),
    above: 1.1em,
    below: 1.1em,
    text(size: 10pt, it),
  )

  // Entornos lógico-matemáticos (numeración compartida por capítulo):
  // «enunciado» (teoremas, definiciones…) y «enunciado-obs» (observaciones).
  show figure.where(kind: "enunciado"): it => context {
    let cap = counter(heading).get().at(0, default: 0)
    let n = counter(figure.where(kind: "enunciado")).get().at(0, default: 0)
    let patron = if estado-apendice.get() { "A.1" } else { "1.1" }
    let num = numbering(patron, cap, n)
    let nombre = if it.caption != none { it.caption.body } else { none }
    block(
      width: 100%,
      breakable: true,
      above: 1.1em,
      below: 1.15em,
      stroke: (left: 2.5pt + acento),
      fill: papel,
      radius: (top-right: 3pt, bottom-right: 3pt),
      inset: (x: 13pt, y: 11pt),
    )[
      #text(weight: "bold")[#it.supplement #num#if nombre != none [ (#nombre)].]
      #h(0.5em)
      #it.body
    ]
  }

  show figure.where(kind: "enunciado-obs"): it => context {
    let cap = counter(heading).get().at(0, default: 0)
    let n = counter(figure.where(kind: "enunciado-obs")).get().at(0, default: 0)
    let patron = if estado-apendice.get() { "A.1" } else { "1.1" }
    let num = numbering(patron, cap, n)
    let nombre = if it.caption != none { it.caption.body } else { none }
    block(
      width: 100%,
      breakable: true,
      above: 1.0em,
      below: 1.05em,
      stroke: (left: 2pt + regla),
      radius: (top-right: 3pt, bottom-right: 3pt),
      inset: (x: 13pt, y: 10pt),
    )[
      #text(fill: acento-claro, style: "italic", size: 11pt)[
        #it.supplement #num#if nombre != none [ (#nombre)].
      ]
      #h(0.5em)
      #it.body
    ]
  }

  // Algoritmos (caja con filetes superior e inferior)
  show figure.where(kind: "algoritmo"): it => context {
    let cap = counter(heading).get().at(0, default: 0)
    let n = counter(figure.where(kind: "algoritmo")).get().at(0, default: 0)
    let patron = if estado-apendice.get() { "A.1" } else { "1.1" }
    let num = numbering(patron, cap, n)
    let nombre = if it.caption != none { it.caption.body } else { none }
    block(
      width: 100%,
      breakable: false,
      above: 1.2em,
      below: 1.2em,
      stroke: (top: 1.1pt + acento, bottom: 1.1pt + acento),
      inset: (x: 12pt, y: 10pt),
    )[
      #strong[#it.supplement #num — #nombre]
      #v(3pt)
      #line(length: 100%, stroke: 0.4pt + regla)
      #v(5pt)
      #text(size: 11pt)[#it.body]
    ]
  }

  // --- índices ---
  show outline: set text(size: 11pt)
  show outline.entry: set par(first-line-indent: 0cm)
  // Los capítulos destacan en negrita en el índice general
  show outline.entry.where(level: 1): set text(weight: "bold")

  // Entradas de índice de figuras y tablas: numeración recalculada en el
  // destino (el valor por defecto se evaluaría en la posición del índice).
  show outline.entry: it => context {
    let el = it.element
    if el != none and el.func() == figure {
      let loc = el.location()
      let cap = counter(heading).at(loc).at(0, default: 0)
      let nv = counter(figure.where(kind: el.kind)).at(loc).at(0, default: 0)
      let previos = query(heading.where(level: 1).before(loc))
      let u = previos.at(-1, default: none)
      let en-ap = u != none and u.numbering == "A.1"
      let patron = if en-ap { "A.1" } else { "1.1" }
      grid(
        columns: (1fr, auto),
        link(loc)[
          #el.supplement #numbering(patron, cap, nv)#h(0.55em)
          #el.caption.body
          #box(width: 1fr, outset: (y: 0.4em), it.fill)
        ],
        [#counter(page).at(loc).at(0)],
      )
    } else {
      it
    }
  }

  // --- bibliografía (APA, localizada al español vía text-lang) ---
  show bibliography: set par(justify: false, first-line-indent: 0cm)

  body
}

// ---------------------------------------------------------------------
// 4 · Portada
// ---------------------------------------------------------------------
#let portada(meta) = [
  #set par(justify: false, first-line-indent: 0cm)
  #align(center)[
    #v(0.3cm)
    #let logo = meta.at("logo", default: none)
    #if logo != none [
      #if type(logo) == content [ #logo ] else [ #image(logo, width: 24%) ]
    ]
    #v(0.55cm)
    #text(size: 15pt, fill: negro, tracking: 0.14em)[#smallcaps[#meta.universidad]]
    #v(2.5mm)
    #text(size: 11.5pt, fill: gris, tracking: 0.05em)[#smallcaps[#meta.facultad]]
    #v(2mm)
    #text(size: 10.5pt, fill: acento, tracking: 0.3em)[#smallcaps[#meta.unidad]]
    #v(2mm)
    #line(length: 34%, stroke: 0.7pt + regla)
  ]
  #v(1fr)
  #align(center)[
    #box(
      stroke: 0.9pt + acento,
      inset: (x: 16pt, y: 9pt),
      radius: 2pt,
      outset: (bottom: 4pt),
    )[
      #text(size: 11pt, fill: acento, tracking: 0.28em)[#smallcaps[#meta.tipo-doc]]
    ]
    #v(0.8cm)
    #text(size: 21pt, weight: "bold", fill: negro, hyphenate: false)[#meta.titulo]
  ]
  #v(1fr)
  #align(center)[
    #text(size: 10.5pt, fill: gris, tracking: 0.22em)[#smallcaps[Para optar el grado académico de]]
    #v(4mm)
    #text(size: 12.5pt, weight: "bold", fill: tinta, tracking: 0.03em)[#smallcaps[#meta.grado]]
  ]
  #v(1fr)
  #align(center)[
    #text(size: 10.5pt, fill: gris, tracking: 0.22em)[#smallcaps[Presentado por]]
    #v(3.5mm)
    #text(size: 14pt, weight: "bold", fill: negro)[#meta.autor]
    #v(9mm)
    #text(size: 10.5pt, fill: gris, tracking: 0.22em)[#smallcaps[Asesor]]
    #v(3.5mm)
    #text(size: 13pt, weight: "bold", fill: negro)[#meta.asesor]
  ]
  #v(1fr)
  #align(center)[
    #text(size: 11pt, fill: tinta, tracking: 0.2em)[#smallcaps[#meta.ciudad]]
    #v(4mm)
    #text(size: 11.5pt, weight: "bold", fill: acento)[#meta.anio]
    #v(0.3cm)
  ]
]

// ---------------------------------------------------------------------
// 5 · Cabecera viva y transiciones estructurales (usar como reglas show)
// ---------------------------------------------------------------------

// Cabecera viva: capítulo corriente en versalitas con filete fino.
// Se omite automáticamente en las páginas de apertura de capítulo.
#let cabecera-de() = context {
  let pg = here().page()
  let abiertos = query(heading.where(level: 1))
    .filter(h => h.location().page() == pg)
  if abiertos.len() > 0 [] else {
    let previos = query(heading.where(level: 1).before(here()))
    let cap = previos.at(-1, default: none)
    if cap != none [
      #grid(
        columns: (1fr,),
        align(left)[
          #text(size: 9.5pt, fill: acento, tracking: 0.12em)[#smallcaps[#cap.body]]
        ],
      )
      #v(4pt)
      #line(length: 100%, stroke: 0.5pt + regla)
    ] else []
  }
}

// Preliminares: numeración romana en minúscula, pie limpio.
#let frontmatter(body) = [
  #pagebreak()
  #counter(page).update(1)
  #set page(numbering: "i")
  #body
]

// Cuerpo: numeración arábiga y cabecera viva.
#let mainmatter(body) = [
  #pagebreak()
  #counter(page).update(1)
  #set page(numbering: "1", header: cabecera-de())
  #body
]

// Apéndices: numeración con letras y rótulo «Apéndice».
#let apendices(body) = [
  #set heading(numbering: "A.1")
  #counter(heading).update(0)
  #estado-apendice.update(true)
  #body
]

// ---------------------------------------------------------------------
// 6 · Piezas de redacción
// ---------------------------------------------------------------------

// Capítulo preliminar sin numerar (aparece en el índice general).
#let prefacio(titulo, cuerpo) = [
  #heading(level: 1, numbering: none)[#titulo]
  #cuerpo
]

// Entorno base de enunciados (numeración compartida por capítulo).
#let enunciado(tipo, nombre: none, id: none, cuerpo) = {
  let familia = if tipo in ("Teorema", "Lema", "Corolario", "Proposición") { "teorema" }
    else if tipo in ("Definición", "Axioma", "Problema") { "definicion" }
    else { "observacion" }
  let clase = if familia == "observacion" { "enunciado-obs" } else { "enunciado" }
  let cuerpo-form = if familia == "teorema" { emph(cuerpo) }
    else if familia == "observacion" { text(size: 11pt, cuerpo) }
    else { cuerpo }
  if id != none [
    #figure(cuerpo-form, kind: clase, supplement: tipo, caption: nombre)
    #label(id)
  ] else [
    #figure(cuerpo-form, kind: clase, supplement: tipo, caption: nombre)
  ]
}

#let teorema(nombre: none, id: none, cuerpo) = enunciado("Teorema", nombre: nombre, id: id, cuerpo)
#let lema(nombre: none, id: none, cuerpo) = enunciado("Lema", nombre: nombre, id: id, cuerpo)
#let corolario(nombre: none, id: none, cuerpo) = enunciado("Corolario", nombre: nombre, id: id, cuerpo)
#let proposicion(nombre: none, id: none, cuerpo) = enunciado("Proposición", nombre: nombre, id: id, cuerpo)
#let definicion(nombre: none, id: none, cuerpo) = enunciado("Definición", nombre: nombre, id: id, cuerpo)
#let axioma(nombre: none, id: none, cuerpo) = enunciado("Axioma", nombre: nombre, id: id, cuerpo)
#let observacion(nombre: none, id: none, cuerpo) = enunciado("Observación", nombre: nombre, id: id, cuerpo)
#let ejemplo(nombre: none, id: none, cuerpo) = enunciado("Ejemplo", nombre: nombre, id: id, cuerpo)
#let nota(nombre: none, id: none, cuerpo) = enunciado("Nota", nombre: nombre, id: id, cuerpo)

// Demostración con lápida (QED).
#let demostracion(cuerpo) = [
  #block(above: 0.4em, below: 1.15em, width: 100%, breakable: true)[
    #emph[Demostración.]#h(0.5em)
    #cuerpo
    #h(1fr)
    #box(width: 0.62em, height: 0.62em, fill: tinta)
  ]
]

// Algoritmo con título (numerado por capítulo).
#let algoritmo(nombre, id: none, cuerpo) = {
  if id != none [
    #figure(cuerpo, kind: "algoritmo", supplement: "Algoritmo", caption: nombre)
    #label(id)
  ] else [
    #figure(cuerpo, kind: "algoritmo", supplement: "Algoritmo", caption: nombre)
  ]
}

// Caja de aviso / nota editorial (instrucciones de la plantilla).
#let aviso(titulo, cuerpo) = block(
  width: 100%,
  breakable: true,
  stroke: (left: 2.5pt + acento-claro),
  fill: papel,
  radius: (top-right: 3pt, bottom-right: 3pt),
  inset: (x: 12pt, y: 10pt),
  above: 1.1em,
  below: 1.1em,
)[
  #text(fill: acento, weight: "bold", size: 11pt)[#smallcaps[#titulo]]
  #v(3pt)
  #text(size: 11pt, fill: gris)[#cuerpo]
]

// Rótulo de nivel de evidencia (documentacion/README.md).
#let evidencia(tipo: "simulación", body) = block(
  width: 100%,
  breakable: true,
  stroke: (left: 2pt + regla),
  inset: (left: 10pt, y: 6pt),
  above: 0.8em,
  below: 0.8em,
)[
  #text(size: 10pt, fill: gris)[
    #strong[Nivel de evidencia:] #tipo. #body
  ]
]

// Tarea pendiente (elimínese en la versión final).
#let TODO(txt) = text(fill: rgb("#a33d3d"))[#strong[TODO: #txt]]
