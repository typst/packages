
#import	"/internals/numbers.typ"	as  n
#import	"/internals/units.typ"		as  u
#import	"/internals/alignment.typ"	as  a
#import	"/internals/bool.typ"		as  b
#import	"/internals/color.typ"		as  c
#import	"/internals/direction.typ"	as  d
#import	"/internals/relative.typ"	as  r
#import	"/internals/stroke.typ"		as  s
#import	"/internals/version.typ"	as  v
#import	"/internals/utils.typ"		:   debug-value


#let	stuff(
	recursive			:   false,
	arguments-collapse		:   false,
	numbers-as			:   auto,
	none-from			: ( ),
	value,
) = {
	let	number-types			= (
		int				:   n.int,
		float				:   n.float,
		decimal				:   n.decimal,
		version				:   v.version,
	)

	assert.eq(
		message				:  "to-stuff: “recursive” argument expected boolean, found {value}"
							.replace("{value}", debug-value(recursive)),
		type(recursive),
		std.bool,
	)

	assert.eq(
		message				:  "to-stuff: “arguments-collapse” argument expected boolean, found {value}"
							.replace("{value}", debug-value(arguments-collapse)),
		type(arguments-collapse),
		std.bool,
	)

	assert(
		message				:  "to-stuff: “numbers-as” argument expected {types}, or auto, found {value}"
							.replace("{types}", number-types.keys().map(x => "std." + x).join(", "))
							.replace("{value}", debug-value(numbers-as)),
		auto == numbers-as or repr(numbers-as) in number-types,
	)

	assert.eq(
		message				:  "to-stuff: “none-from” argument expected array of strings, found {value}"
							.replace("{value}", debug-value(none-from)),
		type(none-from),
		array,
	)

	for test in none-from {
		assert.eq(
			message				:  "to-stuff: “none-from” values expected strings, found {val}"
								.replace("{val}", debug-value(test)),
			type(test),
			std.str,
		)
	}


	let	defaults			= (
		default				:   none,
	)

	let	args				= (
		recursive			:   recursive,
		arguments-collapse		:   arguments-collapse,
		numbers-as			:   numbers-as,
		none-from			:   none-from,
	)

	if type(value) == arguments and recursive {
		if arguments-collapse {
			if 0 == value.named().len() {
				return stuff(..args, value.pos())
			}

			if 0 == value.pos().len() {
				return stuff(..args, value.named())
			}
		}


		// Directly processing value.named() as a unit runs the risk of mistaking it for
		// a valid dictionary conversion target (e.g. strokes) when we have not explicitly
		// enabled argument-collapsing.
		let	dict				= (:)

		for (k, v) in value.named() {
			dict.insert(k, stuff(..args, v))
		}

		return arguments(
			..stuff(..args, value.pos()),
			..dict,
		)
	}


	if type(value) == array {
		// Prioritise recursing into arrays over assuming they’re versions
		if recursive {
			return value.map(stuff.with(..args))
		}

		let	native				=   v.version(..defaults, value)
		if none != native {
			return native
		}
	}


	if type(value) == dictionary {
		// Prioritise assuming dictionaries are type structures over recursing into them
		for func in(
			a.alignment,
			r.relative,
			s.stroke,
		) {
			let	native				=   func(..defaults, value)
			if none != native {
				return native
			}
		}

		if recursive {
			return value.keys().zip(stuff(..args, value.values())).to-dict()
		}
	}


	if type(value) == std.str {
		let	trimmed				=   value.trim()

		if trimmed == "auto" {
			return auto
		}

		for from in none-from.map(lower) {
			if lower(trimmed) == from {
				return none
			}
		}
	}


	for func in (
		b.bool,
		a.alignment,
		d.direction,
		number-types.at(
			default				:   n.number,
			repr(numbers-as),
		),
		v.version,
		u.angle,
		u.fraction,
		u.length,
		u.ratio,
		r.relative,
		c.color,
		s.stroke,
	) {
		let	native				=   func(..defaults, value)
		if none != native {
			return native
		}
	}


	value
}

