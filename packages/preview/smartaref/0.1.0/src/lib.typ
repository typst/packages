// Referenceable elements (https://typst.app/docs/reference/model/ref/):
//
// - [x] headings:  https://typst.app/docs/reference/model/heading/
// - [x] figures:   https://typst.app/docs/reference/model/figure/
// - [x] equations: https://typst.app/docs/reference/math/equation/
// - [x] footnotes: https://typst.app/docs/reference/model/footnote/

#import "@local/hallon:0.1.0": title-case

#let is-heading(elem) = {
	return elem.has("bookmarked")
}

#let is-equation(elem) = {
	return elem.has("number-align") and elem.has("block")
}

#let is-footnote(elem) = {
	if elem.fields().len() != 3 {
		return false
	}
	return elem.has("numbering") and elem.has("body") and elem.has("label")
}

#let is-ref(elem) = {
	return elem.has("target")
}

// TODO: use __pluralize from `swaits/typst-collection` repo
// (file path: `glossy/src/utils.typ`)
#let pluralize(s) = {
	s + "s"
}

#let supplement-func(refs, capital: false) = {
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

#let cref(..args, supplement: supplement-func) = context {
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
		}
		[ ]
	}
	let targets = ()
	for ref in refs {
		let target = query(ref.target).first()
		targets.push(target)
	}
	let new_refs = ()
	let all_nums = ()
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
		let new_ref = link(
			target.label,
			text,
		)
		new_refs.push(new_ref)
		all_nums.push(nums)
	}
	// TODO: implement compacting of crefs.
	//[ all nums: #all_nums \ ]
	new_refs.join(", ", last: " and ")
}

#let Cref = cref.with(supplement: supplement-func.with(capital: true))
