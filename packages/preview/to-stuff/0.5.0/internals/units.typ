
#import	"/internals/numbers.typ"	:   rx-flt-signed
#import	"/internals/utils.typ"		:   mild-panic

#let	units(
	units				: (:),
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	value,
) = {
	if type(value) in types {
		return value
	}


	let	rx				=   regex("^" + rx-flt-signed + "(" + units.keys().join("|") + ")$")

	if type(value) == std.str and value.trim().contains(rx) {
		let	(_, signs, num, _, unit)	=   value.trim().matches(rx).first().captures
		let	negative			=   calc.odd(signs.split("").filter(x => x == "-").len())

		return std.float(num) * units.at(unit) * {
			if negative {
				-1
			} else {
				 1
			}
		}
	}


	mild-panic(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"could not convert to " + repr(types.first()) + ": " + repr(value),
	)
}


#let	length(
	quiet				:   false,
	default				:   auto,
	value,
) = units(
	units				: (
		"pt"				:   1pt,
		"mm"				:   1mm,
		"cm"				:   1cm,
		"in"				:   1in,
		"em"				:   1em,
	),
	quiet				:   quiet,
	default				:   default,
	types				:  (std.length,),
	value,
)


#let	fraction(
	quiet				:   false,
	default				:   auto,
	value,
) = units(
	units				: (
		"fr"				:   1fr,
	),
	quiet				:   quiet,
	default				:   default,
	types				:  (std.fraction,),
	value,
)


#let	ratio(
	quiet				:   false,
	default				:   auto,
	value,
) = units(
	units				: (
		"%"				:   1%,
	),
	quiet				:   quiet,
	default				:   default,
	types				:  (std.ratio,),
	value,
)


#let	angle(
	quiet				:   false,
	default				:   auto,
	value,
) = units(
	units				: (
		"deg"				:   1deg,
		"rad"				:   1rad,
	),
	quiet				:   quiet,
	default				:   default,
	types				:  (std.angle,),
	value,
)


