
#let	direction(
	quiet				:   false,
	value,
) = {
	if type(value) == std.direction {
		return value
	}


	let	constants			= ( // Built-in constants
		ltr				:   std.direction.ltr,
		rtl				:   std.direction.rtl,
		ttb				:   std.direction.ttb,
		btt				:   std.direction.btt,
	)

	if type(value) == std.str and value.trim() in constants {
		return constants.at(value.trim())
	}

	if quiet {
		return none
	}

	panic("could not convert to direction: " + repr(value))
}

