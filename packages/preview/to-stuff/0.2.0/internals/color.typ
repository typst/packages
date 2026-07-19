
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
	let	constants			= ( // Built-in constants
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
	)

	if value in constants {
		return constants.at(value)
	}

	if value.contains(regex("^#?([[:xdigit:]]{3,4}|[[:xdigit:]]{6}|[[:xdigit:]]{8})$")) {
		return rgb(value)
	}

	if value.contains(regex(`^(luma|okl(ab|ch)|cmyk|rgb|linear-rgb|hs[lv])\([\s\da-g.,#%"-]+\)$`.text)) {
		return eval("std.color." + value)
	}

	if quiet {
		return none
	}

	panic(panic-message)
}

