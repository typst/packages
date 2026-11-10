#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/codly-languages:0.1.10": codly-languages

#let code-styles(doc) = {
  show: codly-init
  codly(
    languages: codly-languages,
    fill: rgb("#fafafa"),
  )

  set math.equation(numbering: "(1)")
  // show math.equation: set text(font: "Fira Math")
  show raw: set text(font: "Fira Code") //Code blocks

  doc
}
