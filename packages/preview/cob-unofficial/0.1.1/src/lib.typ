// Unofficial CoB (The Company of Biologists) template.

#import "@preview/hallon:0.1.2"

// Fonts.
#let font-serif      = "Nimbus Roman"
#let font-sans-serif = "Nimbus Sans"

// titcolor specifies the "super" title colour.
#let titcolor = rgb(64, 193, 234) // CoB cyan
// linkblue specifies the colour of links.
#let linkblue = rgb(66, 93, 178)

// print-supertitle displays the "super" title (i.e. "RESEARCH") on the front
// page.
#let print-supertitle(supertitle) = {
	set text(font: font-sans-serif, size: 8pt, fill: titcolor, tracking: 0.5pt)
	//show text: smallcaps // TODO: figure out how to fix (need Cap version of font)?
	show text: strong
	show text: upper
	block(supertitle)
}

// print-header-supertitle displays the "super" title (i.e. "RESEARCH") in the
// page header.
#let print-header-supertitle(supertitle) = {
	set text(font: font-sans-serif, size: 5.6pt, fill: titcolor, tracking: 0.4pt)
	//show text: smallcaps // TODO: figure out how to fix (need Cap version of font)?
	show text: upper
	supertitle
}

// print-title displays the title of the paper.
#let print-title(title) = {
	set text(font: font-sans-serif, size: 18pt)
	block(title)
}

// print-authors displays the list of authors.
#let print-authors(authors) = {
	set text(font: font-sans-serif, size: 12pt)
	show text: strong
	block(authors.join(", ", last: " and "))
}

// print-availability displays an availability notice.
#let print-availability(title, body) = {
	set text(font: font-sans-serif, size: 7pt)
	block(
		above: 1.9em,
		below: 0.8em,
		text(font: font-sans-serif, size: 7.5pt, weight: "bold")[#title availability],
	)
	body
}

#let abstract(body, keywords: none) = {
	set text(font: font-sans-serif)
	set text(size: 9pt)
	block(sticky: true)[#strong[ABSTRACT]]
	line(length: 100%, stroke: 0.5pt)
	block(below: 3mm, body)
	if keywords != none {
		set text(size: 7.9pt)
		strong[KEYWORDS: #keywords.join(", ")]
	}
	line(length: 100%, stroke: 1pt)
}

// data-availability displays a data availability notice.
#let data-availability(body) = {
	print-availability("Data", body)
}

// code-availability displays a code availability notice.
#let code-availability(body) = {
	print-availability("Code", body)
}

// template applies the CoB research paper format to the document.
#let template(
	supertitle:   "Research Article",
	title:        "Paper Title",
	authors:      ("John Doe", "Jane Rue"),
	article-id:   "xxxxxx",
	article-year: datetime.today().year(),
	date:         datetime.today(),
	body
) = {
	set page(
		"us-letter",
		margin: (
			inside: 1.685cm,
			outside: 1.77cm,
			top: 2.38cm,
		),
		columns: 2,
		header: context [
			#if here().page() == 1 [
				#set text(font: font-sans-serif, size: 7pt)
				#rect(
					stroke: (bottom: 0.5pt + black),
					width: 100%,
					inset: (x: 0pt, y: 1.02em),
				)[
					#stack(
						dir: ltr,
						[© #{article-year}. MANUSCRIPT SUBMITTED TO JOURNAL OF CELL SCIENCE (#{article-year}) 00, jcs#{article-id}. doi:#link("https://doi.org/10.1242/jcs."+article-id, "10.1242/jcs."+article-id)],
						h(1fr),
						box(
							inset: (bottom: -0.175cm),
							// TODO: use PDF version of logo when Typst 0.14.0 is released.
							image("/inc/COB_Publisher_Logo.svg"),
						),
					)
				]
				#v(-0.3mm)
			] else [
				#rect(
					stroke: (bottom: 0.5pt + black),
					width: 100%,
					inset: (x: 0pt, y: 0.7em)
				)[
					#stack(
						dir: ltr,
						print-header-supertitle(supertitle),
						h(1fr),
						text(font: font-serif, size: 7pt)[Journal of Cell Science (#{article-year}) 00, jcs#{article-id}. doi:#link("https://doi.org/10.1242/jcs."+article-id, "10.1242/jcs."+article-id)],
					)

				]
			]
		],
		header-ascent: 30%,
	)

	// Set heading styles.
	show heading.where(level: 1): it => {
		set text(font: font-sans-serif, size: 8.5pt)
		show text: upper
		it
	}
	show heading.where(level: 2): it => {
		set text(font: font-sans-serif, size: 8.5pt)
		it
	}
	show heading.where(level: 3): it => {
		//set text(font: font-serif, size: 9.4pt)
		set text(weight: "regular") // disable bold
		show text: emph
		it
	}

	// Set default font and text size.
	set text(font: font-serif, size: 9.4pt)

	// Set line height and justification of paragraphs.
	set par(
		justify: true,
		first-line-indent: 1.2em,
		spacing: 0.5em,
		leading: 0.5em, // adjust line height
	)

	//show ref: set text(fill: linkblue)
	show link: set text(fill: linkblue)
	show cite: set text(fill: linkblue)

	// Set bibliography title.
	set bibliography(title: "References")

	// HACK to insert "Received date" before footnote entry list.
	show footnote.entry: it => {
		let loc = it.note.location()
		if counter(footnote).at(loc).first() == 1 {
			set text(size: 8pt)
			block(
				above: 0.5em,
				strong[Received #date.display("[day] [month repr:long] [year]")]
			)
		}
		it
	}

	// Style footnote links.
	show footnote: set text(fill: linkblue)

	// Style tables.
	show figure.where(kind: table): block.with(above: 1em)
	show figure.where(kind: table): set figure.caption(position: top, separator: ". ")
	set table(
		stroke: none,
		inset: (x: 5pt, y: 2pt),
	)
	set table.hline(stroke: 0.3pt)

	// Apply figure and subfigure styles.
	show: hallon.style-figures

	// Use short supplement for figures and subfigures (place after
	// `hallon.style-subfig` show rule for supplement of "subfigure" kind to take
	// effect).
	show figure.where(kind: image): set figure(supplement: "Fig.")
	show figure.where(kind: image): set figure.caption(separator: [. ])
	show figure.where(kind: "subfigure"): set figure(supplement: "Fig.")

	// https://rupress.org/jcb/pages/reference-guidelines
	//
	// - dependent style:   https://www.zotero.org/styles/the-journal-of-cell-biology
	// - independent style: https://www.zotero.org/styles/the-rockefeller-university-press
	set bibliography(style: "the-rockefeller-university-press.csl")

	// Set space between columns.
	set columns(gutter: 0.5cm)

	// Display title and authors.
	place(
		top+left,
		scope: "parent",
		float: true,
	)[
		#v(0.6mm)
		#print-supertitle(supertitle)
		#v(2.6mm)
		#print-title(title)
		#v(0.4mm)
		#print-authors(authors)
		#v(0.78cm)
	]

	// Display body.
	body
}
