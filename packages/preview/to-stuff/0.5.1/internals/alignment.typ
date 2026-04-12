
#import	"/internals/utils.typ"		:   *

#let	alignment(
	quiet				:   false,
	default				:   auto,
	value,
) = {
	let	types				= (
		std.alignment,
	)

	if type(value) in types {
		return value
	}

	if type(value) == dictionary and value.len() > 0 {
		let	original			=   repr(value)
		let	keys_this			=   value.keys()
		let	keys_valid			= (
			x				:  "horizontal",
			y				:  "vertical",
		)

		if keys_this.all(x => x in keys_valid.keys()) {
			for (field, axis) in keys_valid {
				if field in value {
					value.insert(field, alignment(default : none, value.at(field)))

					if none == value.at(field) or value.at(field).axis() != axis {
						return mild-panic(
							quiet				:   quiet,
							default				:   default,
							types				:   types,
							"could not convert “{field}” component to {axis} alignment: "
							.replace("{axis}",	axis)
							.replace("{field}",	field)
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


	let	panic-message			=  "could not convert to alignment: " + repr(value)

	if type(value) != std.str {
		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			panic-message,
		)
	}


	let	value				=   value.trim()
	let	constants			=   list-predefined(std.alignment)

	if value in constants {
		return constants.at(value)
	}


	let	parts				=   value.split("+").map(std.str.trim)

	if not parts.all(x => x in constants) {
		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			panic-message,
		)
	}

	let	axes				=   parts.map(x => constants.at(x).axis())

	if axes.at(0) == axes.at(1) {
		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			"cannot add two {axis} alignments: "
			.replace("{axis}", axes.at(0))
			+ repr(value),
		)
	}


	return parts.map(alignment).sum()
}

