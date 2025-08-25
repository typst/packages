// === [ Named references ] ====================================================

// nameref displays a reference using section name (instead of numbering).
#let nameref(label) = {
	show ref: it => {
		if it.element == none {
			it
		} else if it.element.func() != heading {
			it
		} else {
			let l = it.target  // label
			let h = it.element // heading
			link(l, h.body)
		}
	}
	ref(label)
}

// === [ Subfigures ] ==========================================================

// export identifiers.
#import "subfig.typ": style-figures, subfigure

// === [ Utility functions ] ===================================================

// export identifiers.
#import "util.typ": title-case
