// Style outline as LaTeX "Table of contents".
#let style-outline(it) = {
	// Use "Table of contents" title instead of "Contents".
	//set outline(title: [Table of contents]) if text.lang == "en"
	show outline: it => {
		show heading: it => {
			show "Contents": "Table of contents"
			it
		}
		it
	}

	// Use spacing to group header level 1 entries.
	show outline.entry.where(level: 1): set block(above: 1.5em)

	// Use bold text for header level 1 entries.
	show outline.entry.where(level: 1): set text(weight: "bold")

	// Skip dots between section title and page number for header level 1.
	show outline.entry.where(level: 1): set outline.entry(fill: none)

	// Increase gap between dots for other header levels.
	set outline.entry(fill: pad(left: 0.2em, right: 1em, repeat(gap: 0.50em, [.])))

	// Increase spacing between section number and section title.
	show outline.entry: it => link(
		it.element.location(),
		if it.prefix() == none {
			it.indented(none, it.inner())
		} else {
			it.indented(it.prefix() + h(0.4em), it.inner())
		},
	)

	it
}
