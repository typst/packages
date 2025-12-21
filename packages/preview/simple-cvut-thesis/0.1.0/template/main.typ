// ------------- Nastavení dokumentu -------------
#set page(
  paper: "a4",
  margin: 3cm,
  numbering: "1"
)
#set text(
  lang: "cs",
  region: "cz",
  size: 12pt,
)
#show heading.where(level: 1): it => block[#text(size: 18pt, it)]
#show heading.where(level: 2): it => block[#text(size: 16pt, it)]
#show heading.where(level: 3): it => block[#text(size: 14pt, it)]
#show heading.where(level: 4): it => block[#text(size: 12pt, it)]

#show raw.where(block: true): it => align(block( // nastavení code bloku
  stroke: rgb("#ddd"),
  fill: rgb("#fafafa"),
  inset: 10pt,
  radius: 0.5em,
  above: 2em,
  below: 2em,
  it
), center)

#set par(justify: true, first-line-indent: 2em) // hezky rádoby do bloku

#show figure: it => {it; v(0.4em)} // trošku větsí mezera za obrázkem
#set heading(numbering: "1.")

// ------------- Dokument -------------
#include "titulnistrana.typ"
#include "obsah.typ"
#counter(page).update(1) // reset stran
#include "text.typ"

// ------------- Citace -------------
#pagebreak()
#block()[
  #set par(justify: false) // citace aby se neroztahovaly
  #bibliography(
    "citace.yaml",
    title: "Odkazy",
    style: "the-lancet", // 1 = "the-lancet", [1] = "angewandte-chemie", i pod čarou = "gb-7714-2015-note"
    full: true
  )
]
