
#import	"/internals/utils.typ"		:   list-predefined

#let	direction(
	quiet				:   false,
	value,
) = {
	if type(value) == std.direction {
		return value
	}


	let	constants			=   list-predefined(std.direction)

	if type(value) == std.str and value.trim() in constants {
		return constants.at(value.trim())
	}

	if quiet {
		return none
	}

	panic("could not convert to direction: " + repr(value))
}

