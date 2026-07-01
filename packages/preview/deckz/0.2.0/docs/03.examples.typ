#import "template.typ": *

The following examples showcase more advanced and interesting use cases of DECKZ. In this Section, you can find how DECKZ can be used to represent real game states, compare card formats, and display entire decks in creative ways.

== Displaying the current state of a game

You can use DECKZ to display the *current state of a game*, such as the cards in hand, the cards on the table, and the deck.

#example(breakable: true)[
	#raw(
		lang: "typ",
		read("examples/exmp_current_state.typ"),
	)
]

#pagebreak()
== Comparing different formats

You can use DECKZ to *compare different formats* of the same card, or to show how a card looks in different contexts.

#example(breakable: true)[
	#raw(
		lang: "typ",
		read("examples/exmp_comparison_table.typ"),
	)
]

#pagebreak()
== Displaying a full deck

You can use DECKZ to display a *full deck of cards*, simply by retrieving the `deckz.deck52` array, which contains all 52 standard playing cards.

#example(breakable: true)[
	#raw(
		lang: "typ",
		read("examples/exmp_deck_circle.typ"),
	)
]