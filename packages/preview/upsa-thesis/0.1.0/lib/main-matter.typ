// Apply the same logical hierarchy at each matter's heading offset.
#let heading-supplements(body, offset: 0, appendix: false) = {
  show heading.where(level: offset + 1): set heading(
    supplement: if appendix { [Anexo] } else { [Capítulo] },
  )
  show heading.where(level: offset + 2): set heading(supplement: [Sección])
  show heading.where(level: offset + 3): set heading(supplement: [Subsección])
  show heading.where(level: offset + 4): set heading(supplement: [Subsubsección])
  show heading.where(level: offset + 5): set heading(supplement: [Párrafo])
  show heading.where(level: offset + 6): set heading(supplement: [Subpárrafo])
  body
}

// Show-set styling follows each matter's offset without replacing headings.
#let heading-styles(body, offset: 0) = context {
  import "info.typ"
  let typeface = info.font.get()
  show heading: set text(weight: "bold", style: "normal")
  show heading.where(level: offset + 1): set text(..typeface.display)
  show heading.where(level: offset + 2): set align(center)
  show heading.where(level: offset + 4): set text(weight: "bold", style: "italic")
  show heading.where(level: offset + 6): set text(weight: "bold", style: "italic")
  // Match the matter's resolved levels before supplements are assigned.
  show heading
    .where(level: offset + 5)
    .or(
      heading.where(level: offset + 6),
    ): it => box[#it.body.]
  body
}

#let chapter-page(it, alignment: left) = context {
  // Art. 143: Inicio y conclusión del capítulo
  // Se recomienda que cada capítulo comience en hoja aparte y que cada uno de ellos incluya un párrafo introductorio que presente su organización e indique al lector cuál es el objetivo específico del mismo.
  // Igualmente, al terminar cada capítulo es aconsejable redactar un párrafo que contenga un pequeño resumen de lo tratado e indique además la relación del capítulo que termina con el que empieza a continuación.
  pagebreak(weak: true)
  set par(justify: false, leading: 0.5em)
  set align(alignment)
  // Keep the complete heading together and attached to the following content.
  block(width: 100%, breakable: false, sticky: true, {
    set text(tracking: 0.05em, number-type: "lining", number-width: "tabular")

    // An inline-only block keeps the label in the heading's structure,
    // without introducing a nested paragraph beside the title block.
    if it.numbering != none and it.outlined {
      block[
        #set text(
          size: 2.5em,
          fill: gray.darken(40%),
        )
        #it.supplement
        #text(
          size: 1.25em,
          counter(heading).display(it.numbering),
        )
      ]
    }

    block(
      width: 100%,
      stroke: (y: 1pt),
      inset: (y: 1.5em, x: 0.5em),
      spacing: 2em,
      text(
        size: 2em,
        it.body,
      ),
    )
  })
}

