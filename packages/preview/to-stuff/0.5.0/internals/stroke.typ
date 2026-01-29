
#import	"/internals/numbers.typ"	:   number
#import	"/internals/units.typ"		:   length
#import	"/internals/color.typ"		:   color
#import	"/internals/utils.typ"		:   *

#let	valid-preset(
	valid				: ( ),
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	value,
) = {
	if value.trim() in valid {
		return value.trim()
	}

	let	expectations			=   valid.join(
		last				:  "”, or “",
		"”, “",
	)

	mild-message(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"expected “{expected}”, found "
		.replace("{expected}", expectations)
		+ repr(value),
	)
}


#let	stroke-cap-preset(
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	value,
) = valid-preset(
	valid				: ( // Built-in constants
		"butt",
		"round",
		"square",
	),
	quiet				:   quiet,
	default				:   default,
	types				:   types,
	value,
)

#let	stroke-join-preset(
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	value,
) = valid-preset(
	valid				: ( // Built-in constants
		"miter",
		"round",
		"bevel",
	),
	quiet				:   quiet,
	default				:   default,
	types				:   types,
	value,
)

#let	stroke-dash-preset(
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	value,
) = valid-preset(
	valid				: ( // Built-in constants
		"solid",
		"dotted",
		"densely-dotted",
		"loosely-dotted",
		"dashed",
		"densely-dashed",
		"loosely-dashed",
		"dash-dotted",
		"densely-dash-dotted",
		"loosely-dash-dotted",
	),
	quiet				:   quiet,
	default				:   default,
	types				:   types,
	value,
)

#let	stroke-dash-array(
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	value,
) = {
	let	dash				=   value.map(x => {
		if x == "dot" {
			return x
		}

		length(default : none, x)
	})

	if dash.all(x => none != x) {
		return dash
	}

	mild-message(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		"expected array of “dot” or length, found " + repr(value),
	)
}

#let	stroke-dash-dict(
	strict				:   true,
	quiet				:   false,
	default				:   auto,
	types				: ( ),
	value,
) = {
	let	dash				= (
		array				: ( ),
		phase				:   0pt,
	)

	let	test				=   x => x in dash.keys()
	let	maybe				=   value.keys().any(test)
	let	valid				=   value.keys().all(test)

	if not strict and not maybe { // Not attempting to be a dash: let it through
		return none
	}

	if (strict or maybe) and not valid {
		return mild-message(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			message-unexpected-keys(
				found				:   value.keys(),
				valid				:   dash.keys(),
				repr(value),
			),
		)
	}

	if "array" in value {
		dash.array			=   dash.array + stroke-dash-array(value.array)
	}

	if "phase" in value {
		dash.phase			=   dash.phase + length(value.phase)
	}

	dash
}

