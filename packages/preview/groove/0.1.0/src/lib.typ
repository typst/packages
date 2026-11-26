#import "@preview/latex-lookalike:0.1.4"
#import "@preview/hallon:0.1.4"

// Fonts.
#let font-serif      = "EB Garamond"
#let font-sans-serif = "Source Sans Pro"

// Colours.
#let cob-cyan       = rgb(64, 193, 234) // CoB cyan
#let cellpress-blue = rgb("#0296d3")    // CellPress blue

#let highlight-color = cob-cyan
#let link-color      = cellpress-blue

// highlight-text highlights the given text with colour.
#let highlight-text(body, size: 12pt, color: highlight-color, modifier: upper) = {
	let tracking = size/16 // tracking 1pt for font size 16pt
	text(font: font-sans-serif, size: size, weight: "bold", fill: color, tracking: tracking)[#modifier(body)]
}

// abstract displays the given abstract with an optional list of keywords.
#let abstract(body, keywords: none) = {
	set text(font: font-sans-serif, size: 9pt)
	pad(x: 10%)[
		#block(sticky: true)[#strong[ABSTRACT]]
		#line(length: 100%, stroke: 0.5pt)
		#block(below: 3mm)[#body]
		#if keywords != none {
			text(size: 7.5pt, weight: "bold")[KEYWORDS: #keywords.join(", ")]
		}
		#line(length: 100%, stroke: 1pt)
	]
}

// appendices show rule.
//
// Example:
//
//
//    #show: appendices
//
//    == Figures
//    <app-figures>
#let appendices(body, title: "Appendices") = {
	set heading(numbering: (..nums) => {
		let nums = counter(heading).get()
		std.numbering("A.1", ..nums.slice(1)) // skip "Appendices" parent header level.
	})
	counter(heading).update(0)
	set heading(supplement: "Appendix")

	heading(numbering: none)[#title]

	body
}

// template applies the research proposal format to the document.
#let template(
	body,
	title:   "Report Title",
	authors: none,
) = {
	// Set document title and authors.
	set document(title: title)
	set document(author: authors)

	// Set page margins.
	set page(
		margin: (x: 2.5cm, y: 2.5cm),
		numbering: none,
	)

	// Set heading numbering style.
	set heading(numbering: "1.1")

	// Use LaTeX default styles.
	show: latex-lookalike.style

	// Style figures.
	show: hallon.style-figures
	set figure.caption(separator: ".")
	show figure.where(kind: image): set figure(supplement: "Fig")

	// Serif font for title and headings.
	show std.title: set text(font: font-serif)
	show heading:   set text(font: font-serif)

	// Sans-serif font for body text.
	set text(font: font-sans-serif, size: 12pt)

	// Use single line spacing.
	set par(leading: 0.5em, spacing: 1em)

	// Set link colour.
	show link:     set text(fill: link-color)
	show ref:      set text(fill: link-color)
	show cite:     set text(fill: link-color)
	show footnote: set text(fill: link-color)

	// Reset link colour for Table of Contents.
	show outline: it => {
		show link: set text(fill: black)
		it
	}

	body
}
