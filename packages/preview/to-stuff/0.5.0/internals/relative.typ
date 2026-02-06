
#import	"/internals/numbers.typ"	:   rx-flt-signed
#import	"/internals/units.typ"		:   length, ratio
#import	"/internals/utils.typ"		:   *

#let	relative(
	quiet				:   false,
	default				:   auto,
	value,
) = {
	let	types				= (
		std.relative,
		std.ratio,
		std.length,
	)

	if type(value) in types {
		return value + 0pt + 0%
	}


	if type(default) in types {
		default				+=   0pt + 0%
	}

	if type(value) == dictionary {
		let	original			=   repr(value)
		let	keys_this			=   value.keys()
		let	keys_valid			= (
			ratio				:   ratio,
			length				:   length,
		)

		if keys_this.all(x => x in keys_valid.keys()) {
			for (field, func) in keys_valid {
				if field in value {
					value.at(field)			=   func(default : none, value.at(field))

					if none == value.at(field) {
						return mild-panic(
							quiet				:   quiet,
							default				:   default,
							types				:   types,
							"could not convert “{field}” component to {field}: "
							.replace("{field}", field)
							+ original,
						)
					}
				}
			}

			return value.values().sum()
		}

		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			message-unexpected-keys(
				found				:   keys_this,
				valid				:   keys_valid.keys(),
				repr(value),
			),
		)
	}


	let	rx				=  "^(" + rx-flt-signed + "(pt|mm|cm|in|em|%))"

	if type(value) == std.str and value.trim().contains(regex(rx + "+$")) {
		let	value				=   value.trim()
		let	parts				= (
			ratio				:   0%,
			length				:   0pt,
		)

		while value.len() > 0 {
			let	match				=   value.match(regex(rx))

			if none == match {
				break
			}

			if match.captures.at(5) == "%" {
				parts.ratio			+=   ratio(default : 0%, match.text)
			} else {
				parts.length			+=   length(default : 0pt, match.text)
			}

			value				=   value.slice(match.end)
		}

		return relative(parts)
	}


	mild-panic(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"could not convert to relative: " + repr(value),
	)
}

