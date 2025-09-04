#import "@preview/cetz:0.4.1"
#import cetz.draw: content, move-to

#import "../data/suit.typ": *
#import "../data/rank.typ": *

// Draw a figure rank (J, Q, K) in a CeTZ canvas
// in double copy, with a central symmetry.
// 
// _*Note*: this has to be drawn in a canvas._
#let draw-symmetric-figure-canvas(rank, symbol) = {
	// Suit
	content((-1em, 0.75em), symbol)
	content((1em, -0.75em), angle: 180deg, symbol)
	// Figure rank
	content((0.1em, 0.68em), angle: 0deg, text(size: 1.7em, rank))
	content((-0.1em, -0.68em), angle: 180deg, text(size: 1.7em, rank))
}

// Show the stack of rank + suit symbols.
// Used for corners in larger formats, or for content in "mini" format.
// 
// _*Note*: this has to be drawn in a canvas._
#let draw-stack-rank-and-suit(card-data, dx: 0pt, dy: 0pt, angle: 0deg) = {
	move-to((dx, dy))
	content((rel: (0pt, -1em)), angle: angle, card-data.suit-symbol)
	content((rel: (0pt, +1em)), angle: angle, card-data.rank-symbol)
}

// Show the stack of rank + suit symbols
#let draw-central-rank-canvas(card-data) = {
  let num = card-data.rank
	let symbol = card-data.suit-symbol
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