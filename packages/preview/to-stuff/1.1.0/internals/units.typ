
#import	"/internals/numbers.typ"	:   rx-quantity
#import	"/internals/utils.typ"		:   mild-panic, neg

#let	units(
	units				: (:),
	default				:   auto,
	types				: ( ),
	value,
) = {
	if type(value) in types {
		return value
	}


	let	rx				=   regex("^" + rx-quantity + "(" + units.keys().join("|") + ")$")

	if type(value) == std.str and value.trim().contains(rx) {
		let	(_, signs, num, _, unit)	=   value.trim().matches(rx).first().captures

		return std.float(num) * units.at(unit) * neg(signs)
	}


	mild-panic(
		default				:   default,
		types				:   types,
		"could not convert to " + repr(types.first()) + ": " + repr(value),
	)
}


#let	length(
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
	default				:   default,
	types				:  (std.length,),
	value,
)


#let	fraction(
	default				:   auto,
	value,
) = units(
	units				: (
		"fr"				:   1fr,
	),
	default				:   default,
	types				:  (std.fraction,),
	value,
)


#let	ratio(
	default				:   auto,
	value,
) = units(
	units				: (
		"%"				:   1%,
	),
	default				:   default,
	types				:  (std.ratio,),
	value,
)


#let	angle(
	default				:   auto,
	value,
) = units(
	units				: (
		"deg"				:   1deg,
		"rad"				:   1rad,
	),
	default				:   default,
	types				:  (std.angle,),
	value,
)