#let part-page(it) = context {
  import "info.typ"
  pagebreak(weak: true)
  set par(justify: false)
  set page(numbering: none, header: none)
  let typeface = info.font.get()

  set align(center)

  v(0.5fr)

  // Keep each visual line in the native heading, without paragraph tags.
  // Paragraph spacing used to resolve at each line's font size. Preserve
  // that spacing explicitly while keeping the lines free of paragraph tags.
  block(spacing: par.spacing * 1.5, text(
    size: 1.5em,
    weight: 500,
    tracking: 0.05em,
    upper(it.supplement),
  ))

  v(1em)

  if it.numbering != none and it.outlined {
    block(spacing: par.spacing * 3.5, text(
      font: typeface.text.font,
      size: 3.5em,
      weight: "black",
    )[#counter(heading).display(it.numbering)])

    v(1em)
  }

  block(spacing: par.spacing * 2.5, text(
    size: 2.5em,
    weight: "bold",
    tracking: 0.1em,
    upper(it.body),
  ))

  v(1fr)
}



/// Prepara el documento para el contenido principal.
#let main-matter(body) = context {
  import "@preview/hydra:0.6.3": hydra
  import "info.typ"

  let typeface = info.font.get()
  let multi-part = info.multi-part.get()
  let chapter-level = if multi-part { 2 } else { 1 }

  set page(
    numbering: "1",
    header: context hydra(
      chapter-level,
      display: (
        _,
        it,
      ) => text(
        tracking: 0.2em,
        fill: gray.darken(40%),
        weight: "bold",
        upper(it.body),
        ..typeface.display,
      ),
    ),
  )

  set text(
    ..typeface.text,
  )

  set par(
    spacing: 1.5em,
    leading: 1em,
    justify: true,
    justification-limits: (
      spacing: (min: 75%, max: 130%),
      tracking: (min: -0.008em, max: 0.015em),
    ),
    first-line-indent: (
      amount: 0in,
      all: true,
    ),
  )

  set math.equation(
    numbering: "(1)",
    supplement: [Fórmula],
  )

  set enum(numbering: n => text(
    number-type: "lining",
    number-width: "tabular",
    numbering(
      "1.",
      n,
    ),
  ))

  show math.equation: set text(..typeface.math)

  set figure.caption(separator: parbreak(), position: top)
  show figure: set align(left)
  show figure.where(kind: image): set block(breakable: false, sticky: true)
  show figure.where(kind: table): set block(breakable: true, sticky: false)
  show table: set text(size: typeface.text.size * 0.9)
  show table: set par(
    spacing: 1.5em,
    leading: 1em,
  )
  show footnote: set text(size: typeface.text.size * 0.8)
  show raw: set text(font: typeface.mono.font, size: typeface.mono.size)
  show figure.where(kind: math.equation): set figure(supplement: [Fórmula])
  set figure(
    gap: 1.25em,
    placement: none,
  )

  show figure.caption: set align(left)
  show figure.caption: set text(font: typeface.text.font)
  show figure.caption: set par(first-line-indent: 0em)
  show figure.caption: it => {
    strong[#it.supplement #context it.counter.display(it.numbering)]
    it.separator
    emph(it.body)
  }

  show quote.where(block: true): set block(spacing: 1.5em)

  import "apa.typ": apa-quote

  show quote: it => apa-quote(it)

  // Art. 144: Encabezamientos
  // Todo escrito deberá incluir encabezados para destacar los subtemas de la investigación. Para ello se deberá considerar un espacio adicional antes y después de cada encabezado. Se podrá remarcar los encabezados con negrillas, en cuyo caso solo se necesita un espacio antes del encabezado.
  // Existen encabezados principales y secundarios, los cuales deberán estar escritos y ubicados apropiadamente, según una escala jerárquica sistemática durante todo el desarrollo del texto. Para señalar los encabezados podrá utilizarse el sistema decimal o alfanumérico.
  // Markup depth stays independent of the optional part level.
  set heading(offset: chapter-level - 1, numbering: (..args) => {
    let pos = args.pos().slice(chapter-level - 1)
    if pos.len() == 1 {
      numbering("1", ..pos)
    } else if pos.len() <= 4 {
      numbering("1.1", ..pos)
    }
  })

  show heading: set text(
    size: typeface.text.size,
    number-type: "lining",
    number-width: "tabular",
  )
  show heading: set block(spacing: 1.5em)

  show: heading-supplements.with(offset: chapter-level - 1)

  show: heading-styles.with(offset: chapter-level - 1)

  // Imported sections may also have markup depth 1 with a larger offset.
  // Only resolved part/chapter levels receive a chapter-opening page.
  show heading.where(level: 1).or(heading.where(level: chapter-level)): it => {
    if it.supplement == [Parte] {
      part-page(it)
    } else {
      smallcaps(chapter-page(it))
    }
  }

  show figure.where(kind: raw): set figure(placement: none)
  show figure.where(kind: raw): set block(breakable: true, sticky: false)
  show figure.where(kind: raw): set raw(block: true)
  show figure.where(kind: raw): set align(left)

  // La numeración de páginas no es correlativa entre romana y arábiga, por lo que se reinicia el contador de páginas al cambiar a la numeración arábiga.
  counter(heading).update(0)
  counter(page).update(1)
  info.in-back-matter.update(false)

  body
}

#let part(body) = context {
  import "info.typ"

  // The same document source can retain part boundaries in chapter-only mode.
  if info.multi-part.get() {
    // A part advances the outer heading counter, but preserves the continuous
    // chapter number.
    // Back matter resets heading counters for alphabetic appendices, so part
    // numbering must follow the document's parts rather than that reset.
    let part-number = query(heading.where(level: 1, supplement: [Parte]).before(here())).len() + 1
    heading(
      level: 1,
      offset: 0,
      numbering: (..numbers) => numbering("I", part-number),
      body,
      supplement: [Parte],
    )
    if info.in-back-matter.get() {
      // A back-matter divider must not advance the alphabetic appendix counter.
      let appendices = query(heading.where(level: 1, supplement: [Anexo]).before(here()))
        .filter(it => it.numbering != none)
        .len()
      counter(heading).update(appendices)
    } else {
      let chapters = query(heading.where(level: 2).before(here())).filter(it => it.numbering != none).len()
      counter(heading).update((part-number, chapters))
    }
    pagebreak(weak: true)
  }
}
