
#import	"basic.typ"			:   length
#import	"color.typ"			:   color

#let	stroke-dash-array		=   z => {
	let	d				=   z.map(x => {
		if x == "dot" {
			x
		} else {
			// #TODO: How is this working correctly without passing quiet:true?
			// #TODO: How does this not *understand* quiet:true!?
			length(x)
		}
	})

	if d.any(x => x == none) {
		if quiet {
			return none
		}

		panic("expected array of “dot” or length, found " + repr(z))
	}

	d
}

#let	stroke(
	quiet				:   false,
	value,
) = {
	if type(value) in (std.stroke, std.color, std.length) {
		return std.stroke(value)
	}

	if type(value) == array {
		// An array of lengths is assumed to be the dash
		return std.stroke(
			dash				:   stroke-dash-array(value),
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

		// A dictionary could be a whole stroke
		if keys_this.all(x => x in keys_valid) {
			if "paint" in value {
				value.paint			=   color(value.paint)
			}

			if "thickness" in value {
				value.thickness			=   length(value.thickness)
			}

			if "dash" in value and type(value.dash) == array {
				value.dash			=   stroke-dash-array(value.dash)
			}

			if "miter-limit" in value {
				value.miter-limit		=   float(value.miter-limit)
			}

			return std.stroke(value)
		}

		// A dictionary containing only valid pattern parameters for keys is assumed to be the dash
		if keys_this.all(x => x in ("array", "phase")) {
			if "array" in value {
				value.array			=   stroke-dash-array(value.array)
			}

			if "phase" in value {
				value.phase			=   length(value.phase)
			}

			return std.stroke(
				dash				:   value,
			)
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
	let	stroke-dashes			= ( // Built-in constants
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

	for	c in value.split("+").map(std.str.trim).filter(x => x != "") {
		if c in stroke-dashes {
			if "dash" in o {
				if quiet {
					return none
				}

				panic("cannot add two stroke arrays: " + repr(value))
			}

			o.insert("dash", c)
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

