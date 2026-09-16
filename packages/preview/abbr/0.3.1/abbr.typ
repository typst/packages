#import "abbr-impl.typ": (
	a, pla, asf,
	s, pls,
	l, pll, lsf,
	lo, pllo,
	list,
	load, load-alt,
	config,
	add, add-alt,
	make,
)

/// reference show rule for QoL improved usage
#let show-rule(body) = {
	import "abbr-impl.typ": abbr
	import "abbr.typ" as exported
	let specs = dictionary(exported)
	for r in ("list", "load", "load-alt", "config", "add", "add-alt", "make", "show-rule") {
		let _ = specs.remove(r)
	}
	show ref: it => context {
		let abbreviations = abbr.final()
		let (key, ..spec) = str(it.target).split(":")
		if key in abbreviations {
			if spec.len() != 0 {
				let func = spec.first()
				if func not in specs {
					panic("unknown specifier ':"+func+"' used on abbreviation ["+key+"]")
				}
				specs.at(func)(key)
			} else {
				(specs.a)(key)
			}
		} else {it}
	}
	body
}
