#import "@preview/cetz:0.4.0"
#import cetz.draw: content

#import "../data/suit.typ": *
#import "../data/rank.typ": *

// Draw a figure (J, Q, K) in a CeTZ canvas
// in double copy, with a central symmetry.
// 
// _*Note*: this has to be drawn in a canvas._
#let draw-symmetric-figure-canvas(fig, symbol) = {
	// Suit
	content((-1em, 0.75em), symbol)
	content((1em, -0.75em), angle: 180deg, symbol)
	// Figure
	content((0.1em, 0.68em), angle: 0deg, text(size: 1.7em, fig))
	content((-0.1em, -0.68em), angle: 180deg, text(size: 1.7em, fig))
}

// Show the stack of rank + suit symbols
#let draw-central-rank-canvas(card-data) = {
  let num = card-data.rank
	let symbol = suits.at(card-data.suit)
	cetz.canvas({
  // Switch by rank
		
		// ACE
		if num == "ace" {
			content((0,0), 
				if (card-data.suit == "spade") {
					text(size: 2em, symbol)
				} else {
					symbol
				}
			)

		// TWO
		} else if num == "two" {
			content((0, 1.5em), symbol)
			content((0, -1.5em), angle: 180deg, symbol)

		// THREE
		} else if num == "three" {
			content((0, 1.5em), symbol)
			content((0, 0), symbol)
			content((0, -1.5em), angle: 180deg, symbol)
		
		// FOUR
		} else if num == "four" {
			content((-0.5em, 1.5em), symbol)
			content((0.5em, 1.5em), symbol)
			content((0.5em, -1.5em), angle: 180deg, symbol)
			content((-0.5em, -1.5em), angle: 180deg, symbol)

		// FIVE
		} else if num == "five" {
			content((-0.5em, 1.5em), symbol)
			content((0.5em, 1.5em), symbol)
			content((0, 0), symbol)
			content((0.5em, -1.5em), angle: 180deg, symbol)
			content((-0.5em, -1.5em), angle: 180deg, symbol)

		// SIX
		} else if num == "six" {
			content((-0.5em, 1.5em), symbol)
			content((0.5em, 1.5em), symbol)
			content((-0.5em, 0), symbol)
			content((0.5em, 0), symbol)
			content((-0.5em, -1.5em), angle: 180deg, symbol)
			content((0.5em, -1.5em), angle: 180deg, symbol)

		// SEVEN
		} else if num == "seven" {
			content((-0.5em, 1.5em), symbol)
			content((0.5em, 1.5em), symbol)
			content((0, 0.75em), symbol)
			content((-0.5em, 0), symbol)
			content((0.5em, 0), symbol)
			content((-0.5em, -1.5em), angle: 180deg, symbol)
			content((0.5em, -1.5em), angle: 180deg, symbol)

		// EIGHT
		} else if num == "eight" {
			content((-0.5em, 1.5em), symbol)
			content((0.5em, 1.5em), symbol)
			content((-0.5em, 0.5em), symbol)
			content((0.5em, 0.5em), symbol)
			content((-0.5em, -0.5em), angle: 180deg, symbol)
			content((0.5em, -0.5em), angle: 180deg, symbol)
			content((-0.5em, -1.5em), angle: 180deg, symbol)
			content((0.5em, -1.5em), angle: 180deg, symbol)

		// NINE
		} else if num == "nine" {
			content((-0.5em, 1.5em), symbol)
			content((0.5em, 1.5em), symbol)
			content((-0.5em, 0.55em), symbol)
			content((0.5em, 0.55em), symbol)
			content((0, 0), symbol)
			content((-0.5em, -0.55em), angle: 180deg, symbol)
			content((0.5em, -0.55em), angle: 180deg, symbol)
			content((-0.5em, -1.5em), angle: 180deg, symbol)
			content((0.5em, -1.5em), angle: 180deg, symbol)

		// TEN
		} else if num == "ten" {
			content((-0.5em, 1.5em), symbol)
			content((0.5em, 1.5em), symbol)
			content((0em, 1em), symbol)
			content((-0.5em, 0.5em), symbol)
			content((0.5em, 0.5em), symbol)
			content((-0.5em, -1.5em), angle: 180deg, symbol)
			content((0.5em, -1.5em), angle: 180deg, symbol)
			content((0em, -1em), angle: 180deg, symbol)
			content((-0.5em, -0.5em), angle: 180deg, symbol)
			content((0.5em, -0.5em), angle: 180deg, symbol)

		// JACK
		} else if num == "jack" {
			draw-symmetric-figure-canvas(emoji.person.sassy, symbol)

		// QUEEN
		} else if num == "queen" {
			draw-symmetric-figure-canvas(emoji.woman.crown, symbol)

		// KING
		} else if num == "king" {
			draw-symmetric-figure-canvas(emoji.man.crown, symbol)

		// otherwise
		} else {
			content((0,0), [$emptyset$])
		}
	
	})
}