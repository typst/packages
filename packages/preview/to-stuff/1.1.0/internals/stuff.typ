
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

#let	debug-types(
	types,
	also				:   none,
) = {
	let	list				=   types.map(x => "std." + x).sorted() + (also,)

	list.filter(x => none != x).join(
		last				:  ", or ",
		", ",
	)
}


#let	stuff(
	recursive			:   false,
	arguments-collapse		:   false,
	numbers-as			:   auto,
	none-from			: ( ),
	skip-strings			: ( ),
	skip-dictionaries		: ( ),
	value,
) = {
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

	let	types-number			= (
		int				:   n.int,
		float				:   n.float,
		decimal				:   n.decimal,
		version				:   v.version,
	)

	assert(
		message				:  "to-stuff: “numbers-as” argument expected {types}, found {value}"
							.replace("{types}", debug-types(types-number.keys(), also: "auto"))
							.replace("{value}", debug-value(numbers-as)),
		auto == numbers-as or repr(numbers-as) in types-number,
	)

	assert(
		message				:  "to-stuff: “none-from” argument expected string or array of strings, found {value}"
							.replace("{value}", debug-value(none-from)),
		type(none-from) == array or type(none-from) == std.str,
	)

	let	none-from			= ( none-from, ).flatten()
	for test in none-from {
		assert.eq(
			message				:  "to-stuff: “none-from” values expected strings, found {val}"
								.replace("{val}", debug-value(test)),
			type(test),
			std.str,
		)
	}

	let	funcs-dictionary		= (
		alignment			:   a.alignment,
		relative			:   r.relative,
		stroke				:   s.stroke,
	)

	assert(
		message				:  "to-stuff: “skip-dictionaries” argument expected type or array of types, found {value}"
							.replace("{value}", debug-value(skip-dictionaries)),
		type(skip-dictionaries) == array or type(skip-dictionaries) == std.type,
	)

	let	types				=   debug-types(funcs-dictionary.keys())
	let	skip-dictionaries		= ( skip-dictionaries, ).flatten()
	for test in skip-dictionaries {
		assert(
			message				:  "to-stuff: “skip-dictionaries” values expected {types}, found {value}"
								.replace("{types}", types)
								.replace("{value}", debug-value(test)),
			repr(test) in funcs-dictionary,
		)
	}


	let	funcs-string			= (
		bool				:   b.bool,
		alignment			:   a.alignment,
		direction			:   d.direction,
		number				:   types-number.at(
			default				:   n.number,
			repr(numbers-as),
		),
		version				:   v.version,
		angle				:   u.angle,
		fraction			:   u.fraction,
		length				:   u.length,
		ratio				:   u.ratio,
		relative			:   r.relative,
		color				:   c.color,
		stroke				:   s.stroke,
	)

	assert(
		message				:  "to-stuff: “skip-strings” argument expected type or array of types, found {value}"
							.replace("{value}", debug-value(skip-strings)),
		type(skip-strings) == array or type(skip-strings) == std.type,
	)

	let	skip-strings			= ( skip-strings, ).flatten()
	let	types				=   debug-types(funcs-string.keys().filter(x => x != "number"))
	for test in skip-strings {
		assert(
			message				:  "to-stuff: “skip-strings” values expected {types}, found {value}"
								.replace("{types}", types)
								.replace("{value}", debug-value(test)),
			repr(test) in funcs-string,
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
		skip-strings			:   skip-strings,
		skip-dictionaries		:   skip-dictionaries,
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
		let	skip-dictionaries		=   skip-dictionaries.map(repr)
		for (type, func) in funcs-dictionary.pairs() {
			if type not in skip-dictionaries {
				let	native				=   func(..defaults, value)
				if none != native {
					return native
				}
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


	let	skip-strings			=   skip-strings.map(repr)
	for (type, func) in funcs-string.pairs() {
		if type not in skip-strings {
			let	native				=   func(..defaults, value)
			if none != native {
				return native
			}
		}
	}


	value
}

