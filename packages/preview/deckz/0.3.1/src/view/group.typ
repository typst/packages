#import "format.typ": *
#import "../logic/random.typ": prepare-rng, attach-rng-if-from-outside, call-rng-function, suiji
#import cetz: draw


/// Displays a *sequence of cards* in a horizontal line layout.
/// The function accepts any number of cards, each represented by a string identifier (e.g., `"AH"` for Ace of Hearts). 
/// It accepts parameters to control the format of the cards and the area they occupy. The value of `spacing` determines the space between adjacent cards, while `width` specifies the total width of the line. 
/// *Important*: being one dependent on the other, only one parameter between `spacing` and `width` can be set to a specific value at a time.
/// If none of them is set, cards are placed adjacent with no extra space.
/// 
/// ```side-by-side
/// #let hand = ("AH", "AD", "AS", "AC")
/// 
/// #deckz.line(..hand, format: "small")
/// 
/// #deckz.line(..hand, format: "small", spacing: 10pt)
/// 
/// #deckz.line(..hand, format: "small", width: 6cm)
/// 
/// #deckz.line(..hand, format: "small", width: 100%)
/// 
/// #box(width: 6cm, stroke: purple)[
/// 	#deckz.line(..hand, format: "small", width: 100%)
/// ]
/// ```
/// 
/// -> content
#let line(
	/// The list of *cards* to display, with standard code representation.
	/// -> array
	..cards,
	/// The *format* of the cards to render. Default is "medium".
	/// Available formats: `inline`, `mini`, `small`, `medium`, `large`, `square`.
	/// -> string
	format: "medium",
	/// The *spacing* between adjacent cards.
	/// - If set, cards are distributed with the specified spacing.
	/// - Default is #value(auto). If left to default value, cards are placed adjacent with no extra space.
	/// - In any other case -- i.e. when `spacing` is set to a specific positive non-zero value, the function requires `width` to be left as #value(auto) or set to #value(none); otherwise, the function will panic.
	/// -> length | auto | none
	spacing: auto,
	/// The *total width* of the line, measured from the center of the first card to the center of the last card.
	/// - If set, cards are distributed evenly along this width.
	/// - Requires `spacing` to be left as #value(auto) or set to #value(none); otherwise, the function will panic.
	/// - Default is #value(auto). If both `width` and `spacing` are #value(auto), cards are placed adjacent with no extra space.
	/// -> length | auto | none
	width: auto,
	/// The amount of "*randomness*" in the placement and rotation of the card. Default value is #value(none) or #value(0), which corresponds to no variations. A value of #value(1) corresponds to a "standard" amount of noise, according to DECKZ style. Higher values might produce crazy results, handle with care. 
	/// -> float | none
	noise: none,
  /// The *random number generator* utilized for the noise. If not provided or set to default value #value(auto), a new random number generator will be created. Otherwise, you can pass an existing random number generator to use.
  /// -> rng | auto
	rng: auto,
) = context {
	let cards-array = cards.pos()
	// If no cards, return empty array
	if cards-array.len() == 0 {
		return []
	}
	// Prepare the random number generator
	let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: cards-array)
	// If only one card, render it directly
	if cards-array.len() == 1 {
		let (new-rng, card-content) = call-rng-function(render, rng,
			cards-array.at(0),
			format: format,
			noise: noise,
		)
		return attach-rng-if-from-outside(rng-from-outside, new-rng, card-content)
	} 
	// If there are multiple cards
	else {
		// Set the spacing
		let computed-spacing = 0pt
		if spacing == auto or spacing == none {
			// Case: spacing is auto or none
			if width == auto or width == none {
				// Case: width is auto or none, like "spacing"
				// Cards are placed adjacent with no extra space
				computed-spacing = 0pt
			} else {
				// Case: `width` is set, thus `spacing` is computed based on the number of cards
				let card-width = format-parameters.at(format).width.to-absolute()
				computed-spacing = (width - card-width * cards-array.len()) / (cards-array.len() - 1)
			}
		} else {
			// Case: spacing is set to a specific value
			// We need to ensure that `width` is left as auto or none
			if width == auto or width == none {
				// Everything's okay, we can use the specified spacing
				computed-spacing = spacing.to-absolute()
			} else {
				// If `width` is set, it must be left as auto or none
				panic("Cannot set both `spacing` and `width` to specific values. Either leave `spacing` as auto or none, or set `width` to auto or none.")
			}
		}

		// Visualization
		let cards-content = ()
		for card in cards-array {
			// Use call-rng-function to properly handle RNG state
			let (new-rng, card-view) = call-rng-function(render, rng,
				card,
				format: format,
				noise: noise,
			)
			rng = new-rng  // Update RNG state for next iteration
			cards-content.push(card-view)
		}
		let result = stack(
			dir: ltr,
			spacing: computed-spacing,
			..cards-content
		)
		return attach-rng-if-from-outside(rng-from-outside, rng, result)
	}
}


