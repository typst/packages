#import "@preview/showybox:2.0.1"

// Fonts definition
#let mainfont = "Spectral"
#let sansfont = "Marianne"

// Colors definition
#let ofbdarkgreen      = rgb("#0E823A")
#let ofbdarkblue       = rgb("#003A76")
#let ofbsemigreen      = rgb("#A4A64B")
#let ofbsemiblue       = rgb("#0083CB")
#let ofbgreen          = rgb("#6AB96F")
#let ofbblue           = rgb("#00A6E2")
#let ofbsemilightgreen = rgb("#9FCA7E")
#let ofbsemilightblue  = rgb("#5BC5F2")
#let ofblightgreen     = rgb("#C4D89B")
#let ofblightblue      = rgb("#99D7F7")
#let ofbred            = rgb("#C2133E")
#let ofborange         = rgb("#ED6A53")
#let ofblightorange    = rgb("#F39655")
#let ofbyellow         = rgb("#FFD744")
#let ofbdarkgold       = rgb("#564949")
#let ofbsemigold       = rgb("#9A7B67")
#let ofbgold           = rgb("#CC9F72")
#let ofblightgold      = rgb("#EAC198")
#let palettea  = ofbdarkblue
#let paletteb  = ofbdarkgreen
#let palettec  = ofbdarkgold
#let paletted  = ofbred
#let palettee  = ofbsemigreen
#let palettef  = ofbsemiblue
#let palettela = ofblightblue
#let palettelb = ofblightgreen
#let palettelc = ofblightgold
#let paletteld = ofbyellow
#let paletteda = ofbdarkblue
#let palettedb = ofbdarkgreen
#let palettedc = ofbdarkgold
#let palettedd = ofbred

// Tables
#let mytable(..args)={
  set table(
    fill: (_,y) => if (y==0) {paletteda} else if calc.odd(y) {palettela.lighten(50%)} else {none},
    stroke: (_y,y) => if (y==0) {(right: 0.1pt + paletteda)} else if calc.odd(y) {(right: 0.1pt + palettela.lighten(50%))} else {none},
  )
  show table.cell.where(y:0): set text(fill:white, weight:"bold")
  align(center,table(
    align: horizon,
    rows: auto,
    table.hline(stroke: palettea + 0.5pt),
    ..args,
    table.hline(stroke: palettea + 0.5pt),
  ))
}

// Blocks
#let myblock(mytitle,..args)={
  showybox.showybox(
    frame:(
      border-color: palettea,
      title-color: white,
      body-color: palettela.lighten(80%),
      width: 0.75pt,
    ),
    title-style:(
      weight: "bold",
      boxed-style: (:),
      color: palettea,
    ),
    body-style: (color: rgb("#666666")),
    sep: (dash: none),
    shadow: (offset: 3pt),
    breakable: true,
    title: mytitle,
    ..args
  )
}

#let _conf(
  meta: (:),
  doc
) = {
  // Metadata
  set document(title: meta.at("title"),author: meta.at("authors"))

  // Main styling
  set text(font: (mainfont, "Linux Libertine"), size: 10pt, fill: rgb("#666666"), lang: "fr", region: "FR")
  set par(justify: true)
  show strong: set text(weight: "bold", fill: palettea)

  // Lists
  set list(
    indent: 1em,
    tight: false,
    marker: ([#set text(fill: palettea);▶],[#set text(fill: paletteb);--],[#sym.star.filled]),
  )
  set enum(
    indent: 1em,
    tight: false,
    numbering: n=>text(fill:palettea,[#n.]),
  )

  doc
}
