#import "format.typ": *

#import cetz: draw

/// Displays a *sequence of cards* in a horizontal hand layout.
/// Optionally applies a slight rotation to each card, creating an arched effect.
/// 
/// This function is useful for displaying a hand of cards in a visually appealing way. It accepts any number of cards, each represented by a string identifier (e.g., `"AH"` for Ace of Hearts).
/// 
/// ```side-by-side
/// #deckz.hand(
/// 	width: 100pt, 
/// 	"AH", "AD", "AS", "AC"
/// 	// Poker of Aces
/// )
/// ```
/// 
/// -> content
#let hand(
	/// The *angle* between the first and last card, i.e. the angle covered by the arc. -> angle
	angle: 30deg, 
	/// The *width* of the hand, i.e. the distance between the first and last card. -> length
	width: 10cm, 
	/// The amount of "*randomness*" in the placement and rotation of the card. Default value is "none" or "0", which corresponds to no variations. A value of "1" corresponds to a "standard" amount of noise, according to DECKZ style. Higher values might produce crazy results, handle with care. -> float | none
	noise: none,
	/// The *format* of the cards to render. Default is "medium".
	/// Available formats: `inline`, `mini`, `small`, `medium`, `large`, `square`. -> string
	format: "medium",
	/// The list of *cards* to display, with standard code representation. -> array
	..cards
) = {
	let cards-array = cards.pos()
	if cards-array.len() == 0 {
		return []
	} else if cards-array.len() == 1 {
		return render(format: format, noise: noise, cards-array.at(0))
	} else {
		// If there is at least a pair of cards
		let (angle-start, angle-shift, radius, shift-x) = (0deg, 0deg, 0pt, 0pt)
		if angle == 0deg {
			shift-x = width / (cards-array.len() - 1)
		} else {
			angle-start = -angle / 2
			angle-shift = angle / (cards-array.len() - 1)
			radius = width / (2 * calc.sin(angle / 2))
		}
		// Handling randomness
		let variabilities = ()
		if noise != none and noise > 0 {
			let seed = int(noise * 1e9) + 42
			let rng = suiji.gen-rng-f(seed)
			(_, variabilities) = suiji.uniform-f(rng, low: 0, high: 1e-6, size: cards-array.len())
		}
		// Drawing canvas
		cetz.canvas({
			draw.rotate(z: -angle-start)
			for i in range(cards-array.len()) {
				// Compute noise for the current card visualization
				let card-noise = if noise == none or noise <= 0 {
					none
				} else {
					noise + variabilities.at(i, default: none)
				}
				// Draw content
				content((shift-x * i, radius),
					rotate(
						angle-start + i * angle-shift,
						reflow: true,
						origin: center + horizon,
						render(format: format, noise: card-noise, cards-array.at(i))
					)
				)
				draw.rotate(z: -angle-shift)
			}
		})
	}
}


/// Renders a *stack* of cards, as if they were placed one ontop of each other.
/// Calculates the number of cards based on the given height (@cmd:deckz:deck.height), and spaces them evenly along the specified angle (@cmd:deckz:deck.angle). Each card is rendered with a positional shift to create a fanned deck appearance.
/// 
/// ```side-by-side
/// #deckz.deck(
///		angle: 20deg,
/// 	height: 1.5cm,
/// 	"7D"
/// )
/// ```
/// 
/// -> content
#let deck(
	/// The *angle* at which the deck is fanned out. Default is #{60deg}. -> angle
	angle: 60deg, 
	/// The total *height* of the deck stack. This determines how many cards are rendered in the stack, as one card is displayed for every #{2.5pt} of height. 
	/// -> height
	height: 1cm, 
	/// The amount of "*randomness*" in the placement and rotation of the card. Default value is "none" or "0", which corresponds to no variations. A value of 1 corresponds to a "standard" amount of noise, according to Deckz style. Higher values might produce crazy results, handle with care. -> float | none
	noise: none, 
	/// The *format* to use for rendering each card. Default is "medium". -> string
	format: "medium", 
	/// The *top card* in the deck, with standard code representation. -> string
	top-card
) = {
	let num-cards = calc.max(int(height / 2.5pt), 1)
	let shift-x = height * calc.cos(angle) / num-cards
	let shift-y = height * calc.sin(angle) / num-cards
	// Handling randomness
	let variabilities = ()
  if noise != none and noise > 0 {
    let seed = int(noise * 1e9) + 42
    let rng = suiji.gen-rng-f(seed)
		(_, variabilities) = suiji.uniform-f(rng, low: 0, high: 1e-6, size: num-cards)
	}
	cetz.canvas({
		for i in range(num-cards) {
			let card-noise = if noise == none or noise <= 0 {
				none
			} else {
				noise + variabilities.at(i, default: none)
			}
			content((shift-x * i, shift-y * i), render(format: format, noise: card-noise, top-card))
		}
	})
}

