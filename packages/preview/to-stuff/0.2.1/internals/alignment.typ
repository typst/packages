
#let	alignment(
	quiet				:   false,
	value,
) = {
	if type(value) == std.alignment {
		return value
	}

	if type(value) == dictionary {
		let	original			=   repr(value)
		let	keys_this			=   value.keys()
		let	keys_valid			= (
			x				:  "horizontal",
			y				:  "vertical",
		)

		if keys_this.all(x => x in keys_valid.keys()) {
			for (field, axis) in keys_valid {
				if field in value {
					value.at(field)			=   alignment(quiet : true, value.at(field))

					if none == value.at(field) or value.at(field).axis() != axis {
						if quiet {
							return none
						}

						panic("could not convert “" + field + "” component to " + axis + " alignment: " + original)
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


	let	panic-message			=  "could not convert to alignment: " + repr(value)

	if type(value) != std.str {
		if quiet {
			return none
		}

		panic(panic-message)
	}


	let	value				=   value.trim()
	let	constants			= ( // Built-in constants
		start				:   std.alignment.start,
		end				:   std.alignment.end,
		left				:   std.alignment.left,
		center				:   std.alignment.center,
		right				:   std.alignment.right,
		top				:   std.alignment.top,
		horizon				:   std.alignment.horizon,
		bottom				:   std.alignment.bottom,
	)

	if value in constants {
		return constants.at(value)
	}


	let	parts				=   value.split("+").map(std.str.trim)

	if not parts.all(x => x in constants) {
		if quiet {
			return none
		}

		panic(panic-message)
	}

	let	axes				=   parts.map(x => constants.at(x).axis())

	if axes.at(0) == axes.at(1) {
		if quiet {
			return none
		}

		panic("cannot add two " + axes.at(0) + " alignments: " + repr(value))
	}

	return parts.map(alignment).sum()
}

