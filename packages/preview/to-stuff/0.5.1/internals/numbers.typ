
#import	"/internals/utils.typ"		:   mild-panic

#let	rx-int-number			=  "[[:digit:]]+"
#let	rx-flt-number			=  "[[:digit:]]*\.?[[:digit:]]+(e[+-]?[[:digit:]]+)?"
#let	rx-xob-number			=  "0([xob])(.+)"

#let	rx-int-signed			=  "(([-+\s]*)(" + rx-int-number + "))"
#let	rx-flt-signed			=  "(([-+\s]*)(" + rx-flt-number + "))"
#let	rx-xob-signed			=  "(([-+\s]*)"  + rx-xob-number +  ")"


#let	int_from_base(value, base)	= {
	let	digits				=  "0123456789abcdefghijklmnopqrstuvwxyz"
	let	max				=   digits.len()

	if base != calc.clamp(base, 2, max) {
		// Intentionally non-suppressible panic.
		panic("Base must be between 2 and {max}: {base}"
			.replace("{max}",	max)
			.replace("{base}",	base)
		)
	}

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
	quiet				:   false,
	default				:   auto,
	types				:  ( ),
	value,
) = {
	let	(_, signs, xob, num)		=   value.trim().matches(regex("^" + rx-xob-signed + "$")).first().captures
	let	negative			=   calc.odd(signs.split("").filter(x => x == "-").len())

	let	v				=   int_from_base(num, (
			x				:   16,
			o				:    8,
			b				:    2,
		)
		.at(xob))

	if type(v) == std.str {
		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			v,
		)
	}

	return v * {
		if negative {
			-1
		} else {
			 1
		}
	}
}

#let	int(
	quiet				:   false,
	default				:   auto,
	value,
) = {
	let	types				= (
		std.int,
	)

	if type(value) in types {
		return value
	}


	if type(value) == std.str {
		let	rx				=   regex("^" + rx-int-signed + "$")

		if value.trim().contains(rx) {
			let	(_, signs, num)			=   value.trim().matches(rx).first().captures
			let	negative			=   calc.odd(signs.split("").filter(x => x == "-").len())

			return std.int(std.float(num) * {
				if negative {
					-1
				} else {
					 1
				}
			})
		}

		if value.trim().contains(regex("^" + rx-xob-signed + "$")) {
			return xob(
				quiet				:   quiet,
				default				:   default,
				types				:   types,
				value,
			)
		}
	}


	mild-panic(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"could not convert to int: " + repr(value),
	)
}



#let	float(
	quiet				:   false,
	default				:   auto,
	value,
) = {
	let	types				= (
		std.float,
	)

	if type(value) in types {
		return value
	}


	let	rx				=   regex("^" + rx-flt-signed + "$")

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


	mild-panic(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"could not convert to float: " + repr(value),
	)
}


#let	number(
	quiet				:   false,
	default				:   auto,
	value,
) = {
	let	types				= (
		std.int,
		std.float,
	)

	if type(value) in types {
		return value
	}


	if type(value) == std.str {
		let	vals				= (
			int(default : none, value),
			float(default : none, value),
		)

		vals				=   vals.filter(x => none != x).dedup()

		if vals.len() > 0 {
			return vals.last()
		}

		if value.trim().contains(regex("^" + rx-xob-signed + "$")) {
			return xob(
				quiet				:   quiet,
				default				:   default,
				types				:   types,
				value,
			)
		}
	}


	mild-panic(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"could not convert to int or float: " + repr(value),
	)
}

