
#import	"/internals/basic.typ"			:   rx-numeric, length, ratio

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

		panic("unexpected key/s “" + keys_this.filter(x => x not in keys_valid.keys()).join(
			last				:  "”, and “",
			"”, “",
		) + "”; valid keys are “" + keys_valid.keys().join(
			last				:  "”, and “",
			"”, “",
		) + "” in " + repr(value))
	}


	let	rx				=  "^(" + rx-numeric + "(pt|mm|cm|in|em|%))"

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

