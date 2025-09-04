#import "../template.typ": *

== Control randomness
<subsec:random>

In card games, always having the same card order, shuffle, or draw every time would be unnatural.  
DECKZ provides functions to manage randomness in both card rendering and manipulation, allowing for varied and realistic outcomes.

In this section, we present functions for *shuffling* or *drawing* random cards from a deck.
Furthermore, randomization is also available in *rendering*: most display functions can take a `noise` argument to change the card's appearance slightly, making it more visually appealing and less uniform.

=== Noise in rendering
*Noise* is a small random variation applied to the card's rendering, which can be useful to create a more dynamic and less uniform appearance.
For instance, we can slightly change a single card rendering by adding *noise* with the @cmd:deckz:render.noise argument:

// This is the standard usage of an example box in this section
#example(breakable: true, side-by-side: false)[
	```typ
	#deckz.render("5S", format: "small") // Default: no noise
	#deckz.render("5S", format: "small", noise: 0.5)
	#deckz.render("5S", format: "small", noise: 1.0)
	```
]

Noise can also be applied to groups of cards, such as *hands* or *decks* (see functions @cmd:deckz:hand and @cmd:deckz:deck):

#example(breakable: true, side-by-side: true)[
	```typ
	// Hand without noise (perfectly aligned)
	#deckz.hand("AH", "KS", "QD", "JC", format: "small", width: 4cm)

	// Hand with moderate noise (slight variations)  
	#deckz.hand("AH", "KS", "QD", "JC", format: "small", width: 4cm, noise: 0.5)

	// Hand with high noise (more chaotic appearance)
	#deckz.hand("AH", "KS", "QD", "JC", format: "small", width: 4cm, noise: 1.2)
	``` 
]


=== The true nature of random outputs

It is important to note that since _Typst_ is a pure functional language, true randomness is not available. Instead, DECKZ uses the #universe("suiji") package to generate *pseudo-random numbers*, which are used to produce a deterministic -- but seemingly chaotic -- output.

Randomization in DECKZ is designed to be simple and intuitive: each function that requires randomness has a `rng` argument (*Random Number Generator*), which can be set to a specific value or left to the default (#value(auto)).

As a *general rule*:

- #primary[_If you don't provide a `rng`_] $=>$ DECKZ will instance a *default generator* that is seeded with the current input content (usually, the cards array). This ensures that the same input will always produce the same output, making it *deterministic and reproducible*.
- #primary[_If you provide a `rng`_] $=>$ DECKZ will use the provided generator and return the new `rng` state along with the produced output. With this approach, you can chain multiple random operations together, ensuring a pseudo-random sequence of results.

Let's explore these two modes in detail.

=== Working with deterministic randomness

When you don't provide an RNG, DECKZ creates a deterministic output based on the input:

#example(breakable: false, side-by-side: false)[
	```typ
	// These three calls will produce identical results
	#stack(
		spacing: 5mm,
		deckz.hand("AS", "KH", "QD", format: "small", noise: 1.0, width: 5cm),
		deckz.hand("AS", "KH", "QD", format: "small", noise: 1.0, width: 5cm),
		deckz.hand("AS", "KH", "QD", format: "small", noise: 1.0, width: 5cm)
	)
	```
]

This behavior is useful for:
- #emph[Consistent document layouts]: the same cards will always appear the same way.
- #emph[Reproducible examples]: perfect for documentation and tutorials.
- #emph[Version control]: documents will look identical across different compilations.

=== Creating variation with external RNGs

To get *different visual results* for the same cards, you need to provide your own RNG from outside the function. This can be done using the #universe("suiji") function `gen-rng-f(seed)`:

#example(breakable: true, side-by-side: false)[
	```typ
	#import "@preview/suiji:0.4.0": gen-rng-f

	// Create different RNGs with different seeds
	#let rng1 = gen-rng-f(42)
	#let rng2 = gen-rng-f(123)
	#let rng3 = gen-rng-f(999)

	// Same cards, different appearances
	#stack(
		spacing: 5mm,
		deckz.hand("AS", "KH", "QD", format: "small", noise: 1.0, width: 5cm, rng: rng1).last(),
		deckz.hand("AS", "KH", "QD", format: "small", noise: 1.0, width: 5cm, rng: rng2).last(),
		deckz.hand("AS", "KH", "QD", format: "small", noise: 1.0, width: 5cm, rng: rng3).last(),
	)
	```
]

