#import "../template.typ": *

// Complete documentation for DECKZ functions and features
= Documentation
<sec:documentation>


== Card visualization
This section provides a comprehensive overview of the DECKZ package's *card visualization* capabilities. It presents the available formats and how to use them effectively.
#show-module(("view/format", "view/back"))


#pagebreak()
== Group visualization
This section covers the *group visualization* features of the DECKZ package, i.e. all functions that allow you to visualize groups of cards, such as hands, decks, and heaps.
#show-module("view/group")


#pagebreak()
== Data
This section provides an overview of the *data structures* used in the DECKZ package, including suits, ranks, and cards. It explains how these data structures are organized and how to access them.
#show-module(("data/suit", "data/rank", "logic/structs"))
//#show-module("data/style")


#pagebreak()
== Randomization
The DECKZ package includes essential *randomization features* for card games, such as shuffling and drawing random cards from a deck. However, since *Typst* is a pure functional language, true randomness is not available; instead, DECKZ uses the #universe("suiji") package to generate pseudo-random numbers.

This section explains how to use these randomization tools within DECKZ, describes the underlying concepts, and provides practical guidance for integrating randomness into your projects.
Randomization functions are available under the #primary[`deckz.mix`] namespace, and they include:
#show-module("logic/mix", submodule: "mix")

#pagebreak()
== Arranging hands
This section covers the *sorting and organizing functions* available in the #primary[`arr`] module in the DECKZ package.
It explains how to sort cards by rank, suit, and other criteria, providing a foundation for building more complex card games and applications.
#show-module("logic/sort", submodule: "arr")


#pagebreak()
== Evaluating hands
This section provides an overview of the *scoring functions* from the #primary[`val`] module of the DECKZ package, which are essential for evaluating hands in card games. Such functions are helpful for assessing the value of a hand based on various criteria and combinations, such as n-of-a-kind, flushes, and straights.
#show-module("logic/score", submodule: "val")


#pagebreak()
== Language-aware card symbols
DECKZ automatically adapts the rendering of card rank symbols based on the document's language. This process is seamless: users only need to set the desired language using the `text` command, and DECKZ will adjust the symbols accordingly. No additional configuration is required.

#let build-lang-row(lang) = {
	return (
		text(weight: "bold")[
			#primary(smallcaps(lang))
		],
		..deckz.ranks.values().map(rank-data => [
				#set text(lang: lang)
				#text(size: 1.2em, weight: "medium", rank-data.symbol)
				#linebreak()
				#text(size: 0.5em)[#rank-data.name]
			]),
	)
}

The current version of DECKZ supports the following *languages*:

#show table.cell: set align(center)
#show table.cell: set text(font: "Roboto Slab", size: 0.9em)
#table(
	stroke: gray.transparentize(70%) + 1pt,
	columns: (1cm, ) + (1fr,) * 13,
	..build-lang-row("en"),
	..build-lang-row("it"),
	..build-lang-row("fr"),
	..build-lang-row("de"),
	..build-lang-row("ru"),
)

The localization is powered by the #universe("linguify") package, thanks to the generous contribution of the users who helped translating card names and symbols.

#example(breakable: true, side-by-side: true)[
	```typ
	#let seq = ("10C", "JH", "QS", "KD", "AC")

	#set text(lang: "en")
	#deckz.line(..seq, format: "small")

	#set text(lang: "it")
	#deckz.line(..seq, format: "small")

	#set text(lang: "fr")
	#deckz.line(..seq, format: "small")
	```
]

