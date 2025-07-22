#import "../src/lib.typ" as deckz: deck52

#set text(font: "Arvo")

= Deck _inline_
#grid(columns: 13, column-gutter: 1fr, row-gutter: 10pt,
    ..deck52.map(deckz.inline)
)

= Deck _mini_
#grid(columns: 13, column-gutter: 1fr, row-gutter: 10pt,
    ..deck52.map(deckz.mini)
)

= Deck _small_
#grid(columns: 13, column-gutter: 1fr, row-gutter: 10pt,
    ..deck52.map(deckz.small)
)

= Deck _medium_
#grid(columns: 6, column-gutter: 1fr, row-gutter: 10pt,
    ..deck52.map(deckz.medium)
)

= Deck _large_
#grid(columns: 4, column-gutter: 1fr, row-gutter: 10pt,
    ..deck52.map(deckz.large)
)

= Deck _square_
#grid(columns: 4, column-gutter: 1fr, row-gutter: 10pt,
    ..deck52.map(deckz.square)
)
