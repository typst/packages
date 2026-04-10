#text(white, font: "Oldenburg", size: 10pt)[
  #block(fill: aqua.darken(40%), inset: 4mm, radius: 2mm)[
    #deckz.hand(
      angle: 270deg, 
      width: 5.8cm, 
      format: "large", 
      noise: 0.05, 
      ..deckz.deck52
    )
    #place(center + horizon)[#text(size: 20pt, baseline: 8pt)[Deckz]]
  ]
]