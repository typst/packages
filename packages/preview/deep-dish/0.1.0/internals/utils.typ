
#let	tidy				=   z => (z,).flatten()


#let	type-smarter(value)		= {
	if value in (none, auto) {		// Treat none and auto as their own types
		return value
	}

	let	type-of				=   type(value)

	if type-of == std.type {		// The type of a type should be itself
		return value
	}

	type-of
}

#let	type-ish(value)			= {
	let	type-smart			=   type-smarter(value)

	// There are 35 native types in Typst 0.15.x, but we really only care about
	// arrays and dictionaries. We might conceivably extend to the arguments type
	// later, but that’ll probably be complicated.
	if type-smart in (none, array, dictionary) {
		return type-smart
	}

	auto
}

#let	type-unabbreviate(value)	=   str(type-smarter(value))


#let	str-is-int(string)		=   regex("^-?\d+$") in string

#let	str-format(string, args)	= {
	for (find, replace) in args.pairs() {
		string				=   string.replace("{" + find + "}", replace)
	}

	string
}


#let	debug-message(func, msg, args)	=   str-format("{package}.{function}(): " + msg, args + (
	package				:   toml("/typst.toml").package.name,
	function			:   func,
))

#let	debug-value(value)		= {
	if value in (none, auto, true, false) or type(value) in (array, dictionary) {
		return repr(value)
	}

	str-format("{type} {value}", (
		value				:   repr(value),
		type				:   if type(value) == std.type {
			"type name"
		} else {
			type-unabbreviate(value)
		},
	))
}


#let	arg-assert-expected(
	func,
	arg,
	options,
) = assert(
	message				:   debug-message(func, "unexpected argument “{arg}”, expected “{list}”", (
		arg				:   arg,
		list				:   options.join(
			last				:  "”, or “",
			"”, “",
		),
	)),

	arg in options,
)

#let	arg-assert-types(
	func,
	arg,
	value,
	types,
) = assert(
	message				:   debug-message(func, "“{arg}” expected {types}, found {value}", (
		arg				:   arg,
		value				:   debug-value(value),
		types				:   types.map(type-unabbreviate).join(
			last				:  ", or ",
			", ",
		),

	)),

	type-smarter(value) in types,
)

#let	arg-assert-values(
	func,
	arg,
	value,
	options,
) = assert(
	message				:   debug-message(func, "“{arg}” expected “{options}”, or a function, found {value}", (
		arg				:   arg,
		value				:   debug-value(value),
		options				:   options.join("”, “"),
	)),

	value in options,
)

#let	arg-assert-numeric(
	func,
	index,
) = assert(
	message				:   debug-message(func, "array index must be numeric, found {index}", (
		index				:   debug-value(index),
	)),

	str-is-int(index),
)

