
#import	"/internals/numbers.typ"	:   int
#import	"/internals/utils.typ"		:   mild-panic, debug-value

#let	version(
	default				:   auto,
	value,
) = {
	let	types				= (
		std.version,
	)

	if type(value) in types {
		return value
	}


	let	panic-message			=  "could not convert to version: " + repr(value)

	if type(value) == array and value.len() > 0 {
		return std.version(..value.flatten().map(version.with(
			default				:   default,
		)).map(array))
	}

	if type(value) == std.int {
		if value < 0 {
			return mild-panic(
				default				:   default,
				types				:   types,
				"number must be greater than zero: " + repr(value),
			)
		}

		return std.version(value)
	}

	if type(value) == std.str {
		if regex("^\s*\d+(\s*\.\s*\d+)*\s*$") not in value {
			return mild-panic(
				default				:   default,
				types				:   types,
				panic-message,
			)
		}


		let	to-int				=   int.with(
			default				:   default,
		)

		return if "." in value {
			std.version(..value.split(".").map(to-int))
		} else {
			std.version(to-int(value))
		}
	}

	// Special error message in case of non-integer numbers
	if type(value) in (std.float, std.decimal) {
		return mild-panic(
			default				:   default,
			types				:   types,
			"expected integer, array or version, found " + debug-value(value)
		)
	}


	mild-panic(
		default				:   default,
		types				:   types,
		panic-message,
	)
}

