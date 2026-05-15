#import "../lib.typ": supported-languages, supported-language-count

#set page(width: 180mm, height: auto, margin: 10mm)
#set text(size: 9pt)

= Supported languages

This package exposes #supported-language-count supported fastText language codes.

#let cols = 8
#let rows = calc.ceil(supported-languages.len() / cols)

#table(
  columns: (1fr,) * cols,
  inset: 4pt,
  align: center,

  ..range(rows * cols).map(i => {
    if i < supported-languages.len() {
      [#raw(supported-languages.at(i))]
    } else {
      []
    }
  })
)
