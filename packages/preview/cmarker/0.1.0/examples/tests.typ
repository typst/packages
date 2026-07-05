#import "../lib.typ" as cmarker

#cmarker.render(
  read("tests.md"),
  blockquote: box.with(stroke: (left: 1pt + black), inset: (left: 5pt, y: 6pt)),
  raw-typst: true,
  show-source: false,
)
