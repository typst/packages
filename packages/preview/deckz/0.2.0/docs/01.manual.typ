#import "template.typ": *

DECKZ is a Typst package designed to display playing cards in the classic poker style, using the standard French suits (hearts #text(red, emoji.suit.heart), diamonds #text(red, emoji.suit.diamond), clubs #text(black, emoji.suit.club), and spades #text(black, emoji.suit.spade)). 
Whether you need to show a single card, a hand, a full deck, or a scattered heap, DECKZ provides flexible tools to visualize cards in a variety of formats and layouts. The package is ideal for games, teaching materials, or any document where clear and attractive card visuals are needed.

DECKZ offers multiple display formats, ranging from compact inline symbols to detailed, full-sized cards—so you can adapt the appearance to your specific use case.
It also includes functions for visualizing groups of cards, such as hands, decks, and heaps, making it easy to represent typical card game scenarios.

This manual is organized in three parts: 
+ @sec:guide helps you get started with the main features; 
+ @sec:documentation provides detailed documentation for each function, serving as a reference; 
+ @sec:examples presents practical examples that combine different features. 
At the end, you'll find credits and instructions for contributing to the project.

This manual presents the most recent DECKZ release as of today: *#doc.package.version*.

== Importing the package

To start using DECKZ in your Typst document, simply *import the package* with:

#show-import(imports: none)

This makes all DECKZ functions available under the #text(purple.darken(30%))[`deckz`] namespace.

== Basic usage

The main entry point is the @cmd:deckz:render function:

```side-by-side
#deckz.render("7D", format: "large")
```

The first argument is the *card identifier* as a string (@cmd:deckz:render.card). Use standard short notation like `"AH"`, `"10S"`, `"QC"`, etc., where the first letter(s) indicates the *rank*, and the last letter the *suit*.

- *Available ranks*: `A`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`.
- *Available suits*: `H` (Hearts #text(red)[#emoji.suit.heart]), `D` (Diamonds #text(red)[#emoji.suit.diamond]), `C` (Clubs #emoji.suit.club), `S` (Spades #emoji.suit.spade).

#info-alert[
	Card identifier is *case-insensitive*, so `"as"` and `"AS"` are equivalent and both represent the Ace of Spades.
]

The second argument is optional and specifies the *format* of the card display (@cmd:deckz:render.format). If not provided, DECKZ functions will typically default to `medium`.


=== Formats

DECKZ provides multiple *display formats* to fit different design needs:

#table(
	columns: 2,
	stroke: 1pt + gray,
	[*Format*],[*Description*],
	[`inline`],[A minimal format where the rank and suit are shown directly inline with text. 
	/*It works well for references like:
	```side-by-side
	you drew a #deckz.inline("KH")
	```*/
	],
	[`mini`],[The smallest visual format: a tiny rectangle with the rank on top and the suit at the bottom.],
	[`small`],[A compact but clear card with rank in opposite corners and the suit centered.],
	[`medium`],[A full, structured card with proper layout, two corner summaries, and realistic suit placement.],
	[`large`],[An expanded version of `medium` with corner summaries on all four sides for maximum readability.],
	[`square`],[A balanced 1:1 format with summaries in all corners and the main figure centered.]
)

Here's an example of how the same card looks in different formats:

```example
#deckz.render("5S", format: "inline") #h(1fr)
#deckz.render("5S", format: "mini") #h(1fr)
#deckz.render("5S", format: "small") #h(1fr)
#deckz.render("5S", format: "medium") #h(1fr)
#deckz.render("5S", format: "large") #h(1fr)
#deckz.render("5S", format: "square")
```

You can use any of these with the *general function* @cmd:deckz:render, or by calling directly the *specific format functions*:
- @cmd:deckz:mini, 
- @cmd:deckz:small, 
- @cmd:deckz:medium, 
- @cmd:deckz:large, 
- @cmd:deckz:square.

#info-alert()[All formats are *responsive to the current text size*: they scale proportionally using #{`em`} units, making them adaptable to different layouts and styles.

For reference, the summaries in larger formats (i.e. the symbols representing the rank and suit of a cards, usually placed in the card's corners) scale with the current text size, ensuring that card details remain readable even when the surrounding text is small.
]

```side-by-side
#deckz.mini("2C")
#deckz.medium("JH")
#deckz.square("AD")

are equivalent to

#deckz.render("2C", format: "mini")
#deckz.render("JH", format: "medium")
#deckz.render("AD", format: "square")
```

If you want more examples of how to use these formats, check out @sec:examples at the end of this document.


=== Back of cards

To render the *back of a card*, you can use the @cmd:deckz:back function. This will display a generic card back design, which can be useful for games or when you want to hide the card's face.

```side-by-side
This is the back of a card:
#deckz.back(format: "small")
```

Alternatively, you can use the general @cmd:deckz:render function with `"back"` as the card code, which is equivalent.

#info-alert[
	Any string other than a valid card identifier will be interpreted as a request for the back of the card (except for the empty string). The convention, however, is to use the string `"back"` for clarity.
]

```side-by-side
// These are all equivalent:
#deckz.medium("back")
#deckz.render("back", format: "medium")
#deckz.back(format: "medium")
```

#coming-soon-feature[
	Currently, the back of cards uses a fixed design. In future updates, DECKZ will allow you to customize the back of cards and decks.
]

== Visualize cards together
DECKZ also provides convenient functions to render *entire decks* or *hands of cards*. Both functions produce a _CeTZ_ canvas, which can be used in any context where you need to display multiple cards together.

=== Decks
The deck visualization is created with the @cmd:deckz:deck function, which takes a card identifier as an argument. It renders a full deck of cards, with the specified card on top.

```side-by-side
#deckz.deck("6D")
```

In the @cmd:deckz:deck function, you can also specify different parameters to *customize deck appearance*; we list here some of them. 

For more information and in-depth explanations, see the documentation in @sec:documentation.

- @cmd:deckz:deck.angle -- The direction towards which the cards are shifted.
- @cmd:deckz:deck.height -- The height of the deck, represented as a `length`.
- @cmd:deckz:deck.format -- The format of the cards in the deck. It can be any of the formats described above, such as `inline`, `mini`, `small`, `medium`, `large`, or `square`.

```example
#stack(
  dir: ltr,
  spacing: 1cm,
  deckz.deck("8S"),
  deckz.deck("8S", angle: 90deg, height: 2.5cm),
  deckz.deck("8S", angle: 180deg, height: 8pt, format: "small"),
  deckz.deck("8S", angle: 80deg, height: 18mm, noise: 0.5)
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
  deckz.hand(width: 5cm, noise: 2, format: "small", ..my-hand),
  deckz.hand(angle: 180deg, width: 3cm, noise: 0.5, format: "large", ..(my-hand + my-hand)),
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



== Card customization
DECKZ allows for some *customization of the card appearance*, such as colors and styles.

#coming-soon-feature[
	This functionality is not fully supported yet: please, come back for the next releases.
]

/*
Variant Colors: to better distinguish same-color suits, Deckz will support variant colors for each suit.

![Example of cards with custom colors.](docs/img/future_variant_colors.png)

> *Note*. The color scheme shown above is inspired by the game *Balatro*. The hand displayed is the initial hand from a game started with the seed "DECKZ" — not a bad opening, huh? 😉
*/

=== Custom Suits
DECKZ will also allow you to define custom suits, so you can use your own symbols or images instead of the standard hearts, diamonds, clubs, and spades.

Even though this feature is not yet implemented, you can still use custom suits by defining your own `show` rule for the emoji suits. In fact, DECKZ uses the `emoji.suit.*` symbols to render the standard suits, so you can override them with your own definitions.

For example, if you want to use a _croissant emoji_ #emoji.croissant as a custom suit instead of _diamonds_ #emoji.suit.diamond, you can define it like this:

```example
#show emoji.suit.diamond: text(size: 0.7em, emoji.croissant)
#deckz.hand(..deckz.deck52.slice(26, 32))
```

#info-alert[
	The *resizing* of the emoji in the previous example is used to make it fit better in the card layout.
	When you're defining your own `show` rule for suits customization, you may need to adjust their size as needed.
]