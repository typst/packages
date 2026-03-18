#import "@preview/equate:0.3.1": equate

#let tapestry(
  title: [],
  year: [],
  author: "",
  doc,
) = {
  set document(
    title: title,
    author: author,
  )

  set page(
    paper: "a5",
    margin: (x: 1.25cm, y: 1.75cm),
    header: [
      #set text(
      size: 9pt,
    )
      _ #title _
      #h(1fr)
      #year
    ],
    header-ascent: 42.5%,
  )

  set heading(
    numbering: "1.",
  )
  show heading: set block(below: 1em)
  show heading: smallcaps

  set text(
    font: "New Computer Modern",
    size: 11pt
  )

  set math.equation(
    numbering: "(1.1)",
    supplement: "Eq."
  )
  show: equate.with(
    number-mode: "label",
    sub-numbering: true
  )

  outline()

  linebreak()

  doc
}

#import "@preview/physica:0.9.5" : vecrow, va, vu, vb, dd, dv, pdv, hbar, grad, div, curl