#bts-info[
	You may have noticed the `.last()` at the end of each call, in the previous example.
	This is because when using an external RNG, DECKZ functions return a *tuple* containing the new RNG state and the rendered content.
	To extract the final content, you need to access the last element of the returned tuple, which is done with the `.last()` function call.
]

However, instead of creating separate RNGs for each call, it is often more convenient to *chain operations* using the same RNG.

#example(breakable: true, side-by-side: false)[
	```typ
	#import "@preview/suiji:0.4.0": gen-rng-f

	#let my-rng = gen-rng-f(42)

	// First operation: render a single card
	#let (my-rng, card1) = deckz.small("3C", noise: 0.2, rng: my-rng)

	// Second operation: use the updated RNG for a different result
	#let (my-rng, card2) = deckz.small("3C", noise: 0.9, rng: my-rng)

	// Display both cards - they will look different!
	#grid(columns: 2, gutter: 1cm, card1, card2)
	```
]

As a general guideline, you can follow these practices when working with randomness in DECKZ:

#grid(
	columns: (1fr, 1fr), 
	gutter: 1em,
	info-alert()[
		*Use deterministic mode when:*
		- Creating documentation;
		- Building consistent layouts;  
		- Teaching card game rules;
		- Making reproducible examples.
	],
	info-alert()[
		*Use external RNGs when:*
		- Simulating real game scenarios;
		- Creating varied visual content;
		- Building interactive examples;
		- Generating multiple variations.
	]
)

=== Manipulate cards with #primary[`mix`]

In addition to rendering, DECKZ provides functions for *manipulating hands and decks*, such as shuffling or drawing cards. These functions -- included in the #primary[`mix`] submodule of DECKZ -- also support RNGs to control randomness.

Here we can see how to *shuffle* a deck of cards (@cmd:deckz.mix:shuffle) and *draw* a hand of five cards (@cmd:deckz.mix:choose) from it:

#example(breakable: true, side-by-side: false)[
	```typ
	#import "@preview/suiji:0.4.0": gen-rng-f

	// Shuffle the deck with a specific RNG
	#let (my-rng, shuffled-deck) = deckz.mix.shuffle(deckz.deck52, rng: gen-rng-f(42))
	
	// Display the shuffled deck
	The current shuffled deck: #shuffled-deck.map(deckz.inline).join()

	// Draw the top 5 cards from the shuffled deck
	#let (my-rng, hand) = deckz.mix.choose(shuffled-deck, n: 5, rng: my-rng)

	// Display the drawn hand
	We draw the following *five cards*: #deckz.hand(..hand, format: "small", width: 3cm)
	```
]

Another function included in the #primary(`mix`) submodule is @cmd:deckz.mix:split, which allows to *split a deck* into multiple parts, according to the specified sizes. This can be useful for creating multiple hands or sub-decks from a larger deck.

#example(breakable: true, side-by-side: false)[
	```typ
	// Randomly split the deck
	#let split-deck = deckz.mix.split(deckz.deck52, size: ((3, 5), 8), rest: true)
	#let ((hand1, hand2, hand3), board, remaining-cards) = split-deck

	// Display the hands and the board
	We split the deck into three hands and a board:
	#grid(
		columns: (1fr, 1fr, 1fr),
		gutter: 1em,
		deckz.hand(..hand1, format: "small", width: 3cm),
		deckz.hand(..hand2, format: "small", width: 3cm),
		deckz.hand(..hand3, format: "small", width: 3cm),
		deckz.hand(..board, format: "small", angle: 0deg)
	)
	There are still *#remaining-cards.len() cards* left in the deck.
	```
]

At first glance, the @cmd:deckz.mix:split function may seem similar to the @cmd:deckz.mix:choose function, but it has a fundamental difference: it keeps track of the *remaining cards* in the deck, allowing you to draw more cards later. If you use @cmd:deckz.mix:choose three times, you will have three different hands, but it's not guaranteed that the same card won't be drawn twice. Instead, @cmd:deckz.mix:split ensures that the drawn cards are unique and that you can still access the remaining cards in the deck.

#bts-info[
	For this reason, @cmd:deckz.mix:split is less efficient than @cmd:deckz.mix:choose, as it needs to keep track of the remaining cards.
]