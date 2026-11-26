/** preamble.typ
 *
 * A file for defining your own commands and functions. To use
 * the commands defined here in another file, this file needs to
 * be imported there:
 *
 *   #import "path/to/preamble.typ": *
 *
 * imports all symbols without qualifying them, and
 *
 *   #import "path/to/preamble.typ"
 *
 * requires that you qualify each command with the name of this
 * module: preamble.command. A few command definitions are
 * defined as an example.
 *
***/


/**
 *
 * This text extraction helper function is used to implement slightly fancier
 * vector, matrix and unit commands.
 *
***/

#let text-extraction-fn(x) = {
	let input-type = type(x)
	let input-str = if input-type == content {
		if x.has("text") {
			x.text
		} else if x.has("body") {
			text-extraction-fn(x.body)
		} else {
			x
		}
	} else if input-type in (symbol, str) {
		x
	} else {
		panic("text-extraction-fn: input was not content or text.")
	}
	input-str
}

// Vectors and matrices.

#let vector(x) = {
	let input-str = text-extraction-fn(x)
	$bold(upright(#lower(input-str)))$
}

#let matrix(x) = {
	let input-str = text-extraction-fn(x)
	$bold(upright(#upper(input-str)))$
}

// Random variables and vectors.

#let random-style-fn = math.frak

#let random-var(x) = {
	let input-str = text-extraction-fn(x)
	$#random-style-fn(input-str)$
}

#let random-vec(x) = $#random-style-fn(vector(x))$

#let random-mat(x) = $#random-style-fn(matrix(x))$

// Other notation commands.

#let unitvec(v) = $hat(vector(#v))$

#let nvec = $vector(n)$

#let unvec = $unitvec(n)$

#let force = math.equation(
	alt: "force",
	$vector(f)$
)

#let mass = math.equation(
	alt: "mass",
	$m$
)

#let position = math.equation(
	alt: "position",
	$vector(x)$
)

#let velocity = math.equation(
	alt: "velocity",
	$vector(v)$
)

#let acceleration = math.equation(
	alt: "acceleration",
	$vector(a)$
)

// A command for a complicated word.

#let eeg = [electroencephalography]

#let EEG = [EEG]

// Euler number and imaginary unit expressed as their unicode symbols.

#let unicode-euler-num = "\u{2107}"

#let unicode-imag-unit = "\u{2148}"

// Euler number and imaginary unit expressed according to the ISO standard.

#let iso-euler-num = math.upright("e")

#let iso-imag-unit = math.upright("i")

// Derivatives.

#let derivative(num,den) = $(dif #h(0.1em) num)/(dif #h(0.1em) den)$

#let partialderivative(num,den) = $(partial #h(0.1em) num)/(partial #h(0.1em) den)$

// A restriction of a function ff to a subdomain dd, using horizontally flowing text.

#let restriction(ff,dd) = $lr((#ff thin mid(|) thin #dd))$

#let conjugate-op = math.equation(
	alt: "*",
	$*$
)

#let complex-conjugate(xx) = $xx #conjugate-op$


#let repeat-white-space-pattern = regex("\s+")

/**
 *
 * Performs transformations on a given alt text string
 * to make it more readable in the output PDF file, while
 * still allowing you to write it on multiple lines.
 *
***/
#let alt-text-fn(string) = string.trim().replace(repeat-white-space-pattern, sym.space)


//// Printing numbers with a thousands-separator.

/** str-in-groups-of(ss,gg)
 *
 * Displays a given string ss in groups of gg.
 *
***/

#let str-in-groups-of(ss, gg, reverse : true, separator: sym.space.nobreak.narrow) = {
	if not type(ss) == str {
		panic("str-in-groups-of: I only accept string arguments. Received a " + str(type(ss)))
	}
	if not type(gg) == int and gg >= 0 {
		panic("str-in-groups-of: the second argument needs to be a non-negative integer.")
	}
	let graphs = ss.clusters()
	let strlen = graphs.len()
	let maxcontinues = calc.max(
		calc.quo(strlen, gg),
		0
	)
	let iters = strlen + maxcontinues
	let continuecount = 0
	let ii = 0
	let condition = if reverse { (it,lim) => it < lim } else { (it,lim) => it <= lim }
	while condition(ii,iters) {
		let dist = if reverse { iters - ii } else { ii }
		let rr = calc.rem(dist, gg+1)
		let dd = graphs.at(ii - continuecount, default: "0")
		if rr == 0 and ii != 0 { separator }
		if rr == 0 {
			continuecount += 1
		} else {
			dd
		}
		ii += 1
	}
}

/** int-with-thousands-sep
 *
 * Displays an integer with some kerning as a
 * thousands-separator.
 *
***/

#let int-with-thousands-sep(nat) = {

	if not type(nat) == int {
		panic("This function only accepts integer arguments")
	}

	if nat < 0 { $-$ }
	let string = repr(calc.abs(nat))
	str-in-groups-of(string, 3)
}

/** float-with-thousands-sep
 *
 * Displays a floating point number with some kerning as a
 * thousands-separator.
 *
 * The implementation is stupid, because Typst cannot convert
 * floats to bytes, and even if it did, the documentation does
 * not tell whether Typst floats conform to the IEEE floating
 * point standard or not.
 *
***/

#let float-with-thousands-sep(ff) = {

	if not type(ff) == float {
		panic("This function only accepts floating point arguments")
	}

	let sf = str(ff)
	let whole-and-fract = sf.split(".")
	let first = whole-and-fract.first()
	let last = whole-and-fract.last()
	let (whole, decim) = if whole-and-fract.len() == 2 {
		(first, last)
	} else {
		(first, none)
	}
	let wholesep = str-in-groups-of(whole, 3)
	if decim == none {
		wholesep
	} else {
		let decimsep = str-in-groups-of(decim, 3, reverse : false)
		wholesep + "." + decimsep
	}

}

/** num(nn)
 *
 * Typesets a given integer or float with some kerning as a
 * thousands separator.
 *
***/

#let num(nn) = {
	let num-str = if type(nn) == int {
		int-with-thousands-sep(nn)
	} else if type(nn) == float {
		float-with-thousands-sep(nn)
	} else {
		panic("num: I can only separate ints and floats. Received " + str(type(nn)))
	}
	math.equation(
		alt: num-str,
		num-str
	)
}

//// Unit definitions.

#let unit(symbol) = {
	math.upright(symbol)
}

//// SI units.

#let meter = unit([m])
#let gram = unit([g])
#let second = unit([s])
#let newton = unit([N])
#let joule = unit([J])
#let time = unit([t])
#let bar = unit([bar])
#let mm-hg = unit([mmHg])
#let pt = unit([pt])
#let pascal = unit([Pa])
#let celsius = math.equation(
	alt: "°C",
	unit("°C")
)


//// Unit prefixes.

#let femto = unit([f])
#let nano = unit([n])
#let micro = unit([μ])
#let milli = unit([m])
#let centi = unit([c])
#let deci = unit([d])
#let kilo = unit([k])
#let mega = unit([M])
#let giga = unit([G])
#let tera = unit([T])
#let peta = unit([P])
