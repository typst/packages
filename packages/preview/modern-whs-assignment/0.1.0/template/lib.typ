#import "@preview/codly:1.0.0": *
#import "@preview/outrageous:0.3.0"
#import "@preview/codly-languages:0.1.5": *

#import "util.typ": *
#import "partial/title.typ" as title-page

#let whs-assignment(
  title,
  author,
  submission-date,
  keywords,
  course,
  lecturer,
  bibliography,
  body,
) = {
  // Global Settings
  set text(lang: "de", size: 12pt)
  set text(ligatures: false)
  set text(font: "TeX Gyre Heros")

  // Set fonts
  show raw: set text(font: "Fira Code")
  show math.equation: set text(font: "New Computer Modern Math")

  // Set pdf meta
  set document(
    title: title,
    author: author,
    date: submission-date,
    keywords: keywords,
  )

  // Set numbering mode
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1")
  set outline(indent: auto)

  // Set citation style
  set cite(style: "iso-690-author-date")

  // Heading spacing
  show heading.where(level: 1): set block(above: 1.95em, below: 1em)
  show heading.where(level: 2): set block(above: 1.85em, below: 1em)
  show heading.where(level: 3): set block(above: 1.75em, below: 1em)
  show heading.where(level: 4): set block(above: 1.55em, below: 1em)

  show: codly-init.with()
  codly(languages: codly-languages, zebra-fill: none)

  // ------ Cover ------

  title-page.title(
    title,
    author,
    submission-date,
    course,
    lecturer,
  )

  // ------ Content ------

  set page(numbering: "I", number-align: right)
  counter(page).update(1)

  // Table of contents.
  show outline.entry: outrageous.show-entry.with(font: ("TeX Gyre Heros", auto))

  outline()

  pagebreak(weak: false)

  // --- Main Chapters ---

  set page(
    header: grid(
      columns: (1fr, 1fr),
      inset: (
        x: 0pt,
        y: 7pt,
      ),
      align(left)[_ #title _],
      align(right)[#image("images/logo.png", width: 30%)],
      grid.hline()
    ),
  )

  set page(numbering: "1", number-align: right)
  counter(page).update(1)

  set par(justify: true)

  body

  // --- Appendixes ---

  set page(header: [])

  // restart page numbering using roman numbers
  set page(numbering: "I", number-align: right)
  counter(page).update(1)

  [= Verzeichnisse]

  show heading: it => [
    #it.body
  ]

  // --- Bibliography ---
  set par(leading: 0.7em, first-line-indent: 0em, justify: true)
  heading(outlined: false, numbering: none)[Literaturverzeichnis]
  bibliography(
    title: none,
    style: "partial/iso690-author-date-de.csl",
  )

  // List of figures.
  outline(
    title: "Abbildungsverzeichnis",
    target: figure.where(kind: image),
  )

  // List of tables.
  outline(
    title: "Tabellenverzeichnis",
    target: figure.where(kind: table),
  )

  // List of code.
  outline(
    title: "Codeverzeichnis",
    target: figure.where(kind: "code"),
  )
}
