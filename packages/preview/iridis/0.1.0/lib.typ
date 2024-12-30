#import "internals.typ"

#let iridis-palette = internals.iridis-palette

#let iridis-show(
	opening-parenthesis: ("(","[","{"),
	closing-parenthesis: (")","]","}"),
	palette: internals.iridis-palette,	
	body
) = {

	let counter = state("parenthesis", 0)
	

	show raw : internals.colorize-code(counter, opening-parenthesis, closing-parenthesis, palette)
	show math.equation : internals.colorize-math
 
	body
}

