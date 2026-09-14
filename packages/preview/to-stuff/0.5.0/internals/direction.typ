
#import	"/internals/utils.typ"		:   *

#let	direction(
	quiet				:   false,
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
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"could not convert to direction: " + repr(value),
	)
}

