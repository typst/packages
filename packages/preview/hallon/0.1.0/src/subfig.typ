// === [ subfigure ] ===========================================================

// style-figures handles (optional heading-dependent) numbering of figures and
// subfigures.
#let style-figures(body, heading-levels: 0) = {
	// Numbering patterns for figures and subfigures.
	let fig-numbering = "1."*heading-levels + "1"     // e.g. "1.1"
	let subfig-numbering = "1."*heading-levels + "1a" // e.g. "1.1a"

	// Set depth of multi-level numbering patterns.
	show figure: set figure(level: heading-levels+1)
	show figure: set figure(numbering: fig-numbering) // e.g. "1.1"
	show figure.where(kind: "subfigure"): set figure(level: heading-levels+2)
	show figure.where(kind: "subfigure"): set figure(numbering: subfig-numbering) // e.g. "1.1a"

	// Set default supplement for subfigures.
	show figure.where(kind: "subfigure"): set figure(supplement: "Figure")

	// Step counter at parent heading and figure levels.
	show heading: it => {
		if it.level <= heading-levels {
			counter(figure.where(kind: image)).step(level: it.level)
			counter(figure.where(kind: table)).step(level: it.level)
			counter(figure.where(kind: raw)).step(level: it.level)
			counter(figure.where(kind: "subfigure")).step(level: it.level)
		}
		it
	}
	show figure.where(kind: image): outer => {
		counter(figure.where(kind: "subfigure")).step(level: heading-levels+1)
		outer
	}

	// Use "(a)" subfigure caption numbering.
	show figure.where(kind: "subfigure"): outer => {
		show figure.caption: it => {
			strong(std.numbering("(a)", it.counter.at(outer.location()).last()))
			[ ]
			it.body
		}
		outer
	}

	// Use bold figure caption.
	show figure: outer => {
		show figure.caption: it => {
			strong[#it.supplement~#std.numbering(it.numbering, ..it.counter.at(outer.location()))]
			it.separator
			it.body
		}
		outer
	}

	body
}

// subfigure creates a new subfigure with the given arguments and an optional
// label.
#let subfigure(body, outlined: false, ..args, label: none) = {
	let fig = figure(body, kind: "subfigure", outlined: outlined, ..args)
	if label == none {
		fig
	} else {
		[ #fig #label ]
	}
}