#let	stroke(
	quiet				:   false,
	default				:   auto,
	value,
) = {
	let	types				= (
		std.stroke,
		std.color,
		std.length,
	)

	if type(value) in types {
		return std.stroke(value)
	}


	if type(default) in types {
		default				=   std.stroke(default)
	}

	// An array of lengths is assumed to be the dash
	if type(value) == array {
		let	dash				=   stroke-dash-array(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			value,
		)

		if type(dash) == array {
			return std.stroke(dash : dash)
		}

		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			dash,
		)
	}

	if type(value) == dictionary {
		let	keys_this			=   value.keys()
		let	keys_valid			= (
			"paint",
			"thickness",
			"dash",
			"cap",
			"join",
			"miter-limit",
		)

		// A dictionary containing valid pattern parameters for keys could be the dash
		let	dash				=   stroke-dash-dict(
			strict				:   false,
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			value,
		)

		if none != dash {
			if type(dash) == str {
				panic(dash)
			}

			if type(dash) == dictionary {
				return std.stroke(
					dash				:   dash,
				)
			}
		}

		// Any other dictionary must be a whole stroke
		if keys_this.all(x => x in keys_valid) {
			if "paint" in value {
				value.paint			=   color(
					quiet				:   quiet,
					default				:   default,
					value.paint,
				)

				if none == value.paint { // Implies default:none
					return none
				}
			}

			if "thickness" in value {
				value.thickness			=   length(
					quiet				:   quiet,
					default				:   default,
					value.thickness,
				)

				if none == value.thickness { // Implies default:none
					return none
				}
			}

			if "dash" in value {
				let	funcs				= (
					array				:   stroke-dash-array,
					dictionary			:   stroke-dash-dict,
					str				:   stroke-dash-preset,
				)

				if repr(type(value.dash)) in funcs {
					let	key				=   repr(type(value.dash))
					let	dash				=   funcs.at(key)(
						quiet				:   quiet,
						default				:   default,
						types				:   types,
						value.dash,
					)

					if none == dash { // Implies default:none
						return none
					}

					if key != "str" and type(dash) == str {
						panic(dash)
					}

					if key == "str" and dash != value.dash.trim() {
						panic(dash)
					}

					value.dash			=   dash
				}
			}

			if "cap" in value {
				let	cap				=   stroke-cap-preset(
					quiet				:   quiet,
					default				:   default,
					types				:   types,
					value.cap,
				)

				if none == cap { // Implies default:none
					return none
				}

				if cap != value.cap.trim() {
					panic(cap)
				}

				value.cap			=   cap
			}

			if "join" in value {
				let	join				=   stroke-join-preset(
					quiet				:   quiet,
					default				:   default,
					types				:   types,
					value.join,
				)

				if none == join { // Implies default:none
					return none
				}

				if join != value.join.trim() {
					panic(join)
				}

				value.join			=   join
			}

			if "miter-limit" in value {
				value.miter-limit		=   number(
					quiet				:   quiet,
					default				:   default,
					value.miter-limit,
				)

				if none == value.miter-limit { // Implies default:none
					return none
				}
			}

			return std.stroke(value)
		}


		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			message-unexpected-keys(
				found				:   keys_this,
				valid				:   keys_valid,
				repr(value),
			),
		)
	}


	let	panic-message			=  "could not convert to stroke: " + repr(value)

	// We’ve covered full stroke definitions, as well as individual paint, thickness and dash values;
	// an individual cap, join or miter-limit value isn’t really worth worrying about. That leaves
	// string depictions of compound paint+length+dash declarations.
	if type(value) != std.str {
		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			panic-message,
		)
	}


	// Splitting on `+` and evaluating components separately catches more edge cases than one big regex,
	// e.g. a non-ridiculous regex would probably pass `invalid + 3pt`, which would be an error.
	// Allowing addition of multiple paints/thicknesses is a little cheeky; we can’t easily do subtraction
	// since splitting on `-` breaks dash pattern strings.
	let	o				= (:)

	for	c in value.split("+").map(std.str.trim).filter(x => x != "") {
		let	d				=   stroke-dash-preset(default : none, c)
		if none != d {
			if "dash" in o {
				return mild-panic(
					quiet				:   quiet,
					default				:   default,
					types				:   types,
					"cannot add two stroke arrays: " + repr(value),
				)
			}

			o.insert("dash", d)
			continue
		}

		let	k				=   color(default : none, c)
		if none != k {
			o.insert(
				"paint",
				if "paint" in o {
					std.color.mix(o.paint, k)
				} else {
					k
				},
			)
			continue
		}

		let	t				=   length(default : none, c)
		if none != t {
			o.insert(
				"thickness",
				t + o.at(
					default				:   0pt,
					"thickness",
				),
			)
			continue
		}

		// Value cannot be processed
		return mild-panic(
			quiet				:   quiet,
			default				:   default,
			types				:   types,
			panic-message,
		)
	}


	if o.keys().len() > 0 {
		return std.stroke(o)
	}


	return mild-panic(
		quiet				:   quiet,
		default				:   default,
		types				:   types,
		panic-message,
	)
}

