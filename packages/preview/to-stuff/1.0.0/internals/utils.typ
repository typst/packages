
#let	neg(signs)			=   signs.split("").filter(x => x == "-").map(x => -1).product(default : 1)

#let	list-predefined(type)		=   dictionary(std).pairs().filter(
						x => std.type(x.last()) == type
					).to-dict()

#let	message-unexpected-keys(
	found				: ( ),
	valid				: ( ),
	value,
) = {
	return "unexpected key/s “" + found.filter(x => x not in valid).join(
		last				:  "”, and “",
		"”, “",
	) + "”; valid keys are “" + valid.join(
		last				:  "”, and “",
		"”, “",
	) + "” in " + value
}

#let	type-unabbreviate(value)	= {
	let	type-str			=   type(value)

	if type-str == type {
		type-str			=   repr(value)
	} else {
		type-str			=   repr(type-str)
	}

	(
		bool				:  "boolean",
		int				:  "integer",
		str				:  "string",
	).at(
		default				:   type-str,
		type-str,
	)
}

#let	debug-value(value)		= {
	if value in (none, auto, true, false) or type(value) in (array, dictionary) {
		repr(value)
	} else {
		(
			type-unabbreviate(value),
			repr(value),
		).join(" ")
	}
}

#let	mild-panic(
	default				:   auto,
	types				: ( ),
	message,
) = {
	if auto != default {
		assert(
			message				:  "to-stuff: “default” argument expected {types}, or none, found {value}"
								.replace("{types}", types.map(type-unabbreviate).join(", "))
								.replace("{value}", debug-value(default)),
			none == default or type(default) in types,
		)

		return default
	}

	panic(message)
}

