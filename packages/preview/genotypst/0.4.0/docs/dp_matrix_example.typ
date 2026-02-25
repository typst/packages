#import "../src/lib.typ": *

#set page(
  fill: none,
  height: auto,
  width: 200mm,
  margin: 0cm,
)

#set align(center)
#set text(font: "Source Sans 3")
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
  dna_alignment.dp-matrix.values,
  path: dna_alignment.traceback-paths.at(0),
  arrows: dna_alignment.dp-matrix.arrows,
)
