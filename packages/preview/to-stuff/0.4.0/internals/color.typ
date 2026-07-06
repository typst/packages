
#import "/internals/scalars.typ"	:   int, scalar
#import "/internals/units.typ"		:   angle, ratio
#import	"/internals/utils.typ"		:   list-predefined


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
	let	constants			=   list-predefined(std.color)
	let	constructors			= (
		rgb				: (
			constructor			:  std.color.rgb,
			args				: (
				red				: (optional: false,	types: (ratio, int)),
				green				: (optional: false,	types: (ratio, int)),
				blue				: (optional: false,	types: (ratio, int)),
				alpha				: (optional: true,	types: (ratio, int)),
			),
		),
		linear-rgb			: (
			constructor			:  std.color.linear-rgb,
			args				: (
				red				: (optional: false,	types: (ratio, int)),
				green				: (optional: false,	types: (ratio, int)),
				blue				: (optional: false,	types: (ratio, int)),
				alpha				: (optional: true,	types: (ratio, int)),
			),
		),
		luma				: (
			constructor			:  std.color.luma,
			args				: (
				lightness			: (optional: false,	types: (ratio, int)),
				alpha				: (optional: true,	types: (ratio,)),
			),
		),
		cmyk				: (
			constructor			:  std.color.cmyk,
			args				: (
				cyan				: (optional: false,	types: (ratio,)),
				magenta				: (optional: false,	types: (ratio,)),
				yellow				: (optional: false,	types: (ratio,)),
				black				: (optional: false,	types: (ratio,)),
			),
		),
		hsl				: (
			constructor			:  std.color.hsl,
			args				: (
				hue				: (optional: false,	types: (angle,)),
				saturation			: (optional: false,	types: (ratio, int)),
				lightness			: (optional: false,	types: (ratio, int)),
				alpha				: (optional: true,	types: (ratio, int)),
			),
		),
		hsv				: (
			constructor			:  std.color.hsv,
			args				: (
				hue				: (optional: false,	types: (angle,)),
				saturation			: (optional: false,	types: (ratio, int)),
				value				: (optional: false,	types: (ratio, int)),
				alpha				: (optional: true,	types: (ratio, int)),
			),
		),
		oklab				: (
			constructor			:  std.color.oklab,
			args				: (
				lightness			: (optional: false,	types: (ratio,)),
				A				: (optional: false,	types: (ratio, scalar),	clamp: false),
				B				: (optional: false,	types: (ratio, scalar),	clamp: false),
				alpha				: (optional: true,	types: (ratio,)),
			),
		),
		oklch				: (
			constructor			:  std.color.oklch,
			args				: (
				lightness			: (optional: false,	types: (ratio,)),
				chroma				: (optional: false,	types: (ratio, scalar), clamp: false),
				hue				: (optional: false,	types: (angle,)),
				alpha				: (optional: true,	types: (ratio,)),
			),
		),
	)

	let	clamps				= (
		int 				: (
			fails				:   x => 0 > x or x > 255,
			error				:  "component must be between 0 and 255",
		),
		ratio				: (
			fails				:   x => 0% > x or x > 100%,
			error				:  "component must be between 0% and 100%",
		),
	)


	if value in constants {
		return constants.at(value)
	}

	if value.contains(regex("^#?([[:xdigit:]]{3,4}|[[:xdigit:]]{6}|[[:xdigit:]]{8})$")) {
		return std.color.rgb(value)
	}


	let	rx-funcs			=   regex( "^(" + constructors.keys().join("|") + ")\((.*)\)$")

	if value.contains(rx-funcs) {
		let	(func, args)			=   value.match(rx-funcs).captures

		if func not in constructors {
			if quiet {
				return none
			}

			panic(panic-message)
		}

		let	allowed				=   constructors.at(func).args.pairs()
		let	required			=   allowed.filter(x => not x.last().optional)
		let	args				=   args
			.split(",")
			.map(str.trim)
			.filter(x => "" != x)
			.enumerate()
			.map(((offset, arg)) => {
				if offset >= allowed.len() {
					return ("panic", "unexpected argument " + repr(arg))
				}

				let	(name, rules)			=   allowed.at(offset)

				for	parse in rules.types {
					let	clamp				=   clamps.at(
						default				: (:),
						repr(parse),
					)
					let	parsed				=   parse(
						quiet				:   true,
						arg,
					)

					if none == parsed {
						continue;
					}


					if repr(parse) in clamps and rules.at(
						default				:   true,
						"clamp",
					) and clamp.at("fails")(parsed) {
						return ("panic", (name, clamp.error).join(" "))
					}

					return (name, parsed)
				}

				return ("panic", (
					name,
					"component expected",
					rules.types.map(repr).join(
						last				:  ", or ",
						", ",
					).replace("scalar", "float"),
				).join(" "))
			})
			.to-dict()

		if "panic" in args {
			if quiet {
				return none
			}

			panic(panic-message + "; " + args.panic)
		}

		if args.len() < required.len() {
			if quiet {
				return none
			}

			panic(panic-message + "; missing " + required.at(args.len()).first() + " component")
		}

		return	constructors.at(func).at("constructor")(..args.values())
	}


	if quiet {
		return none
	}

	panic(panic-message)
}

