#import "i18n.typ": *
#import "utils.typ": *

/// This style is applied to the entire project.
#let global-style(doc) = {
  set page(paper: "a4", margin: (top: 6.7cm, bottom: 2.5cm, rest: 3.25cm))
  set text(size: 12pt)
  set par(
    justify: true,
    first-line-indent: 1.5em,
    spacing: 0.8em,
    linebreaks: "optimized",
    justification-limits: (
      tracking: (min: -0.05em, max: 0.05em),
    ),
  )
  show figure: set block(spacing: 1.75em)
  show math.equation: set block(spacing: 1.75em)
  show: line-spacing.with(1.25em)
  show footnote: set text(size: 0.8em)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set align(start)
  show figure.caption: it => {
    grid(
      columns: 3,
      gutter: 0pt,
      align: left,
      context {
        show: strong
        it.supplement
        sym.space
        it.counter.display(it.numbering)
      },
      it.separator,
      it.body,
    )
  }

  show figure.where(kind: image): set figure(supplement: i18n("figure"))
  show figure.where(kind: table): set figure(supplement: i18n("table"))
  show figure.where(kind: raw): set figure(supplement: i18n("raw"))
  show math.equation: set math.equation(supplement: i18n("equation"))

  // Setup supplements and formatting of references
  show ref.where(form: "normal"): set ref(supplement: it => if it.func()
    == figure {
    if it.kind == image {
      i18n("ref-figure")
    } else if it.kind == table {
      i18n("ref-table")
    } else if it.kind == raw {
      i18n("ref-raw")
    } else {
      return it.supplement
    }
  } else if it.func() == math.equation {
    i18n("ref-equation")
  } else {
    return it.supplement
  })
  show ref.where(form: "normal"): it => {
    if it.element == none {
      return it
    }

    if it.element.func() == math.equation {
      return link(it.element.location())[
        #(it.supplement)(it.element)
        #(
          (it.element.numbering)(
            ..counter(math.equation).at(it.element.location()),
          )
            .trim("(", at: start)
            .trim(")", at: end)
        )
      ]
    }

    return it
  }

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
  set heading(numbering: none, supplement: i18n("ref-section"))
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
  let element-location = entry.element.location()
  if entry.element.func() == heading and entry.element.level == 1 {
    element-location = nearest-top-level-heading(element-location)
  }

  link(
    element-location,
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
          numbering(
            element-location.page-numbering(),
            ..counter(page).at(element-location),
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
  show heading.where(level: 1): set heading(supplement: i18n("chapter"))
  // Reset figure and math counters per chapter
  show heading.where(level: 1): it => {
    reset-listing-counters()
    colbreak(weak: true)
    it
  }

  show: _pre-top-heading-numbering.with("1.1")
  set figure(numbering: hierarchical-numbering("1.1"))
  set math.equation(numbering: hierarchical-numbering("(1.1)"))

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
#let bibliography-style(doc) = context {
  // Arabic for literature section
  set page(numbering: "1")

  // Configure actual bibliography style
  set bibliography(style: "apa", title: i18n-translation(
    "references",
    text.lang,
  ))

  doc
}

/// This style is applied to the appendix section.
#let appendix-style(doc) = {
  // Arabic for text sections = appendix
  set page(numbering: "1")

  show heading.where(level: 1): set heading(supplement: i18n("appendix"))
  counter(heading).update(0)
  show heading.where(level: 1): it => {
    reset-listing-counters()
    colbreak(weak: true)
    it
  }
  show: _pre-top-heading-numbering.with("A.1")
  set figure(numbering: hierarchical-numbering("A.1"))
  set math.equation(numbering: hierarchical-numbering("(A.1)"))

  doc
}
