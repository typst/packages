#import "@preview/latex-lookalike:0.1.4"
#import "@preview/hallon:0.1.2"

#import "@preview/nth:1.0.1": nth

// template formats the document as a lab report, essay or exam.
#let template(
	logo:              image("/inc/default_logo.png"),
	title:             "Lab report",
	subtitle:          none,
	page-header-title: none,
	course-name:       none,
	course-code:       none,
	course-part:       none,
	lab-name:          none,
	authors:           none,
	lab-partners:      none,
	lab-supervisor:    none,
	lab-group:         none,
	lab-date:          none,

	// Report contents.
	body,
) = {
	// Set document metadata.
	set document(title: title)

	// support both array and string type for authors.
	let authors-str = authors
	if type(authors) == array {
		authors-str = authors.join(", ", last: " and ")
	}

	// Set page size and margins.
	set page(
		paper: "a4",
		margin: (x: 2.5cm, top: 3.1cm, bottom: 3.55cm),
		header: {
			grid(
				columns: (2fr, 1fr, 2fr),
				align: (left, center, right),
				inset: (bottom: 5pt),
				// left
				course-code,
				// middle
				page-header-title,
				//right
				authors-str,
				grid.hline(stroke: 0.4pt),
			)
		},
	)

	// Set default font.
	set text(font: "New Computer Modern")

	// Style outline, headings, lists and quotes using the style of LaTeX.
	show: latex-lookalike.style

	// Style links and citations.
	let linkblue = blue
	show ref: set text(fill: linkblue)
	show cite: set text(fill: linkblue)

	// Place table and listing captions at top.
	show figure.where(kind: table): set figure.caption(position: top)
	show figure.where(kind: raw): set figure.caption(position: top)

	// Style figures and subfigures.
	show: hallon.style-figures

	// Set title of bibliography.
	set bibliography(title: "References")

	// === [ Frontmatter ] ======================================================

	// --- [ Front page ] -------------------------------------------------------

	page(
		numbering: none,
		header: none,
		margin: (x: 1.55cm, top: 3.1cm, bottom: 3.55cm),
	)[
		#grid(
			columns: (5.10cm, 1fr),
			gutter: 3pt,
			grid.vline(x: 1, stroke: 0.4pt + black),
			// left cell (logo)
			{
				set image(width: 4.3cm)
				logo
			},
			// right cell (title)
			block(height: 100%, inset: 2.1em)[
				#v(6.1cm)
				#if course-name != none { text(size: 1.2em)[ #course-name \ ] }
				#if course-code != none { text(size: 1.2em)[ (#course-code) ] }

				// title
				#text(size: 2.1em, weight: "bold", title)

				// subtitle
				#if subtitle != none { v(-1.5em) + text(size: 1.5em, weight: "bold", subtitle) }

				// date
				#text(size: 1.2em, {
					let today = datetime.today()
					nth(today.display("[day padding:none]"))
					today.display(" [month repr:long] [year]")
				})

				#v(1fr)

				#let cells = ()
				#if course-name != none {
					cells.push([Course:])
					cells.push([#course-name])
				}
				#if course-part != none {
					cells.push([Course part:])
					cells.push([#course-part])
				}
				#if lab-name != none {
					cells.push([Lab:])
					cells.push([#lab-name])
				}
				#if authors != none {
					// support both array and string type for authors.
					if type(authors) != array {
						cells.push([Author:])
						cells.push([#authors])
					} else {
						if authors.len() > 1 {
							cells.push([Authors:])
						} else {
							cells.push([Author:])
						}
						cells.push([#authors.join(", ", last: " and ")])
					}
				}
				#if lab-partners != none {
					// support both array and string type for lab partners.
					if type(lab-partners) != array {
						cells.push([Lab partner:])
						cells.push([#lab-partners])
					} else {
						if lab-partners.len() > 1 {
							cells.push([Lab partners:])
						} else {
							cells.push([Lab partner:])
						}
						cells.push([#lab-partners.join(", ", last: " and ")])
					}
				}
				#if lab-supervisor != none {
					cells.push([Lab supervisor:])
					cells.push([#lab-supervisor])
				}
				#if lab-group != none {
					cells.push([Lab group:])
					cells.push([#lab-group])
				}
				#if lab-date != none {
					cells.push([Lab date:])
					cells.push([#lab-date])
				}
				#block(inset: 0.4em)[
					#grid(
						columns: (auto, 1fr),
						gutter: 10pt,
						..cells,
					)
				]
			],
		)
	]

	pagebreak(weak: true)

	// --- [ Table of contents ] ------------------------------------------------

	set page(numbering: "i")
	counter(page).update(1)

	outline()
	pagebreak(weak: true)

	// Style all links after outline.
	show link: set text(fill: linkblue)

	// --- [ Main matter ] ------------------------------------------------------

	set page(numbering: "1")
	counter(page).update(1)

	body
}
