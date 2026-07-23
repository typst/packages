#counter(page).update(1) //resettet counter so numbering starts only from section "abstract"

#page(numbering: "I")[
  // -------------------------englische version
  #align(center + horizon)[
  #heading("Abstract", depth: 1, numbering: none)
  #v(0.6em)
  ]
  // english abstract...
  #lorem(60)
  
  #pagebreak()
  
  // -------------------------deutsche version
  #align(center + horizon)[
  // #set par(justify: false) sieht manchmal schöner aus
  #heading("Zusammenfassung", depth: 1, numbering: none)
  #v(0.6em)
  ]
  // deutsche zusammenfassung...
  
  #lorem(60)
]

#pagebreak()