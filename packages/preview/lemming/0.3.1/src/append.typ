#let sequence-func = [. ].func()
#let space-func = [. ].children.last().func()
#let styled-func = [#set text(fill: red)].func()

#let get-last-nonempty(content_) = {
	for (i, part) in content_.children.enumerate().rev() {
		let func = part.func()
		if func in (space-func, parbreak, linebreak, colbreak, pagebreak) {
			continue
		}
		return (func, i)
	}
	return (it => it, content_.children.len() - 1)
}

/// Similar to
/// ```typ
/// #h(1fr)
/// #marker
/// ```
/// but keeps the spacing even after soft line-breaks
///
/// - marker (content): The content to place at the end
/// ->
#let space-marker(marker, minimal-spacing) = {
	if minimal-spacing != none {
			h(minimal-spacing)
		}
	box(
		// Don't apply user set-rules
		baseline: 0% + 0pt, fill:  none, height: auto, inset: (:), outset: (:), stroke: (:),
		width: 1fr, align(right, marker)
	)
}


#let clone-without(dict, keys) = for (k, value) in dict {
	if not keys.contains(k) {
		({ k }: value)
	}
}

#let append(body, qed, minimal-spacing: 2em) = if type(body) == content {
	if qed == none {
		return body
	}

	let func = body.func()
	if func == sequence-func and body.children.len() > 0 {
		let (child-func, index) = get-last-nonempty(body)
		for part in body.children.slice(0, index) {
			part
		}
		append(body.children.at(index), qed)
		for part in body.children.slice(index + 1) {
			part
		}
	} else if func == math.equation and body.block {
		body
		place(bottom + right, qed)
		context if math.equation.numbering != none {
			let number-align = math.equation.number-align
			let equation-height = measure(body).height
			let numbering-height = measure(numbering(math.equation.numbering, 1)).height
			let qed-height = measure(qed).height

			if number-align.x == end or number-align.x == none {
				if number-align.y == top {
					let remaining-height = equation-height - numbering-height - qed-height
					if remaining-height < par.leading.to-absolute() {
						h(par.leading - remaining-height)
					}
				} else if number-align.y == horizon {
					let remaining-height = (equation-height - numbering-height) / 2 - qed-height
					if remaining-height < par.leading.to-absolute() {
						h(par.leading - remaining-height)
					}
				} else if number-align.y == bottom {
					h(par.leading)
				}
			}
		}
	} else if func in (list.item, enum.item, block) {
		func(append(body.body, qed), ..clone-without(body.fields(), ("body",)))
	} else if func == terms.item {
		func(body.term, append(body.description, qed))
	} else if func == columns {
		func(append(body.body, qed), body.count)
	} else if func == styled-func {
		func(append(body.child, qed), body.styles)
	} else {
		// if func != text {panic("Unknown: " + repr(func))}
		body
		space-marker(qed, minimal-spacing)
	}
} else {
	panic("Can't append qed to non-content.")
}
