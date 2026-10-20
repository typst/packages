#import "@preview/equate:0.3.2": *
#import "iop-globals.typ": *
#import "iop-cover.typ": *
#import "iop-globals.typ": *
#import "iop-journal.typ": *
#import "iop-environment.typ": *

#let ioppub(
  journal: default-journal,
  title: [],
  abstract: [],
  authors: (),
  institutions: (),
  paper-info: paper-info-default,
  keywords: (),
  body,
) = {
  let new-journal = default-font + journal

  // Set paper information
  let paper-information = paper-info-default + paper-info

  // Text
  set text(size: 10pt, font: new-journal.font.text)

  // Math
  show: equate.with(breakable: true, sub-numbering: true)
  set math.equation(numbering: (..n) => text(font: new-journal.font.text, numbering("(1a)", ..n)), supplement: none)
  show math.equation: set text(font: new-journal.font.math)

  // Links styling
  show link: set text(fill: rgb(0, 0, 245))

  // Refs styling
  set ref(supplement: it => none)
  show ref: set text(fill: rgb(0, 0, 245))

  // Figures and Tables
  show figure.where(kind: image): set figure(placement: top)
  show figure: set figure.caption(separator: ". ")
  show figure.caption: c => align(center, block[
    #set align(left)
    #par(justify: false, [#text(
        font: journal.font.header,
        [*#c.supplement #c.counter.display(c.numbering)#c.separator*],
      )#c.body])
  ])
  show figure.where(kind: table): set figure.caption(position: top)
  show table: set table(stroke: (x, y) => {
    if y == 0 {
      (top: 1pt + black, bottom: 0.7pt + black)
    }
  })

  // Page setup
  set page(
    paper: "a4",
    margin: (x: 16mm, top: 25mm, bottom: 26mm),
    header: make-header(authors, new-journal, paper-information),
    footer: make-footer(paper-information, new-journal),
    columns: journal.numcol,
  )
  set columns(journal.numcol, gutter: 1.03em)

  place(top, scope: "parent", float: true, clearance: 2.2em, {
    make-title(
      title: title,
      authors: authors,
      institutions: institutions,
      paper-info: paper-info-default,
    )

    v(0.5em)

    make-precis(
      keywords: keywords,
      abstract: abstract,
    )
  })

  show heading: set block(spacing: 1.25em, above: 2em)
  set heading(numbering: "1.1.1.")
  show heading: set text(size: 11pt, font: new-journal.font.header)
  show heading.where(level: 1): it => {
    set text(weight: "bold")
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

  set par(justify: true, first-line-indent: 1.5em, spacing: 0.65em)

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
        body,
      )
    }
  }

  // bibliography
  set bibliography(title: "References", style: "apa")
  show bibliography: set heading(numbering: none)
  show bibliography: set text(size: 9pt)

  // Custom citations
  show cite: it => {
    show regex("\[|\]"): it => text(fill: black)[#it]
    it
  }

  // Main body
  show: body
}
