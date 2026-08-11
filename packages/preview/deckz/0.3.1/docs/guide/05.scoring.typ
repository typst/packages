#import "../template.typ": *

== Arrange and score cards
<subsec:scoring>

Up to this point, all cards have been "treated equally", without regard to their suit or rank. However, in most card games, the arrangement and value of cards are crucial -- winning often depends on how cards are sorted and scored, and specific combinations can determine the outcome.

For this reason, the *#primary[`arr`] and #primary[`val`] sub-modules* of DECKZ include *sorting* and *scoring* functions respectively, for organizing cards and evaluating hands according to the rules of the most popular card games (especially poker).

=== Sort hands with #primary(`arr`)

The @cmd:deckz.arr:sort function *organizes cards array by different criteria*. The resulting array of cards can be passed to a function for group visualization, such as @cmd:deckz:hand, to display the cards in a specific order.

#example(breakable: true, side-by-side: false)[
	```typ
	// Define an unordered set of cards
	#let cards = ("AS", "KH", "QD", "JC", "10S", "2H")

	// Sort by standard order (suit first, then rank)
	#deckz.line(..deckz.arr.sort(cards, by: "order"), format: "small")

	// Sort by score (high cards first: A, K, Q, J, 10...)
	#deckz.line(..deckz.arr.sort(cards, by: "score"), format: "small")
	```
]

Sometimes it can be useful to *count or group cards in the hand* according to their suit or rank, for example to display them in a more organized way. 
The @cmd:deckz.arr:group-ranks and @cmd:deckz.arr:group-suits functions can be used for this purpose.

#example(breakable: true, side-by-side: false)[
	```typ
	#let hand = ("AS", "AH", "KS", "KH", "QD", "5H")

	// Count occurrences of each rank
	Count the number of each rank in a hand:
	#deckz.arr.count-ranks(hand)

	// Group cards by rank or suit
	Group cards by *rank*:
	#for (rank, cards) in deckz.arr.group-ranks(hand).pairs() [
		- #rank: #cards
	]
	Group cards by *suit*:
	#for (suit, cards) in deckz.arr.group-suits(hand).pairs() [
		- #suit: #cards
	]
	```
]

=== Score hands with #primary(`val`)

DECKZ includes functions to *evaluate hands of cards* according to the rules of the most common card games.
More specifically, it is possible to assess *poker hands* with three types of functions:

- *Detection*: check if a hand _contains_ a specific combinations.
- *Validation*: check if a hand _exactly matches_ a specific combination.
- *Hand Extraction*: extract _all possible combinations_ of a specific type from a hand.

#bts-info[
	The combinations recognized by DECKZ are the standard poker combinations:
	#let combos = (
		"high-card": "The singular highest card of the hand",
		"pair": "A pair of cards with the same rank",
		"two-pairs": "Two pairs of cards with the same rank",
		"three-of-a-kind": "Three cards of the same rank",
		"straight": "Five cards in a sequence, regardless of suit",
		"flush": "Five cards of the same suit",
		"full-house": "Three cards of one rank and two cards of another",
		"four-of-a-kind": "Four cards of the same rank",
		"straight-flush": "Five cards in a sequence, all of the same suit",
		"five-of-a-kind": "Five cards of the same rank (only possible with multiple copies of the same card)",
	)
	#let hand = ("3S", "3H", "KS", "KH", "QD", "JC", "9H", "9S", "9C", "10D", "4S", "4H", "4C", "4D", "10S", "JS", "10S", "7S", "8S", "AS", "AS", "AH", "AC", "AD")
	#table(
		columns: 3,
		stroke: white,
		primary[*Combination*],
		primary[*Description*],
		primary[*Example*],
		..combos.pairs().map(
			((id, desc)) => {return (
				[*#id*],
				[#desc],
				stack(
					dir: ltr,
					spacing: 10pt,
					..deckz.val.extract(id, hand).at(0, default: ()).map(deckz.mini)
				)
			)}
		).flatten()
	)
]

==== Detection and validation

DECKZ offers many functions to check if a hand *contains* (#codly.local[`has-X`]) or *exactly matches* (#codly.local[`is-X`]) a specific combination `X` (where `X` is one of the combinations defined in the table above).

Detection and validation functions return a `bool` value, and can be used as follows:

#example(breakable: true, side-by-side: false)[
	```typ
	#let cards = ("AS", "AH", "KD", "QC", "JH")
	#deckz.val.has-pair(cards) // true (contains a pair)
	#deckz.val.is-pair(cards) // false (5 cards, not exactly 2)
	#deckz.val.is-pair(("AS", "AH")) // true (exactly 2 matching cards)
	```
]

==== Extraction of a given combination

DECKZ offers many functions to *extract* all possible combinations of a specific type from a hand. The return type is an `array` of all combinations found, which can be used to display the cards in a specific order or to evaluate the hand.

#example(breakable: true, side-by-side: false)[
	```typ
	#let available-cards = ("AS", "AH", "KS", "KH", "QD")

	// Get all possible pairs from these cards
	All possible pairs:
	#for pair in deckz.val.extract-pair(available-cards) [ - #pair ]

	// Find the best hand automatically
	Best hand combination:
	#deckz.val.extract-highest(available-cards).first()
	```
]

The general @cmd:deckz.val:extract function can be used to extract any combination specified with the @cmd:deckz.val:extract.scoring-combination parameter.

#example(breakable: true, side-by-side: false)[
	```typ
	#let some-cards = ("AS", "3H", "KS", "3C", "2C", "3S", "6H", "7H", "3D")

	// These are equivalent:
	Extracted combinations:
	#deckz.val.extract("three-of-a-kind", some-cards)

	Extracted combinations:
	#deckz.val.extract-three-of-a-kind(some-cards)
	```
]

#bts-info[
	All extraction functions are *stable functions*, meaning they evaluate the hand in a consistent order: if two cards have a certain order, their relative order will be preserved in the output.
	This is particularly useful for games where the order of cards matters.
]

