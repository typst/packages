#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": codly-languages

#let code-styles(doc) = {
  // A list of fills cycles per line (zebra striping, as in codly 1.x).
  show: codly.theme("thesis", fill: (luma(240), rgb("#fafafa")))
  show: codly.lang-set_(languages: codly-languages)
  show raw.where(block: true): codly.new

  set math.equation(numbering: "(1)")
  // show math.equation: set text(font: "Fira Math")
  show raw: set text(font: "Fira Code") //Code blocks

  doc
}
