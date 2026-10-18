#import "i18n.typ": i18n, i18n-page-counter
#import "utils.typ": *

/// This stile is applied to the entire project.
#let global-style(doc) = {
  set page(paper: "a4", margin: (top: 6.7cm, bottom: 2.5cm, rest: 3.25cm))
  set text(font: "Times New Roman", size: 12pt)
  set par(justify: true)
  show footnote: set text(size: 0.8em)
  show: line-spacing.with(1.25em)
  show figure.where(kind: table): set figure.caption(position: top)
  doc
}


/// This style is applied to the entire document (project without title page).
#let document-style(doc) = context {
  // Setup page decorations
  let header = []
  let footer = context [
    #set align(top + page.number-align.x)
    #show: apply-sans-font
    #show: block.with(inset: (top: 1em))
    #set text(size: 10pt)
    #i18n-page-counter(
      counter(page).get().first(),
      counter(page).final().first(),
    )
  ]
  //set page(header: header, header-ascent: 0cm)
  set page(footer: footer, footer-descent: 0cm)

  // Adjust page margin to account for header and footer
  let target-margin = page.margin
  set page(margin: (
    ..target-margin,
    top: target-margin.top + measure(header).height,
    bottom: target-margin.bottom + measure(footer).height,
  ))
  // Default page numbering style for the whole document
  set page(numbering: "i")

  // Setup headings
  set heading(numbering: none)
  // Default heading style for the whole document
  show heading.where(level: 1): set text(size: 1.6em)
  show heading.where(level: 2): set text(size: 1.25em)
  show heading.where(level: 3): set text(size: 1.15em)
  show heading.where(level: 4): set text(size: 1.1em)
  show heading: mark-heading-boundaries

  show heading: set block(above: 1.5em, below: 1em)
  show heading.where(level: 1): set block(inset: (bottom: 1.5cm))
  show heading: apply-sans-font
  show heading: set text(weight: "regular")

  // Typography
  set par(spacing: 2em)

  doc
}

#let _pre-top-heading-numbering(numbering-str, doc) = {
  show heading.where(level: 1): set heading(hanging-indent: 0pt)
  set heading(numbering: (..args) => with-inside-heading(
    is-inside-heading => context {
      let number = numbering(numbering-str, ..args)
      if is-inside-heading and args.pos().len() == 1 {
        set text(size: 0.68em)
        show: block.with(inset: 0pt, below: 1.1cm)
        heading.supplement
        sym.space
        number
      } else {
        number
      }
    },
  ))

  doc
}

#let _outline-entry(entry, logical-level: none) = {
  if logical-level == none {
    logical-level = entry.element.level
  }
  link(
    entry.element.location(),
    {
      let original-font = text.font
      show: if logical-level == 1 { apply-sans-font } else { it => it }
      entry.indented(
        entry.prefix(),
        {
          entry.body()
          set text(font: original-font)
          box(width: 1fr, inset: (x: 0.5em), if logical-level != 1 {
            repeat([.], gap: 0.5em)
          })
          let elem-location = entry.element.location()
          numbering(
            elem-location.page-numbering(),
            ..counter(page).at(elem-location),
          )
        },
        gap: if logical-level == 1 { 1em } else { 0.5em },
      )
    },
  )
}

/// This style is applied to the chapter content of the document, everything that the template wraps so to say.
#let content-style(doc) = {
  // Arabic for text sections = content
  set page(numbering: "1")
  counter(page).update(1)

  // Setup headings
  set heading(supplement: i18n("chapter"))
  show heading.where(level: 1): it => {
    colbreak(weak: true)
    it
  }
  show: _pre-top-heading-numbering.with("1.1")

  doc
}

/// This style is applied to the declaration page.
#let declaration-style(doc) = {
  show heading.where(level: 1): set text(size: 0.5em)
  set page(header: none)
  doc
}

/// This style is applied to the acknowledgement section.
#let acknowledgement-style(doc) = {
  doc
}

/// This style is applied to the abstract section (both german and english).
#let abstract-style(doc) = {
  doc
}

/// This style is applied to the preamble section.
#let preamble-style(doc) = {
  doc
}

/// This style is applied to the chapter outline.
#let chapter-outline-style(doc) = context {
  set outline(indent: auto)
  //show outline.entry: set block(stroke: green)
  //show outline.entry: set box(stroke: red)
  let root-em = text.size
  show outline.entry: _outline-entry
  show outline.entry.where(level: 1): set text(weight: "semibold")
  show outline.entry.where(level: 1): set block(above: 1.5em)
  set outline.entry(fill: {
    set text(size: root-em)

    repeat(
      [
        #set text(size: root-em)
        .
      ],
      gap: 0.5em,
    )
  })

  doc
}

#let abbreviations-style(doc) = {
  // Arabic for abbreviations section
  set page(numbering: "1")

  doc
}

/// This style is applied to the figure outline.
#let figure-outline-style(doc) = {
  // Arabic for figures section
  set page(numbering: "1")

  show outline.entry: _outline-entry.with(logical-level: 2)

  doc
}

#let table-outline-style(doc) = {
  // Arabic for tables section
  set page(numbering: "1")

  show outline.entry: _outline-entry.with(logical-level: 2)

  doc
}

/// This style is applied to the bibliography section.
#let bibliography-style(doc) = {
  // Arabic for literature section
  set page(numbering: "1")

  // Configure actual bibliography style
  set bibliography(style: "apa", title: i18n("references"))

  doc
}

/// This style is applied to the appendix section.
#let appendix-style(doc) = {
  // Arabic for text sections = appendix
  set page(numbering: "1")

  set heading(supplement: i18n("appendix"))
  counter(heading).update(0)
  show heading.where(level: 1): it => {
    colbreak(weak: true)
    it
  }
  show: _pre-top-heading-numbering.with("A.1")

  doc
}
