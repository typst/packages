// Style outline as LaTeX "Table of contents".
#let style-outline(body) = {
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

	body
}

// Style headings with "1.1" numbering and increased spacing.
#let style-heading(it) = {
	// Increase distance between heading and surrounding paragraphs.
	set block(above: 2em, below: 1.6em)

	// Increase distance between numbering and heading.
	if it.numbering == none {
		block(it.body)
	} else {
		block[
			#std.numbering(it.numbering, ..counter(heading).at(it.location()))
			#h(0.8em)
			#it.body
		]
	}
}

// Style list with larger left margin.
#let style-list(body) = {
	block(
		inset: (left: 1.1em),
		body
	)
}

// Style quote with larger horizontal margin.
#let style-quote = block.with(width: 100%, inset: (x: 1.5em))

// Style outline, headings, lists and quotes using the style of LaTeX.
#let style(justify: true, numbering: "1.1", body) = {
	// Use arabic numbering of headings.
	set heading(numbering: numbering)

	// Style outline as LaTeX "Table of contents".
	show outline: style-outline

	// Style headings with "1.1" numbering and increased spacing.
	show heading: style-heading

	// Style bullet list with larger left margin.
	show list: style-list

	// Style numbered list with larger left margin.
	show enum: style-list

	// Style quote with larger horizontal margin.
	show quote: style-quote

	set par(justify: justify)

	body
}

// make-title displays the title, authors and date as specified by the
// corresponding document metadata variables.
#let make-title() = context {
	let authors = document.author
	let date = none
	if document.date == auto {
		date = datetime.today()
	} else if document.date != none {
		date = document.date
	}
	show title: set text(weight: "regular")
	v(1.67cm)
	align(center)[
		#block(
			below: 3em,
			title()
		)
		#if authors.len() > 0 {
			block(
				below: 2.25em,
				text(size: 1.3em)[#authors.join(",", last: " and ")]
			)
		}
		#if date != none {
			block(
				below: 2.15em,
				text(size: 1.3em)[#date.display()]
			)
		}
	]
}

// abstract displays an abstract block.
#let abstract(body, title: "Abstract") = {
	set par(
		justify: true,
		first-line-indent: (amount: 1.5em, all: true),
		leading: 0.55em, // adjust line height
		spacing: 0.55em, // no space between paragraphs
	)
	set text(size: 0.955em)
	block(
		inset: (x: 1.03cm),
	)[
		#align(center,
			block(
				below: 1.45em,
				strong[#title]
			)
		)

		#body
	]
}
