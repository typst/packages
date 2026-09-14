
#import	"/internals/scalars.typ"	:   rx-flt-signed
#import	"/internals/units.typ"		:   length, ratio
#import	"/internals/utils.typ"		:   message-unexpected-keys

#let	relative(
	quiet				:   false,
	value,
) = {
	if type(value) in (std.relative, std.ratio, std.length) {
		return value + 0pt + 0%
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
					value.at(field)			=   func(quiet : true, value.at(field))

					if none == value.at(field) {
						if quiet {
							return none
						}

						panic("could not convert “" + field + "” component to " + field + ": " + original)
					}
				}
			}

			return value.values().sum()
		}

		if quiet {
			return none
		}

		panic(message-unexpected-keys(
			found				:   keys_this,
			valid				:   keys_valid.keys(),
			repr(value),
		))
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
				parts.ratio			=   parts.ratio + ratio(quiet : true, match.text)
			} else {
				parts.length			=   parts.length + length(quiet : true, match.text)
			}

			value				=   value.slice(match.end)
		}

		return relative(parts)
	}

	if quiet {
		return none
	}

	panic("could not convert to relative: " + repr(value))
}

