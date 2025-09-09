#import "../template.typ": *

== Visualize cards together
DECKZ also provides convenient functions to render *entire decks* or *hands of cards*. Both functions produce a _CeTZ_ `canvas` from the #universe("cetz") package, which can be used in any context where you need to display multiple cards together.

=== Decks
The deck visualization is created with the @cmd:deckz:deck function, which takes a card identifier as an argument. It renders a full deck of cards, with the specified card on top.

```side-by-side
#deckz.deck("6D")
```

In the @cmd:deckz:deck function, you can also specify different parameters to *customize deck appearance*; we list here some of them. 

- @cmd:deckz:deck.angle -- The direction towards which the cards are shifted.
- @cmd:deckz:deck.height -- The height of the deck, represented as a `length`.
- @cmd:deckz:deck.format -- The format of the cards in the deck. It can be any of the formats described above, such as `inline`, `mini`, `small`, `medium`, `large`, or `square`.

For more information and in-depth explanations, see the documentation in @sec:documentation.

```example
#stack(
  dir: ltr,
  spacing: 1cm,
  deckz.deck("8S"),
  deckz.deck("8S", angle: 90deg, height: 2.5cm),
  deckz.deck("8S", angle: 180deg, height: 8pt, format: "small"),
  deckz.deck("8S", angle: 80deg, height: 18mm, noise: 0.1)
)
```

=== Hands
The hand visualization is created with the @cmd:deckz:hand function, which takes a variable number of card identifiers as arguments. It renders a *hand of cards*, with the specified cards displayed side by side.

```example
#deckz.hand("AS", "KS", "QS", "JS", "10S")
```

As can be seen in the example above, the cards are displayed in an arc shape, with the first card on the left and the last card on the right. 

To customize such display, you can use the following parameters (more parameters for @cmd:deckz:hand explained in @sec:documentation):

- @cmd:deckz:hand.angle -- The angle of the arc in degrees, i.e. the angle between the first and last cards' orientations.
- @cmd:deckz:hand.width -- The width of the hand, i.e. the distance between the centers of the first and last card.
- @cmd:deckz:hand.format -- The format of the cards in the deck. It can be any of the formats described above, such as `inline`, `mini`, `small`, `medium`, `large`, or `square`. The default is `medium`.

#example(breakable: true, )[
```example
#let my-hand = ("AS", "KH", "QD", "JS", "JH", "10C", "9D", "6C")

#table(
  columns: (1fr),
  align: center,
  stroke: none,
  deckz.hand(..my-hand),
  deckz.hand(angle: 0deg, width: 4cm, ..my-hand),
  deckz.hand(format: "mini", ..my-hand),
  deckz.hand(width: 5cm, noise: 0.8, format: "small", ..my-hand),
  deckz.hand(angle: 180deg, width: 3cm, noise: 0.1, format: "large", ..(my-hand + my-hand)),
)
```
]

=== Heaps
DECKZ also provides a @cmd:deckz:heap function to display a *heap of cards*. 
This is similar to a hand (@cmd:deckz:hand), but the cards are randomly scattered within a specified area, rather than arranged in an arc. Like the hand, the heap requires a list of card identifiers as arguments, and it can be customized with various parameters.

#example(breakable: true)[
```example
#let (w, h) = (10cm, 10cm)
#box(width: w, height: h, 
	fill: olive, 
	stroke: olive.darken(50%) + 2pt,
)[
	#deckz.heap(format: "small", width: w, height: h, ..deckz.deck52)
]
// Note: The `deckz.deck52` array contains all 52 standard playing cards.
```
]

Some customization options are:
- @cmd:deckz:heap.width -- The width of the heap, i.e. how far apart the cards will be scattered horizontally.
- @cmd:deckz:heap.height -- The height of the heap, i.e. how far apart the cards will be scattered vertically.
- @cmd:deckz:heap.format -- The format of the cards in the heap. It can be any of the formats described above, such as `inline`, `mini`, `small`, `medium`, `large`, or `square`. The default is `medium`.

See also @sec:documentation for the full list of parameters of @cmd:deckz:heap.
