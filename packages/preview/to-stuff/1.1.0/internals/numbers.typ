
#import	"/internals/utils.typ"		:   mild-panic, neg

#let	rx-catchall			=  "(([-+\s]*)([[:digit:].]+(e[+-]?[[:digit:]]+)?))"
#let	rx-decimals			=  "(([-+\s]*)([[:digit:].]+))"
#let	rx-quantity			=  "(([-+\s]*)([[:digit:]]*\.?[[:digit:]]+(e[+-]?[[:digit:]]+)?))"
#let	rx-prefixed			=  "(([-+\s]*)0([xob])(\S+))"

#let	int_from_base(value, base)	= {
	let	digits				=  "0123456789abcdefghijklmnopqrstuvwxyz"
	let	max				=   digits.len()

	assert.eq(
		message				:  "Base must be between 2 and {max}: {base}"
							.replace("{max}",	std.str(max))
							.replace("{base}",	std.str(base)),
		base,
		calc.clamp(base, 2, max),
	)

	let	v				=   lower(value)
	let	d				=   digits.slice(0, base)

	if none != v.match(regex("([^" + d + "]+)")) {
		let	base				=   std.str(base)
		let	debug				= (
			"16"				:  "hexadecimal",
			 "8"				:  "octal",
			 "2"				:  "binary",
		).at(
			default				:  "base-" + base,
			base,
		)

		let	xob				= (
			"16"				:  "0x",
			 "8"				:  "0o",
			 "2"				:  "0b",
		).at(
			default				:  "",
			base
		)

		return	"invalid {base} number: {value}"
				.replace("{value}",	repr(xob + value))
				.replace("{base}",	debug)
	}

	return	 v
		.rev()
		.clusters()
		.enumerate()
		.map(((x, c)) => d.position(c) * calc.pow(base, x))
		.sum()
}

#let	xob(
	default				:   auto,
	types				:  ( ),
	value,
) = {
	let	(_, signs, xob, num)		=   value.matches(regex("^" + rx-prefixed + "$")).first().captures

	let	v				=   int_from_base(num, (
			x				:   16,
			o				:    8,
			b				:    2,
		)
		.at(xob))

	if type(v) == std.str {
		return mild-panic(
			default				:   default,
			types				:   types,
			v,
		)
	}

	v * neg(signs)
}


#let	number(
	default				:   auto,
	value,
) = {
	let	types				= (
		std.int,
		std.float,
		std.decimal,
	)

	if type(value) in types {
		return value
	}


	if type(value) == std.str {
		let	value				=   value.trim()

		if value.contains(regex("^" + rx-prefixed + "$")) {
			return xob(
				default				:   default,
				types				:   types,
				value,
			)
		}

		let	rx				=   regex("^" + rx-catchall + "$")

		// Regex is a little inadequate, so some extra constraints are needed here
		if value != "." and value.contains(rx) and value.matches(".").len() <= 1 {
			let	(_, signs, num, _)		=   value.matches(rx).first().captures

			if "." in value or "e" in value {
				return std.float(num) * neg(signs)
			} else {
				return std.int(num) * neg(signs)
			}
		}
	}


	mild-panic(
		default				:   default,
		types				:   types,
		"could not convert to int or float: " + repr(value),
	)
}


#let	int(
	default				:   auto,
	value,
) = {
	let	types				= (
		std.int,
	)

	if type(value) in types {
		return value
	}

	// Non-integer inputs are fine but default MUST be an integer
	if type(value) in (std.float, std.decimal) {
		return std.int(value)
	}


	if type(value) == std.str {
		let	num				=   number(
			default				:   none,
			value,
		)

		if none != num {
			return std.int(num)
		}
	}


	mild-panic(
		default				:   default,
		types				:   types,
		"could not convert to int: " + repr(value),
	)
}


#let	float(
	default				:   auto,
	value,
) = {
	let	types				= (
		std.int,
		std.float,
		std.decimal,
	)

	if type(value) in types {
		return std.float(value)
	}


	if type(value) == std.str {
		let	num				=   number(
			default				:   none,
			value,
		)

		if none != num {
			return std.float(num)
		}
	}


	if type(default) in types {
		default				=   std.float(default)
	}

	mild-panic(
		default				:   default,
		types				:   types,
		"could not convert to float: " + repr(value),
	)
}


#let	decimal(
	default				:   auto,
	value,
) = {
	let	types				= (
		std.int,
		std.decimal,
	)

	if type(value) in types {
		return std.decimal(value)
	}


	if type(value) == std.str {
		let	value				=   value.trim()

		if value.contains(regex("^" + rx-prefixed + "$")) {
			let	num				=   xob(
				default				:   default,
				types				:   types,
				value,
			)

			if none != num {
				return std.decimal(num)
			}
		}

		let	rx				=   regex("^" + rx-decimals + "$")

		// Regex is a little inadequate, so some extra constraints are needed here
		if value != "." and value.contains(rx) and value.matches(".").len() <= 1 {
			let	(_, signs, num)			=   value.matches(rx).first().captures

			return std.decimal(num) * neg(signs)
		}
	}


	if type(default) in types {
		default				=   std.decimal(default)
	}

	mild-panic(
		default				:   default,
		types				:   types,
		"could not convert to decimal: " + repr(value),
	)
}

