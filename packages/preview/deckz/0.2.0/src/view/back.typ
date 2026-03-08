// Functions to handle the back of cards.
#import "format.typ": format-parameters, border-style, render-card-frame

//#let back-color = red.lighten(45%).mix(blue)
#let back-color = color.rgb("#4796a4")

#let fill-rombus = {
	tiling(
		size: (8pt, 16pt), 
		relative: "parent",	{
			place(line(stroke: white, start: (0%, 0%), end: (100%, 100%)))
			place(line(stroke: white, start: (0%, 100%), end: (100%, 0%)))
		}
	)
}

/// Renders the back of a card in the specified format.
/// Currently, it only supports one style, which is a simple rectangle with a rhombus pattern.
/// 
/// ```side-by-side
/// #deckz.back(format: "medium")
/// #deckz.back(format: "small")
/// #deckz.back(format: "mini")
/// #deckz.back(format: "inline")
/// ```
/// 
/// -> content
#let back(
	/// The format of the card back, defaults to #value("medium").
	/// Available formats: #choices("inline", "mini", "small", "medium", "large", "square").
	/// -> str
	format: "medium"
) = {
	render-card-frame(format, box(
			width: 100%,
			height: 100%,
			radius: 4pt,
			fill: back-color,
			box(width: 100%, height: 100%,
				fill: fill-rombus,
			)
		)
	)
}