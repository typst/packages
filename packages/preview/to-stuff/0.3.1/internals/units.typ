
#import	"/internals/float.typ"		:   rx-signed

#let	units(
	units				: (:),
	target				:   none,
	quiet				:   false,
	value,
) = {
	if type(value) == target {
		return value
	}


	let	rx				=   regex("^" + rx-signed + "(" + units.keys().join("|") + ")$")

	if type(value) == std.str and value.trim().contains(rx) {
		let	(_, signs, num, _, unit)	=   value.trim().matches(rx).first().captures
		let	negative			=   calc.odd(signs.split("").filter(x => x == "-").len())

		return float(num) * units.at(unit) * {
			if negative {
				-1
			} else {
				 1
			}
		}
	}

	if quiet {
		return none
	}

	panic("could not convert to " + repr(target) + ": " + repr(value))
}


#let	length(
	quiet				:   false,
	value,
) = {
	return units(
		units				: (
			"pt"				:   1pt,
			"mm"				:   1mm,
			"cm"				:   1cm,
			"in"				:   1in,
			"em"				:   1em,
		),
		target				:   std.length,
		quiet				:   quiet,
		value,
	)
}


#let	fraction(
	quiet				:   false,
	value,
) = {
	return units(
		units				: (
			"fr"				:   1fr,
		),
		target				:   std.fraction,
		quiet				:   quiet,
		value,
	)
}


#let	ratio(
	quiet				:   false,
	value,
) = {
	return units(
		units				: (
			"%"				:   1%,
		),
		target				:   std.ratio,
		quiet				:   quiet,
		value,
	)
}


#let	angle(
	quiet				:   false,
	value,
) = {
	return units(
		units				: (
			"deg"				:   1deg,
			"rad"				:   1rad,
		),
		target				:   std.angle,
		quiet				:   quiet,
		value,
	)
}

