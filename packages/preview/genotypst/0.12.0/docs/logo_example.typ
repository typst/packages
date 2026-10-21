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

#let protein_msa = parse-fasta(read("/docs/data/msa.afa"))

#render-sequence-logo(
  protein_msa,
  start: 100,
  end: 135,
)
