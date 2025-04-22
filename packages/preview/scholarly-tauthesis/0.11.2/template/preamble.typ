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

#let textExtractionFn(x) = {
	let inputType = type(x)
	let inputStr = if inputType == content {
		if x.has("text") {
			x.text
		} else if x.has("body") {
			textExtractionFn(x.body)
		} else {
			x
		}
	} else if inputType in (symbol, str) {
		x
	} else {
		panic("textExtractionFn: input was not content or text.")
	}
	inputStr
}

// Vectors and matrices.

#let vector(x) = {
	let inputStr = textExtractionFn(x)
	$bold(upright(#lower(inputStr)))$
}

#let matrix(x) = {
	let inputStr = textExtractionFn(x)
	$bold(upright(#upper(inputStr)))$
}

// Random variables and vectors.

#let randomStyleFn = math.frak

#let randomVar(x) = {
	let inputStr = textExtractionFn(x)
	$randomStyleFn(#inputStr)$
}

#let randomVec(x) = $randomStyleFn(vector(#x))$

#let randomMat(x) = $randomStyleFn(matrix(#x))$

// Other notation commands.

#let unitvec(v) = $hat(vector(#v))$

#let nvec = $vector(n)$

#let unvec = $unitvec(n)$

#let position = $vector(r)$

#let Avec = $vector(A)$

#let force = $vector(f)$

#let mass = $m$

#let position = $vector(x)$

#let velocity = $vector(v)$

#let acceleration = $vector(a)$

#let matrix(input) = $upright(bold(input))$

// A command for a complicated word.

#let eeg = [electroencephalography]

#let EEG = [EEG]

// Derivatives.

#let derivative(num,den) = $(dif #h(0.1em) num)/(dif #h(0.1em) den)$

#let partialderivative(num,den) = $(partial #h(0.1em) num)/(partial #h(0.1em) den)$

//// Printing numbers with a thousands-separator.

/** strInGroupsOf(ss,gg)
 *
 * Displays a given string ss in groups of gg.
 *
***/

#let strInGroupsOf(ss, gg, reverse : true) = {
	if not type(ss) == str {
		panic("strWithThousandsSep: I only accept string arguments. Received a " + str(type(ss)))
	}
	if not type(gg) == int and gg >= 0 {
		panic("strWithThousandsSep: the second argument needs to be a non-negative integer.")
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
		if rr == 0 and ii != 0 { h(0.2em) }
		if rr == 0 {
			continuecount += 1
		} else {
			$dd$
		}
		ii += 1
	}
}

/** intWithThousandsSep
 *
 * Displays an integer with some kerning as a
 * thousands-separator.
 *
***/

#let intWithThousandsSep(nat) = {

	if not type(nat) == int {
		panic("This function only accepts integer arguments")
	}

	if nat < 0 { $-$ }
	let string = repr(calc.abs(nat))
	strInGroupsOf(string, 3)
}

/** floatWithThousandsSep
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

#let floatWithThousandsSep(ff) = {

	if not type(ff) == float {
		panic("This function only accepts floating point arguments")
	}

	let sf = str(ff)
	let whole_and_fract = sf.split(".")
	let first = whole_and_fract.first()
	let last = whole_and_fract.last()
	let (whole, decim) = if whole_and_fract.len() == 2 {
		(first, last)
	} else {
		(first, none)
	}
	let wholesep = strInGroupsOf(whole, 3)
	if decim == none {
		$#wholesep$
	} else {
		let decimsep = strInGroupsOf(decim, 3, reverse : false)
		$#wholesep.#decimsep$
	}

}

/** num(nn)
 *
 * Typesets a given integer or float with some kerning as a
 * thousands separator.
 *
***/

#let num(nn) = {
	if type(nn) == int {
		intWithThousandsSep(nn)
	} else if type(nn) == float {
		floatWithThousandsSep(nn)
	} else {
		panic("num: I can only separate ints and floats. Received " + str(type(nn)))
	}
}

//// Unit definitions.

#let unit(symbol) = $upright(symbol)$

#let intregex = regex("^(?:-)?\d+$")
#let floatregex = regex("^(:?-)?\d+\.\d+$")

#let unitful(nn,uu) = {
	let nr = if type(nn) == content {
		let text = textExtractionFn(nn)
		let intmatches = text.matches(intregex)
		let flomatches = text.matches(floatregex)
		if not intmatches == () {
			int(text)
		} else if not flomatches == () {
			float(text)
		} else {
			panic("unitful: Could not convert content text into a number")
		}
	} else {
		nn
	}
	$num(nr)#h(0.1em)unit(uu)$
}

//// SI units.

#let meter = unit([m])
#let gram = unit([g])
#let second = unit([s])
#let newton = unit([N])
#let joule = unit([J])
#let time = unit([t])
#let bar = unit([bar])
#let mmHg = unit([mmHg])
#let pascal = unit([Pa])
#let celsius = unit([C])

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
