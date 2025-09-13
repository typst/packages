#set table(stroke: 1pt + white, fill: white)
#set text(font: "Arvo", size: 0.8em)
#block(fill: gray.lighten(60%), inset: 10pt, breakable: false)[

  #let example-cards = ("AS", "5H", "10C", "QD")

  #text(blue)[`inline`] --- A minimal format where the rank and suit are displayed directly within the flow of text; perfect for quick references.
  #table(align: center, columns: (1fr,) * 4, 
    ..example-cards.map(deckz.inline),
  )

  #text(blue)[`mini`] --- The smallest visual format: a compact rectangle showing the rank at the top and the suit at the bottom.
  #table(align: center, columns: (1fr,) * 4, 
    ..example-cards.map(deckz.mini),
  )

  #text(blue)[`small`] --- A slightly larger card with rank indicators on opposite corners and a central suit symbol; ideal for tight layouts with better readability.
  #table(align: center, columns: (1fr,) * 4, 
    ..example-cards.map(deckz.small),
  )

  #text(blue)[`medium`] --- A fully structured card layout featuring proper suit placement and figures. Rank and suit appear in two opposite corners, offering a realistic visual.
  #table(align: center, columns: (1fr,) * 4, 
    ..example-cards.map(deckz.medium),
  )

  #text(blue)[`large`] --- The most detailed format, with corner summaries on all four corners and an expanded layout; great for presentations or printable decks.
  #table(align: center, columns: (1fr,) * 4, 
    ..example-cards.map(deckz.large),
  )
]