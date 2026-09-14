// Importing package files
#import "utils.typ": *

// _Auxiliary function_.
// Visualizes the solution word next to its definition, with a specific style.
#let visualize-hint-word(word) = [ #text(writing-color, font: writing-font, weight: "bold")[#upper[#word]] ]

// _Auxiliary function_.
// Visualize a given *entry* of the crossword. An entry is a dictionary with the following keys:
// - number = the number of the word, associated with its definition.
// - word = the word itself, which is the solution to the crossword.
// - definition = the text describing the hint of the word.
// - solved = whether the word has already been found.
#let visualize-definition(entry) = {
	assert("number" in entry)
	assert("definition" in entry)
	assert("word" in entry)
	assert("solved" in entry)

	if not entry.definition.ends-with(".") and not entry.definition.ends-with("?") {
		entry.definition += "."
	}
	// SOLVED
	if entry.solved {
		strike(stroke: 1pt + writing-color)[*#entry.number*. #entry.definition]
		[#visualize-hint-word(entry.word)]
	} 
	// UNSOLVED
	else {
		[ #box(fill: none, radius: 50%)[*#entry.number*.] #entry.definition ]
	}
	linebreak()
}

// Show the definitions of the crossword.
#let show-definitions(definitions) = {
	for entry in definitions {
		visualize-definition(entry)
	}
}
