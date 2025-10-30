
#let	rx-number			=  "\d*\.?\d+(e[+-]?\d+)?"
#let	rx-signed-strict		=  "([-+]?" + rx-number + ")"
#let	rx-signed-loose			=  "(([-+\s]*)(" + rx-number + "))"

#let	float(
	quiet				:   false,
	value,
) = {
	if type(value) == std.float {
		return value
	}


	let	rx				=   regex("^" + rx-signed-strict + "$")

	if type(value) == std.str and value.trim().contains(rx) {
		return std.float(value.trim())
	}

	if quiet {
		return none
	}

	panic("could not convert to float: " + repr(value))
}