/// Renders a *heap* of cards, randomly placed in the given area.
/// The cards are placed in a random position within the specified width (@cmd:deckz:heap.width) and height (@cmd:deckz:heap.height), with a random rotation applied to each card. The @cmd:deckz:heap.exceed parameter controls whether cards can exceed the specified frame dimensions or not.
/// 
/// ```side-by-side
/// #deckz.heap(
/// 	format: "small",
/// 	width: 5cm,
/// 	height: 4cm,
/// 	"7D", "8D", "9D", "10D", "JD"
/// )
/// ```
/// 
/// -> content 
#let heap(
	/// The *format* to use for rendering each card. Default is "medium". -> string
	format: "medium", 
	/// The *horizontal dimension* of the area in which cards are placed. -> length
	width: 10cm,
	/// The *vertical dimension* of the area in which cards are placed. -> length
	height: 10cm, 
	/// If `true`, allows cards to *exceed the frame* with the given dimensions. When the parameter is `false`, instead, cards placement considers a margin of half the card length on all four sides. This way, it is guaranteed that cards are placed within the specified frame size. Default is `false`.
	/// 
	/// ```side-by-side
	/// // Example with `exceed: true`
	/// #box(width: 3cm, height: 3cm, stroke: green)[
	/// 	#place(center + horizon, deckz.heap(
	/// 		format: "small",
	/// 		width: 3cm,
	/// 		height: 3cm,
	/// 		exceed: true,
	/// 		..deckz.deck52.slice(0, 13)
	/// 	))
	/// ]
	/// 
	/// // Example with `exceed: false`
	/// #box(width: 3cm, height: 3cm, stroke: green)[
	/// 	#place(center + horizon, deckz.heap(
	/// 		format: "small",
	/// 		width: 3cm,
	/// 		height: 3cm,
	/// 		exceed: false,
	/// 		..deckz.deck52.slice(0, 13)
	/// 	))
	/// ]
	/// 
	/// ``` 
	/// 
	/// -> boolean
	exceed: false, 
	/// The *cards to display*, with standard code representation. The last cards are represented on top of the previous one, as the rendering follows the given order.  -> array
	..cards
) = context {
	let num-cards = cards.pos().len()
	let card-w = format-parameters.at(format).width.to-absolute()
	let card-h = format-parameters.at(format).height.to-absolute()
	// Random values
	let rng = suiji.gen-rng-f(42)
	let (rng, rand-x) = suiji.uniform-f(rng, size: num-cards) 	// [0, 1)
	let (rng, rand-y) = suiji.uniform-f(rng, size: num-cards) 	// [0, 1)
	let (rng, shift-rot) = suiji.uniform-f(rng, low: 0, high: 360, size: num-cards) // [0°, 360°)
	cetz.canvas({
		for i in range(num-cards) {
			// Compute random angle
			let angle = shift-rot.at(i) * 1deg
			// If cannot exceed, compute the bounding box
			let (x, y) = (0, 0)
			if not exceed {
				let sin_angle = calc.abs(calc.sin(angle))
				let cos_angle = calc.abs(calc.cos(angle))
				let span-x = card-w * cos_angle + card-h * sin_angle
				let span-y = card-w * sin_angle + card-h * cos_angle
				x = rand-x.at(i) * (width - span-x) + (span-x / 2)
				y = rand-y.at(i) * (height - span-y) + (span-y / 2)
			} else {
				x = rand-x.at(i) * width
				y = rand-y.at(i) * height
			}
			// Render content
			content((x, y), 
				rotate(angle, origin: center + horizon, reflow: true)[
					//#box(width: card-w, height: card-h, stroke: 1pt)
					#render-card(format, cards.pos().at(i))
				]
			)
		}
	})
}