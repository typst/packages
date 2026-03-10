// Defining players and their hands
#let players = ("Alice", "Bob", "Carol", "David")
#let (players-hands, board-cards) = deckz.mix.split(
  deckz.deck52, // Start with a standard deck of 52 cards
  size: ((players.len(), 2), 5), // 2 cards per player + 5 board cards
  rest: false,
)

#set align(center)
#set text(fill: white, size: 13pt, font: "Arvo")

#block(
  fill: olive,
  inset: 15pt,
  radius: 5pt,
  breakable: false,
)[
  // Board cards
  *Board*
  #deckz.hand(
    format: "small",
    width: 4cm,
    angle: 20deg,
    noise: 0.2,
    ..board-cards
  )
  // Displaying the deck of cards
  #place(right + top)[
    #deckz.deck(
      format: "small",
      angle: 90deg,
      noise: 0.2,
      "back"
    )
  ]
  
  #v(1cm)
  #set table.cell(
    fill: olive.darken(20%),
    stroke: olive.darken(10%) + 2pt,
  )

  // Players' hands
  #table(
    columns: players.len(),
    column-gutter: 1fr,

    ..players-hands
      .zip(players)
      .map(((hand, player)) => [
        #player
        #deckz.hand(
          format: "small",
          width: 1cm,
          angle: 30deg,
          noise: 0.4,
          ..hand
        )
      ])
  )
]

#set align(left)
#set text(fill: black, size: 12pt)

Which is the *best hand* each player can make?
#for (player, hand) in players.zip(players-hands) [

  - *#player*
  #box(
    fill: olive,
    inset: 8pt,
    radius: 15%,
  )[
    #(hand + board-cards).map(deckz.mini).join("  ")
  ]
  $stretch(=>)^"  Best hand  "$
  #let best = deckz.val.extract-highest(hand + board-cards, sort: true).first()
  #box(
    fill: none, 
    stroke: (paint: green, thickness: 3pt, dash: "dashed"), 
    inset: 8pt, 
    radius: 45%,
  )[
    #best.map(deckz.mini).join("  ")
  ]
]
