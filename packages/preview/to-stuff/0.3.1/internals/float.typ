
#let	rx-number			=  "\d*\.?\d+(e[+-]?\d+)?"
#let	rx-signed			=  "(([-+\s]*)(" + rx-number + "))"

#let	float(
	quiet				:   false,
	value,
) = {
	if type(value) == std.float {
		return value
	}


	let	rx				=   regex("^" + rx-signed + "$")

	if type(value) == std.str and value.trim().contains(rx) {
		let	(_, signs, num, _)		=   value.trim().matches(rx).first().captures
		let	negative			=   calc.odd(signs.split("").filter(x => x == "-").len())

		return std.float(num) * {
			if negative {
				-1.0
			} else {
				 1.0
			}
		}
	}

	if quiet {
		return none
	}

	panic("could not convert to float: " + repr(value))
}

