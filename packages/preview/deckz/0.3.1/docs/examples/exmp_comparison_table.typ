#let cards-window(body) = block(fill: white, width: 100%, inset: 5pt, body)

#block(fill: gray.lighten(60%), inset: 5pt, breakable: false)[

  #let example-cards = ("AS", "5H", "10C", "QD")

  #text(blue)[`inline`] --- A minimal format where the rank and suit are displayed directly within the flow of text; perfect for quick references.
  #cards-window[
    #deckz.line(..example-cards, format: "inline", width: 100%)
  ]

  #text(blue)[`mini`] --- The smallest visual format: a compact rectangle showing the rank at the top and the suit at the bottom.
  #cards-window[
    #deckz.line(..example-cards, format: "mini", width: 100%)
  ]

  #text(blue)[`small`] --- A slightly larger card with rank indicators on opposite corners and a central suit symbol; ideal for tight layouts with better readability.
  #cards-window[
    #deckz.line(..example-cards, format: "small", width: 100%)
  ]

  #text(blue)[`medium`] --- A fully structured card layout featuring proper suit placement and figures. Rank and suit appear in two opposite corners, offering a realistic visual.
  #cards-window[
    #deckz.line(..example-cards, format: "medium", width: 100%)
  ]

  #text(blue)[`large`] --- The most detailed format, with corner summaries on all four corners and an expanded layout; great for presentations or printable decks.
  #cards-window[
    #deckz.line(..example-cards, format: "large", width: 100%)
  ]
]