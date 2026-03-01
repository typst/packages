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

#let protein_msa = parse-fasta(read("/docs/data/msa.afa"))

#render-sequence-logo(
  protein_msa,
  start: 100,
  end: 145,
)
