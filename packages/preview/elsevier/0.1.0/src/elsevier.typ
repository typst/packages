#import "@preview/equate:0.3.2": *
#import "els-globals.typ": *
#import "els-layout.typ": *
#import "els-globals.typ": *
#import "els-journal.typ": *
#import "els-environment.typ": *

#let elsevier(
  paper-type: [Article],
  journal: mssp,
  title: [],
  abstract: [],
  authors: (),
  institutions: (),
  paper-info: paper-info-default,
  keywords: (),
  body,
) = {
  // Set paper information
  let paper-information = paper-info-default + paper-info

  // Text
  set text(size: 8pt, font: textfont)

  // Math
  show: equate.with(breakable: true, sub-numbering: true)
  set math.equation(numbering: (..n) => text(font: textfont, numbering("(1a)", ..n)) , supplement: none)

  let pad-val = if journal.numcol == 1 {2em} else {0em}
  show math.equation.where(block: true): set align(left)
  show math.equation.where(block: true): pad.with(left: pad-val)
  show math.equation: set text(font: mathfont)

  // Links styling
  show link: set text(fill: rgb(33, 150,209))

  // Refs styling
  set ref(supplement: it => none)
  show ref: set text(fill: rgb(33, 150,209))

  // Figures and Tables
  show figure.where(kind: table): set figure.caption(position: top)

  // Page setup
  set page(
    paper: "a4",
    margin: (x: 1.5cm, top: 2cm),
    header: make-header(authors, journal, paper-information),
    footer: make-footer(paper-information, journal),
  )

  top-bar({
      text(size: 8pt)[Contents lists available at #link("https://"+journal.address, "ScienceDirect")]
      v(1fr)
      text(size:13.9pt)[#journal.name]
      v(1fr)
      text(size: 8pt, font: "Roboto")[journal homepage: #link("https://"+journal.address, strong(delta: 100, journal.address))]
    },
    journal-image: journal.logo,
  )

  make-title(
    title: title,
    authors: authors,
    institutions: institutions,
    paper-type: paper-type
  )

  v(0.3em)

  make-precis(
    keywords: keywords,
    abstract: abstract,
    extra-info: paper-info.extra-info
  )

  make-corresponding-author(authors)

  show heading: set block(spacing: 1.25em, above: 2em)
  set heading(numbering: "1.1.1.")
  show heading: set text(size: 10pt)
  show heading.where(level: 1): it => {
    it
    v(0.25em)

    // Update math counter at each new appendix
    if isappendix.get() {
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
    }
  }
  show heading.where(level: 2): set text(weight: "light", style: "italic")
  show heading.where(level: 3): it => {
    set text(weight: "light", style: "italic")
    it
    v(-0.6em)
  }

  v(1em)

  set par(justify: true, first-line-indent: (amount: 1.5em, all:true))

  // Workaround to not indent the first paragraph after an equation
  show math.equation: it => it + [#[ #[]<eq-end>]]
  show par: it => {
    if it.first-line-indent.amount == 0pt {
      // Prevent recursion.
      return it
    }

    context {
      let eq-end = query(selector(<eq-end>).before(here())).at(-1, default: none)
      if eq-end == none { return it }
      if eq-end.location().position() != here().position() { return it }

      // Paragraph start aligns with end of last equation, so recreate
      // the paragraph, but without indent.
      let fields = it.fields()
      let body = fields.remove("body")
      return par(
        ..fields,
        first-line-indent: 0pt,
        body
      )
    }
  }

  // bibliography
  set bibliography(title: "References", style: "elsevier-with-titles")
  show bibliography: set heading(numbering: none)
  show bibliography: set text(size: 7.2pt)

  show: columns(journal.numcol, body)
}