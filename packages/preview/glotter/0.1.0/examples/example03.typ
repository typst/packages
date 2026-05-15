#import "../lib.typ": *

#set page(width: 45mm, height: auto, margin: 2mm)

#let sample = "שלום עולם"

*Plain text:*

#sample

*Manual Typst:*

#text(lang: "he")[#sample]

*With glotter:*

#auto-text[#sample]