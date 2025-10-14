
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
		let	keys_valid			= ("ratio", "length")

		if keys_this.all(x => x in keys_valid) {
			if "ratio" in value {
				value.ratio			=   ratio(quiet : true, value.ratio)

				if none == value.ratio {
					if quiet {
						return none
					}

					panic("could not convert “ratio” component to ratio: " + original)
				}
			}

			if "length" in value {
				value.length			=   length(quiet : true, value.length)

				if none == value.length {
					if quiet {
						return none
					}

					panic("could not convert “length” component to length: " + original)
				}
			}

			return value.values().sum()
		}

		if quiet {
			return none
		}

		panic("unexpected key/s “" + keys_this.filter(x => x not in keys_valid).join(
			last				:  "”, and “",
			"”, “",
		) + "”; valid keys are “" + keys_valid.join(
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
				let	to				=   ratio(quiet : true, match.text)

				if none != to {
					parts.ratio			=   parts.ratio + to
				}
			} else {
				let	to				=   length(quiet : true, match.text)

				if none != to {
					parts.length			=   parts.length + to
				}
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

