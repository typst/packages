
#import	"/internals/basic.typ"		:   length, message-unexpected-keys
#import	"/internals/color.typ"		:   color

#let	stroke-dash-preset(
	quiet				:   false,
	value,
) = {
	let	valid				= ( // Built-in constants
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
	)

	if value.trim() in valid {
		return value.trim()
	}

	if quiet {
		return none
	}

	"valid predefined dash patterns are “" + valid.join(
		last				:  "”, and “",
		"”, “",
	) + "”, found " + repr(value)
}

#let	stroke-dash-array(
	quiet				:   false,
	value,
) = {
	let	dash				=   value.map(x => {
		if x == "dot" {
			return x
		}

		length(quiet : true, x)
	})

	if dash.all(x => none != x) {
		return dash
	}

	if quiet {
		return none
	}

	"expected array of “dot” or length, found " + repr(value)
}

#let	stroke-dash-dict(
	strict				:   true,
	quiet				:   false,
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
		if quiet {
			return none
		}

		return message-unexpected-keys(
			found				:   value.keys(),
			valid				:   dash.keys(),
			repr(value),
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
	value,
) = {
	if type(value) in (std.stroke, std.color, std.length) {
		return std.stroke(value)
	}

	// An array of lengths is assumed to be the dash
	if type(value) == array {
		let	dash				=   stroke-dash-array(
			quiet				:   quiet,
			value,
		)

		if type(dash) == array {
			return std.stroke(dash : dash)
		}

		if quiet {
			return none
		}

		panic(dash)
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
					value.paint,
				)

				if none == value.paint { // Implies quiet
					return none
				}
			}

			if "thickness" in value {
				value.thickness			=   length(
					quiet				:   quiet,
					value.thickness,
				)

				if none == value.thickness { // Implies quiet
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
						value.dash,
					)

					if none == dash { // Implies quiet
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

			if "miter-limit" in value {
				value.miter-limit		=   float(value.miter-limit)

				// #TODO: handle failed float parsing?
			}

			return std.stroke(value)
		}


		if quiet {
			return none
		}

		panic(message-unexpected-keys(
			found				:   keys_this,
			valid				:   keys_valid,
			repr(value),
		))
	}


	let	panic-message			=  "could not convert to stroke: " + repr(value)

	// We’ve covered full stroke definitions, as well as individual paint, thickness and dash values;
	// an individual cap, joint or miter-limit value isn’t really worth worrying about. That leaves
	// string depictions of compound paint+length+dash declarations.
	if type(value) != std.str {
		if quiet {
			return none
		}

		panic(panic-message)
	}


	// Splitting on `+` and evaluating components separately catches more edge cases than one big regex,
	// e.g. a non-ridiculous regex would probably pass `invalid + 3pt`, which would be an error.
	// Allowing addition of multiple paints/thicknesses is a little cheeky; we can’t easily do subtraction
	// since splitting on `-` breaks dash pattern strings.
	let	o				= (:)

	for	c in value.split("+").map(std.str.trim).filter(x => x != "") {
		let	d				=   stroke-dash-preset(quiet : true, c)
		if none != d {
			if "dash" in o {
				if quiet {
					return none
				}

				panic("cannot add two stroke arrays: " + repr(value))
			}

			o.insert("dash", d)
			continue
		}

		let	k				=   color(quiet : true, c)
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

		let	t				=   length(quiet : true, c)
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
		if quiet {
			return none
		}

		panic(panic-message)
	}


	if o.keys().len() > 0 {
		return std.stroke(o)
	}

	if quiet {
		return none
	}

	panic(panic-message)
}

