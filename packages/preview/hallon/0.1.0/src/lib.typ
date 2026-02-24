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

// === [ Image notes ] =========================================================

// TODO: remove font parameter when custom types are implemented in Typst. Then
// use a `#show image-notes: set text(font: font-sans, weight: "bold")` rule
// from the user instead.
//
// See https://github.com/typst/typst/issues/147

// image-notes places notes above the given image, positioned as specified by
// alignment.
#let image-notes(img, ..args, alignment: top + right, font: "Nimbus Sans") = {
	let notes = args.pos()
	let dx = 0em
	let dy = 0em
	let ystep = 1em
	if alignment.x == left {
		dx = 0.3em
	} else if alignment.x == center {
		dx = 0em
	} else if alignment.x == right {
		dx = -0.3em
	} else {
		panic("horizontal alignment missing from '" + repr(alignment) + "'")
	}
	if alignment.y == top {
		dy = 0.3em
	} else if alignment.y == horizon {
		dy = 0em - 1em*notes.len()/2
	} else if alignment.y == bottom {
		dy = 0.3em - 1em*notes.len()
	} else {
		panic("vertical alignment missing from '" + repr(alignment) + "'")
	}
	set text(font: font, weight: "bold")
	block(
		{
			img
			for note in notes {
				place(
					alignment,
					dx: dx,
					dy: dy,
				)[#note]
				dy = dy + ystep
			}
		}
	)
}

// === [ Subfigures ] ==========================================================

// style-figures handles (optional heading-dependent) numbering of figures and
// subfigures.
#let style-figures(body, heading-levels: 0) = {
	// Numbering patterns for figures and subfigures.
	let fig-numbering = "1."*heading-levels + "1"     // e.g. "1.1"
	let subfig-numbering = "1."*heading-levels + "1a" // e.g. "1.1a"

	// Set default supplement for subfigures.
	show figure.where(kind: "subfigure"): set figure(supplement: "Figure")

	// use bold figure caption.
	show figure.where(kind: image).or(figure.where(kind: table)).or(figure.where(kind: raw)): outer => {
		show figure.caption: it => context {
			// Left align caption if occupying more than one line. Otherwise,
			// center align.
			align(
				center,
				block({
					set align(left)
					strong[#it.supplement~#it.counter.display(it.numbering)#it.separator]
					[ ]
					it.body
				})
			)
		}
		outer
	}

	show heading: outer => {
		if outer.level <= heading-levels {
			// reset figure counter.
			counter(figure.where(kind: image)).update(0)
			counter(figure.where(kind: table)).update(0)
			counter(figure.where(kind: raw)).update(0)
		}
		outer
	}

	set figure(numbering: (..nums) => {
		// TODO: check if we need to provide more context (i.e. using `at` instead
		// of `get`)?
		//
		// ref: https://github.com/typst/typst/issues/3930
		let heading-nums = counter(heading).get()
		if heading-nums.len() > heading-levels {
			// truncate if needed.
			heading-nums = heading-nums.slice(0, heading-levels)
		} else if heading-nums.len() < heading-levels {
			// zero pad if needed.
			for i in range(heading-nums.len(), heading-levels) {
				heading-nums.push(0)
			}
		}
		std.numbering(fig-numbering, ..heading-nums, ..nums)
	})

	show figure.where(kind: image): outer => {
		// reset subfigure counter
		counter(figure.where(kind: "subfigure")).update(0)

		// use nesting level of figure to infer numbering of subfigures.
		set figure(numbering: (..nums) => {
			let heading-nums = counter(heading).at(outer.location())
			if heading-nums.len() > heading-levels {
				// truncate if needed.
				heading-nums = heading-nums.slice(0, heading-levels)
			} else if heading-nums.len() < heading-levels {
				// zero pad if needed.
				for i in range(heading-nums.len(), heading-levels) {
					heading-nums.push(0)
				}
			}
			let outer-nums = counter(figure.where(kind: image)).at(outer.location())
			std.numbering(subfig-numbering, ..heading-nums, ..outer-nums, ..nums)
		})
		show figure.where(kind: "subfigure"): inner => {
			// use bold "(a)" subfigure caption.
			show figure.caption: it => context {
				// Left align caption if occupying more than one line. Otherwise,
				// center align.
				align(
					center,
					block({
						set align(left)
						strong(std.numbering("(a)", it.counter.at(inner.location()).last()))
						[ ]
						it.body
					})
				)
			}
			inner
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
		return fig
	}
	[ #fig #label ]
}
