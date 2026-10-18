
#import	"/internals/utils.typ"		:   *

#let	bool(
	default				:   auto,
	value,
) = {
	let	types				= (
		std.bool,
	)

	if type(value) in types {
		return value
	}


	let	constants			= (
		"false"				:   false,
		"true"				:   true,
	)

	if type(value) == std.str and lower(value.trim()) in constants {
		return constants.at(lower(value.trim()))
	}


	mild-panic(
		default				:   default,
		types				:   types,
		"could not convert to boolean: " + repr(value),
	)
}

