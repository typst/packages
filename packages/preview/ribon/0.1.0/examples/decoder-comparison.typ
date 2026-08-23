#import "@preview/ribon:0.1.0": *

#set page(width: 150mm, height: 58mm, margin: 0pt, fill: white)
#set text(font: "Libertinus Serif", size: 7pt)

#let sequence = "GCGCCUUGAAAGUCCAGAGGACUUGGUUUUAUUGGGUAGUUGAGGUUGGUGGCCCAUCUC"
#let result = analyze(sequence)
#let decoded = data(result)

#assert(decoded.mfe_structure != decoded.centroid_structure)
#assert(decoded.mfe_structure != decoded.mea_structure)
#assert(decoded.centroid_structure != decoded.mea_structure)

#align(center + horizon, grid(
  columns: 3,
  gutter: 4mm,
  ..("mfe", "centroid", "mea").map(which => render(
    result,
    which: which,
    method: "naview",
    width: 46mm,
    height: 54mm,
    node-radius: 2.2pt,
    font-size: 3pt,
    detail: "full",
    numbering: none,
    show-ends: false,
  )),
))
