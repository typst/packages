#import "toc.typ": all-outlines
#import "main-matter.typ": chapter-page, heading-supplements

/// Genera la página de agradecimientos del documento, si aplica.
#let acknowledgements-page(body) = {
  if body == none {
    return
  }

  body
}

/// Genera la página dedicatoria del documento, si aplica.
///
/// Se recomienda que la dedicatoria sea breve y concisa (1 página).
#let dedication-page(body) = {
  if body == none {
    return
  }

  body
}

/// Genera las páginas preliminares del documento, incluyendo carátula, índices, abstracto, etc.
#let front-matter(
  problem: none,
  objective: none,
  executive-summary: none,
  dedication: none,
  abstract-content: context {
    let chapters = query(heading.where(outlined: true, supplement: [Capítulo])).filter(it => it.numbering != none)
    outline(
      target: selector.or(..chapters.map(it => heading.where(
        outlined: true,
        supplement: [Capítulo],
        numbering: it.numbering,
      ))),
      indent: 0em,
      title: [Contenido],
    )
  },
  acknowledgements: none,
) = context {
  import "info.typ"
  import "abstract.typ"
  import "title.typ": title-page

  set heading(offset: 0)
  show: heading-supplements
  title-page()

  let typeface = info.font.get()
  let font-family = info.font-family.get()

  set text(
    ..typeface.text,
    lang: "es",
    region: "bo",
  )

  show heading: set text(size: typeface.text.size)
  show heading.where(level: 2): set text(font: typeface.text.font, size: 1.1em)
  show heading: set block(spacing: 1.5em)
  show outline.entry: set text(number-type: "lining", number-width: "tabular")

  set par(
    leading: 1.25em,
    spacing: 1.5em,
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

  show table: set text(size: typeface.text.size, hyphenate: true)
  show table: set par(
    spacing: 1.5em / 2,
    leading: 1em / 2,
    justify: true,
  )

  dedication-page(dedication)
  acknowledgements-page(acknowledgements)

  counter(page).update(1)
  set page(numbering: "i", footer: context {
    set text(stylistic-set: 1) if font-family == "Alegreya" or font-family == "Piazzolla"
    set align(right)
    lower(counter(page).display("i"))
  })

  show heading.where(level: 1): it => chapter-page(it, alignment: center)
  show heading.where(level: 1): smallcaps
  show heading.where(level: 2): set align(center)

  abstract.faculty(
    problem: problem,
    objective: objective,
    content-index: abstract-content,
  )

  {
    set heading(numbering: none)

    if info.work-abstract.get() != none {
      pagebreak(weak: true)
      heading[Resumen]
      info.work-abstract.get()
    }

    if executive-summary != none {
      pagebreak(weak: true)
      heading[Resumen ejecutivo]
      executive-summary
    }
  }

  all-outlines
}
