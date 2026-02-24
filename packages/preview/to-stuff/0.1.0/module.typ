
// Regular expressions
#let	rx-numeric			=  "[-+\s]*(\d+|\d*\.\d+)"

#let	rx				= (
	ratios				:   regex("^"  + rx-numeric +  "%$"),
	fractions			:   regex("^"  + rx-numeric +  "fr$"),
	lengths				:   regex("^"  + rx-numeric + "(pt|mm|cm|in|em)$"),
	angles				:   regex("^"  + rx-numeric + "(deg|rad)$"),
	relatives			:   regex("^(" + rx-numeric + "(pt|mm|cm|in|em|%))+$"),
	color-funcs			:   regex(`^(luma|okl(ab|ch)|cmyk|rgb|linear-rgb|hs[lv])\([\s\da-g.,#%"-]+\)$`.text),
	color-hexes			:   regex("^#?([[:xdigit:]]{3,4}|[[:xdigit:]]{6}|[[:xdigit:]]{8})$"),
)

// Built-in constants
#let	bx				= (
	colors				: (
		aqua				:   std.color.aqua,
		black				:   std.color.black,
		blue				:   std.color.blue,
		eastern				:   std.color.eastern,
		fuchsia				:   std.color.fuchsia,
		gray				:   std.color.gray,
		green				:   std.color.green,
		lime				:   std.color.lime,
		maroon				:   std.color.maroon,
		navy				:   std.color.navy,
		olive				:   std.color.olive,
		orange				:   std.color.orange,
		purple				:   std.color.purple,
		red				:   std.color.red,
		silver				:   std.color.silver,
		teal				:   std.color.teal,
		white				:   std.color.white,
		yellow				:   std.color.yellow,
	),
	directions			: (
		ltr				:   std.direction.ltr,
		rtl				:   std.direction.rtl,
		ttb				:   std.direction.ttb,
		btt				:   std.direction.btt,
	),
	alignments			: (
		start				:   std.alignment.start,
		end				:   std.alignment.end,
		left				:   std.alignment.left,
		center				:   std.alignment.center,
		right				:   std.alignment.right,
		top				:   std.alignment.top,
		horizon				:   std.alignment.horizon,
		bottom				:   std.alignment.bottom,
	),
)

// String constants
#let	sx				= (
	stroke-dashes			: (
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
)


#let	length(
	quiet				:   false,
	value,
) = {
	if type(value) == std.length {
		return value
	}

	if type(value) == std.str and value.trim().contains(rx.lengths) {
		return eval(value)
	}

	if quiet {
		return none
	}

	panic("could not convert to length: " + repr(value))
}

#let	fraction(
	quiet				:   false,
	value,
) = {
	if type(value) == std.fraction {
		return value
	}

	if type(value) == std.str and value.trim().contains(rx.fractions) {
		return eval(value)
	}

	if quiet {
		return none
	}

	panic("could not convert to fraction: " + repr(value))
}

#let	ratio(
	quiet				:   false,
	value,
) = {
	if type(value) == std.ratio {
		return value
	}

	if type(value) == std.str and value.trim().contains(rx.ratios) {
		return eval(value)
	}

	if quiet {
		return none
	}

	panic("could not convert to ratio: " + repr(value))
}

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

	if type(value) == std.str and value.trim().contains(rx.relatives) {
		return eval(value)
	}

	if quiet {
		return none
	}

	panic("could not convert to relative: " + repr(value))
}

#let	angle(
	quiet				:   false,
	value,
) = {
	if type(value) == std.angle {
		return value
	}

	if type(value) == std.str and value.trim().contains(rx.angles) {
		return eval(value)
	}

	if quiet {
		return none
	}

	panic("could not convert to angle: " + repr(value))
}

#let	color(
	quiet				:   false,
	value,
) = {
	if type(value) == std.color {
		return value
	}


	let	panic-message			=  "could not convert to color: " + repr(value)

	if type(value) != std.str {
		if quiet {
			return none
		}

		panic(panic-message)
	}


	let	value				=   value.trim()

	if value in bx.colors {
		return bx.colors.at(value)
	}

	if value.contains(rx.color-hexes) {
		return rgb(value)
	}

	if value.contains(rx.color-funcs) {
		return eval("std.color." + value)
	}

	if quiet {
		return none
	}

	panic(panic-message)
}

#let	direction(
	quiet				:   false,
	value,
) = {
	if type(value) == std.direction {
		return value
	}

	if type(value) == std.str and value.trim() in bx.directions {
		return bx.directions.at(value.trim())
	}

	if quiet {
		return none
	}

	panic("could not convert to direction: " + repr(value))
}

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
		let	keys_valid			= ("x", "y")

		if keys_this.all(x => x in keys_valid) {
			if "x" in value {
				value.x				=   alignment(quiet : true, value.x)

				if none == value.x or value.x.axis() != "horizontal" {
					if quiet {
						return none
					}

					panic("could not convert “x” component to horizontal alignment: " + original)
				}
			}

			if "y" in value {
				value.y				=   alignment(quiet : true, value.y)

				if none == value.y or value.y.axis() != "vertical" {
					if quiet {
						return none
					}

					panic("could not convert “y” component to vertical alignment: " + original)
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


	let	panic-message			=  "could not convert to alignment: " + repr(value)

	if type(value) != std.str {
		if quiet {
			return none
		}

		panic(panic-message)
	}


	let	value				=   value.trim()

	if value in bx.alignments {
		return bx.alignments.at(value)
	}


	let	parts				=   value.split("+").map(std.str.trim)

	if not parts.all(x => x in bx.alignments) {
		if quiet {
			return none
		}

		panic(panic-message)
	}

	let	axes				=   parts.map(x => bx.alignments.at(x).axis())

	if axes.at(0) == axes.at(1) {
		if quiet {
			return none
		}

		panic("cannot add two " + axes.at(0) + " alignments: " + repr(value))
	}

	return eval(value)
}


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

	for	c in value.split("+").map(std.str.trim).filter(x => x != "") {
		if c in sx.stroke-dashes {
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

