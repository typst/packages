#import "../template.typ": *

== Customize cards
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
DECKZ will allow you to define *custom suits*, so you can use your own symbols or images instead of the standard hearts, diamonds, clubs, and spades.

Even though this feature is not yet implemented, you can still use custom suits by defining your own `show` rule for the emoji suits. In fact, DECKZ uses the `emoji.suit.*` symbols to render the standard suits, so you can override them with your own definitions.

For example, if you want to use a _croissant emoji_ #emoji.croissant as a custom suit instead of _diamonds_ #emoji.suit.diamond, you can define it like this:

```example
#show emoji.suit.diamond: text(size: 0.7em, emoji.croissant)
#deckz.hand(..deckz.cards52.diamond.values().slice(0, 7))
```

#bts-info[
	The *resizing* of the emoji in the previous example is used to make it fit better in the card layout.
	When you're defining your own `show` rule for suits customization, you may need to adjust their size as needed.
]

#coming-soon-feature[
	Custom suits will be better supported in the future releases, allowing you to define them more easily and consistently across the deck.
]