/// Displays a *sequence of cards* in a horizontal hand layout and applying a slight rotation to each card, creating an arched effect.
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
	/// The list of *cards* to display, with standard code representation.
	/// -> array
	..cards,
	/// The *format* of the cards to render. Default is "medium".
	/// Available formats: `inline`, `mini`, `small`, `medium`, `large`, `square`. 
	/// -> string
	format: "medium",
	/// The *angle* between the first and last card, i.e. the angle covered by the arc. 
	/// -> angle
	angle: 30deg, 
	/// The *width* of the hand, i.e. the distance between the first and last card.
	/// -> length
	width: 10cm, 
	/// The amount of "*randomness*" in the placement and rotation of the card. Default value is "none" or "0", which corresponds to no variations. A value of "1" corresponds to a "standard" amount of noise, according to DECKZ style. Higher values might produce crazy results, handle with care. 
	/// -> float | none
	noise: none,
  /// The *random number generator* to use for the noise. If not provided or set to default value #value(auto), a new random number generator will be created. Otherwise, you can pass an existing random number generator to use.
  /// -> rng | auto
	rng: auto,
) = {
	let cards-array = cards.pos()
	// If no cards, return empty array
	if cards-array.len() == 0 {
		return []
	}
	// Prepare the random number generator
	let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: cards-array)
	// If only one card, render it directly
	if cards-array.len() == 1 {
		let (new-rng, card-content) = call-rng-function(render, rng,
			cards-array.at(0),
			format: format,
			noise: noise,
		)
		return attach-rng-if-from-outside(rng-from-outside, new-rng, card-content)
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
		// Drawing canvas
		let result = cetz.canvas({
			draw.rotate(z: -angle-start)
			for i in range(cards-array.len()) {
				// Draw content - use call-rng-function to properly handle RNG state
				let (new-rng, card-content) = call-rng-function(render, rng,
					cards-array.at(i),
					format: format,
					noise: noise,
				)
				rng = new-rng  // Update RNG state for next iteration
				
				draw.content((shift-x * i, radius), angle: -(angle-start + i * angle-shift), card-content)
				draw.rotate(z: -angle-shift)
			}
		})
		return attach-rng-if-from-outside(rng-from-outside, rng, result)
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
	/// The *top card* in the deck, with standard code representation.
	/// -> string
	top-card,
	/// The *format* to use for rendering each card. Default is "medium". 
	/// -> string
	format: "medium", 
	/// The *angle* at which the deck is fanned out. Default is #value(60deg). 
	/// -> angle
	angle: 60deg, 
	/// The total *height* of the deck stack. This determines how many cards are rendered in the stack, as one card is displayed for every #value(2.5pt) of height. 
	/// -> height
	height: 1cm, 
	/// The amount of "*randomness*" in the placement and rotation of the card. Default value is "none" or "0", which corresponds to no variations. A value of 1 corresponds to a "standard" amount of noise, according to Deckz style. Higher values might produce crazy results, handle with care. 
	/// -> float | none
	noise: none, 
  /// The *random number generator* to use for the noise. If not provided or set to default value #value(auto), a new random number generator will be created. Otherwise, you can pass an existing random number generator to use.
  /// -> rng | auto
	rng: auto,
) = {
	let num-cards = calc.max(int(height / 2.5pt), 1)
	let shift-x = height * calc.cos(angle) / num-cards
	let shift-y = height * calc.sin(angle) / num-cards
	
	// Prepare the random number generator  
	let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: top-card)
	
	let result = cetz.canvas({
		for i in range(num-cards) {
			// Use call-rng-function to properly handle RNG state
			let (new-rng, card-content) = call-rng-function(render, rng,
				top-card,
				format: format,
				noise: noise,
			)
			rng = new-rng  // Update RNG state for next iteration
			
			content((shift-x * i, shift-y * i), card-content)
		}
	})
	return attach-rng-if-from-outside(rng-from-outside, rng, result)
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
	/// The *cards to display*, with standard code representation. The last cards are represented on top of the previous one, as the rendering follows the given order.
	/// -> array
	..cards,
	/// The *format* to use for rendering each card. Default is "medium".
	/// -> string
	format: "medium", 
	/// The *horizontal dimension* of the area in which cards are placed.
	/// -> length
	width: 10cm,
	/// The *vertical dimension* of the area in which cards are placed.
	/// -> length
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
  /// The *random number generator* to use for cards displacement. If not provided or set to default value #value(auto), a new random number generator will be created. Otherwise, you can pass an existing random number generator to use.
  /// -> rng | auto
	rng: auto,
) = context {
	let cards-array = cards.pos()
	let num-cards = cards-array.len()
	let card-w = format-parameters.at(format).width.to-absolute()
	let card-h = format-parameters.at(format).height.to-absolute()
	
	// Prepare the random number generator  
	let (rng-from-outside, rng) = prepare-rng(rng: rng, seed: cards-array)
	
	// Random values
	let (rng, rand-x) = suiji.uniform-f(rng, size: num-cards) 	// [0, 1)
	let (rng, rand-y) = suiji.uniform-f(rng, size: num-cards) 	// [0, 1)
	let (rng, shift-rot) = suiji.uniform-f(rng, low: 0, high: 360, size: num-cards) // [0°, 360°)
	
	let result = cetz.canvas({
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
			// Render content using call-rng-function to properly handle RNG state
			let (new-rng, card-content) = call-rng-function(render, rng,
				cards-array.at(i),
				format: format,
			)
			rng = new-rng  // Update RNG state for next iteration
			
			content((x, y), 
				rotate(angle, origin: center + horizon, reflow: true)[
					#card-content
				]
			)
		}
	})
	return attach-rng-if-from-outside(rng-from-outside, rng, result)
}