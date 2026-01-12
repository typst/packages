
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

#let	type-unabbreviate(type)		= {
	let	type-str			=   repr(type)

	(
		bool				:  "boolean",
		int				:  "integer",
		str				:  "string",
	).at(
		default				:   type-str,
		type-str,
	)
}

#let	mild-message(
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	message,
) = {
	if type(quiet) != std.bool {
		return "“quiet” argument expected boolean, found {unabb} {value}"
			.replace("{unabb}", type-unabbreviate(type(quiet)))
			.replace("{value}", repr(quiet))
	} else if quiet {
		default				 =   none
	}

	if auto != default {
		if none == default or type(default) in types {
			return default
		}

		return "“default” argument expected {types}, or none, found {unabb} {value}"
			.replace("{types}", types.map(type-unabbreviate).join(", "))
			.replace("{unabb}", type-unabbreviate(type(default)))
			.replace("{value}", repr(default))
	}

	message
}

#let	mild-panic(
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	message,
) = {
	default				=   mild-message(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		message,
	)

	if type(default) == std.str {
		panic(default)
	}

	return default
}

