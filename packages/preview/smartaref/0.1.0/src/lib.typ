// Referenceable elements (https://typst.app/docs/reference/model/ref/):
//
// - [x] headings:  https://typst.app/docs/reference/model/heading/
// - [x] figures:   https://typst.app/docs/reference/model/figure/
// - [x] equations: https://typst.app/docs/reference/math/equation/
// - [x] footnotes: https://typst.app/docs/reference/model/footnote/

// is-heading reports whether the given element is a heading.
#let is-heading(elem) = {
	return elem.has("bookmarked")
}

// is-equation reports whether the given element is an equation.
#let is-equation(elem) = {
	return elem.has("number-align") and elem.has("block")
}

// is-footnote reports whether the given element is a footnote.
#let is-footnote(elem) = {
	if elem.fields().len() != 3 {
		return false
	}
	return elem.has("numbering") and elem.has("body") and elem.has("label")
}

// is-ref reports whether the given element is a reference.
#let is-ref(elem) = {
	return elem.has("target")
}

// pluralize returns the plural form of the given word.
//
// TODO: use __pluralize from `swaits/typst-collection` repo
// (file path: `glossy/src/utils.typ`)
// see: https://github.com/swaits/typst-collection/issues/65
#let pluralize(s) = {
	s + "s"
}

// title-case capitalizes the first character of the given string.
#let title-case(s) = {
	let c = s.first()
	upper[#c]
	s.slice(c.len(),)
}

// supplement-func returns an (optionally capitalized) supplement for the given
// list of references.
#let supplement-func(
	// An array of references for which to provide a supplement.
	refs,
	// Whether to capitalize the supplement.
	capital: false,
) = {
	let target = query(refs.first().target).first()
	let supplement = none
	if target.has("supplement") {
		if target.supplement.has("text") {
			supplement = target.supplement.text
		} else if type(target.supplement) == content {
			return target.supplement
		} else {
			//return [ fields: #target.supplement.fields() \ ]
			panic("unable to get supplement (with type '" + str(type(target.supplement)) + "') of target '" + str(type(target)) + "'")
		}
	} else if is-footnote(target) {
		return none // no default supplement for footnotes
	} else {
		//return [ fields: #target.fields() \ ]
		panic("unable to get supplement of target '" + str(type(target)) + "'")
	}
	let s = supplement
	if refs.len() > 1 {
		let singular = s.trim(regex("[.]")) // remove trailing dot if present (e.g. "Fig.")
		let plural = pluralize(singular)
		s = s.replace(singular, plural)
	}
	if capital {
		title-case(s)
	} else {
		lower(s)
	}
}

// is-consecutive reports whether the given numberings follow one another in
// consecutive order (e.g. `(3, 1, 2)` is followed by `(3, 1, 3)`).
#let is-consecutive(a-nums, b-nums) = {
	if a-nums.len() != b-nums.len() {
		return false
	}
	let n = a-nums.len()
	for i in range(0, n - 1) {
		if a-nums.at(i) != b-nums.at(i) {
			return false
		}
	}
	let a-last = a-nums.at(n - 1)
	let b-last = b-nums.at(n - 1)
	return a-last + 1 == b-last
}

// consecutive returns the number of pairs of consecutive numberings present at
// the start of the given list of numberings.
#let consecutive(some-nums) = {
	let n = 0
	for i in range(1, some-nums.len()) {
		let prev = some-nums.at(i - 1)
		let cur = some-nums.at(i)
		if not is-consecutive(prev, cur) {
			return n
		}
		n = n + 1
	}
	return n
}

// compact-func returns a compacted list based of the given list of references,
// the list of corresponding numberings and an optional separator. Consecutive
// references are compacted (e.g. "figs. 1, 2, 3 and 4" becomes "figs. 1 to 4".
#let compact-func(
	// A list of short references (e.g. "1" instead of "Figure 1").
	short-refs,
	// An array of numberings, with indices corresponding to the short-refs list.
	all-nums,
	separator: " to ",
) = {
	let compacted-refs = ()
	let length = all-nums.len()
	let start = 0
	while start < length {
		let n = consecutive(all-nums.slice(start))
		if n > 1 {
			let first-ref = short-refs.at(start)
			let last-ref = short-refs.at(start + n)
			compacted-refs.push[#first-ref#separator#last-ref]
			start = start + n + 1
		} else {
			let short-ref = short-refs.at(start)
			compacted-refs.push(short-ref)
			start = start + 1
		}
	}
	return compacted-refs
}

// join-func joins the given list of references.
#let join-func(
	// An array of references to join. A single element may be compact and
	// correspond to a sequence of consecutive references (e.g. "1 to 3").
	args,
	// A string to insert between each reference.
	separator: ", ",
	// An alternative separator between the last two references.
	last: " and ",
) = {
	args.join(separator, last: last)
}

#let cref(
	// A variadic list of content containing references (e.g. `[@foo @bar]`).
	..args,
	// Whether to compact consecutive references (e.g. "figs. 1, 2, 3 and 4"
	// becomes "figs. 1 to 4").
	compact: false,
	// A function used to compact consecutive references.
	compact-func: compact-func,
	// A supplement used for the list of references.
	//
	// Takes one of the following values:
	//
	// - A `string` (e.g. "figures" or "tables").
	// - A `content` value.
	// - A `function` taking a list of references and a boolean to optionally
	//   capitalize the returned supplement.
	supplement: supplement-func,
	// A function used to join references.
	join-func: join-func,
) = context {
	let refs = ()
	for arg in args.pos() {
		let children = ()
		if arg.has("children") {
			children = arg.children
		} else {
			children.push(arg)
		}
		for child in children {
			if is-ref(child) {
				refs.push(child)
			}
		}
	}
	if supplement != none {
		if type(supplement) == str or type(supplement) == content {
			supplement
		} else if type(supplement) == function {
			supplement(refs)
		} else {
			panic("support for supplement '" + str(type(supplement)) + "' not yet supported")
		}
		[ ]
	}
	let targets = ()
	for ref in refs {
		let target = query(ref.target).first()
		targets.push(target)
	}
	let short-refs = () // short references (e.g. "1" instead of "Figure 1")
	let all-nums = ()   // array of counter numberings.
	for target in targets {
		let elem = target
		let c = none
		if elem.has("counter") {
			c = elem.counter
		} else if is-heading(elem) {
			c = counter(heading)
		} else if is-equation(elem) {
			c = counter(math.equation)
		} else if is-footnote(elem) {
			c = counter(footnote)
		} else {
			//return [ fields: #elem.fields() \ ]
			panic("unable to get counter of element '" + str(type(elem)) + "'")
		}
		let nums = c.at(elem.location())
		let text = std.numbering(elem.numbering, ..nums)
		let short-ref = link(
			target.label,
			text,
		)
		short-refs.push(short-ref)
		all-nums.push(nums)
	}
	if compact {
		// compact consecutive references (e.g. "figs. 1, 2, 3 and 4" becomes
		// "figs. 1 to 4").
		let compacted-refs = compact-func(short-refs, all-nums)
		join-func(compacted-refs)
	} else {
		join-func(short-refs)
	}
}

#let Cref = cref.with(
	supplement: supplement-func.with(capital: true),
)
