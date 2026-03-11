// Outline page layout for table of contents, list of figures, and list of tables.

#import "config.typ"

#let outline-page(title, ..args) = page(numbering: "i")[
  #set outline.entry(fill: repeat[.])
  #align(center, text(size: config.heading-size, weight: "bold")[#title])
  #v(1.5em)
  #outline(title: none, indent: 2em, ..args)
]
