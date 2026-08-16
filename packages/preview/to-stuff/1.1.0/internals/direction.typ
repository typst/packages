
#import	"/internals/utils.typ"		:   *

#let	direction(
	default				:   auto,
	value,
) = {
	let	types				= (
		std.direction,
	)

	if type(value) in types {
		return value
	}


	let	constants			=   list-predefined(std.direction)

	if type(value) == std.str and value.trim() in constants {
		return constants.at(value.trim())
	}


	mild-panic(
		default				:   default,
		types				:   types,
		"could not convert to direction: " + repr(value),
	)
}

