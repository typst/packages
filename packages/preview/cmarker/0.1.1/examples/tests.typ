#import "../lib.typ" as cmarker
#import "@preview/mitex:0.2.4": mitex

#cmarker.render(
  read("tests.md"),
  blockquote: box.with(stroke: (left: 1pt + black), inset: (left: 5pt, y: 6pt)),
  raw-typst: true,
  math: mitex,
  show-source: false,
)
