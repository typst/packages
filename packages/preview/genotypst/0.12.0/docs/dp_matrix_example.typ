#import "../src/lib.typ": *

#set page(
  fill: none,
  height: auto,
  width: 200mm,
  margin: 0cm,
)

#let theme = sys.inputs.at("theme", default: "light")
#let text-color = if theme == "dark" { rgb("#f0f6fc") } else { rgb("#000000") }
#set text(font: "Source Sans 3", fill: text-color)
#set align(center)
#show raw: set text(font: "Source Code Pro", size: 9pt)

#let dna_alignment = align-seq-pair(
  "AAT",
  "AACTTG",
  match-score: 3,
  mismatch-score: -1,
  gap-penalty: -1,
  mode: "local",
)

#render-dp-matrix(
  dna_alignment.seq-1,
  dna_alignment.seq-2,
  cell-values: dna_alignment.dp-matrix.scores,
  path: dna_alignment.traceback-paths.at(0),
  arrows: dna_alignment.dp-matrix.arrows,
)
