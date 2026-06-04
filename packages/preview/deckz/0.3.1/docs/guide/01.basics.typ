#import "../template.typ": *

== Basic usage

The main entry point to start using DECKZ visualization features is the @cmd:deckz:render function. Here's an example of how to use it:

```side-by-side
#deckz.render("7D", format: "large")
```

As you can see, the function has been called with two arguments, and it produced a large card with the rank #value(7) and the suit of #text(deckz.suits.diamond.color)[diamonds #emoji.suit.diamond].

+ The first argument is the *card identifier* as a string (@cmd:deckz:render.card). Use *standard short notation* like `"AH"`, `"10S"`, `"QC"`, etc., where the first letter(s) indicates the *rank*, and the last letter the *suit*.

	- *Available ranks*: `A`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `J`, `Q`, `K`.
	- *Available suits*: `H` (Hearts #text(red)[#emoji.suit.heart]), `D` (Diamonds #text(red)[#emoji.suit.diamond]), `C` (Clubs #emoji.suit.club), `S` (Spades #emoji.suit.spade).

	#bts-info[
		Card identifier is *case-insensitive*, so `"as"` and `"AS"` are equivalent and both represent the _Ace of Spades_.
	]

+ The second argument is optional and specifies the *format* of the card display (@cmd:deckz:render.format). If not provided, DECKZ functions will typically default to `medium`, which is a well-balanced card size suitable for most uses.

	To learn more about the available formats, see @subsubsec:formats.


=== Formats
<subsubsec:formats>

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

#example(breakable: true, side-by-side: false)[
	```typ
	#deckz.render("5S", format: "inline")
	#deckz.render("5S", format: "mini")
	#deckz.render("5S", format: "small")
	#deckz.render("5S", format: "medium")
	#deckz.render("5S", format: "large")
	#deckz.render("5S", format: "square")
	```
]

You can use any of these with the *general function* @cmd:deckz:render, or by calling directly the *specific format functions*:
- @cmd:deckz:inline,
- @cmd:deckz:mini, 
- @cmd:deckz:small, 
- @cmd:deckz:medium, 
- @cmd:deckz:large, 
- @cmd:deckz:square.

#bts-info[All formats are *responsive to the current text size*: they scale proportionally using #{`em`} units, making them adaptable to different layouts and styles.

For reference, the summary view contained in larger formats (i.e. the symbols representing the rank and suit of a cards, usually placed in the card's corners) *scale with the current text size*, ensuring that card details remain readable by being no smaller than #value(1em) in size.
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

Alternatively, you can use the general @cmd:deckz:render function with #value("back") as the card code, which is equivalent.

#bts-info[
	Any string other than a valid card identifier will be interpreted as a request for the back of the card (except for the empty string). The convention, however, is to use the string #value("back") for clarity.
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