#import "pages/title.typ": *
#import "pages/affidavit.typ": *
#import "pages/abstract.typ": *
#import "pages/table-of-contents.typ": *
#import "pages/acknowledgements.typ": *
#import "pages/acronyms.typ": *
#import "pages/notations.typ": *
#import "pages/kurzfassung.typ": *
#import "helper.typ": *

// Downstream package with extra functionalities
// #import "@preview/acrostiche:0.5.0": *
#import "packages/acrostiche.typ": * // 0.5.0 + patches (untouched API)
#import "packages/notations.typ": * // 0.5.0 + patches (untouched API)

#let thesis(
	title: none,
	author: none,
	curriculum: none,
	supervisors: none,
	institute: none,
	date: none,
	acknowledgements: none,
	abstract: none, 
	kurzfassung: none, 
	keywords: none,
	notations: none,
	acronyms: none,
	list-of-figures: none,
	list-of-tables: none,
	list-of-listings: none,
	debug: none,
	body
) = [

	// --------------------------------------------------------------------------
	// Debug Options

	#show: rest => if debug {
		set par.line(numbering: n => {
			text(size: 7pt, red)[#n]
		})
		show figure: set par.line(numbering: none)
		show figure.caption: set par.line(numbering: n => {
			text(size: 7pt, red)[#n]
		})
		show raw.where(block: true): set par.line(numbering: none)
		show outline: set par.line(numbering: none)
		show math.equation: set par.line(numbering: none)

		// Highlight TODOs
		show regex("TODO"): m => { highlight(m) }
		rest
	} else {
		rest
	}

	// --------------------------------------------------------------------------
	// Citation Hotfix 

	// Hotfix to properly cite in abstract
	#set cite(style: "alphanumeric")

	// --------------------------------------------------------------------------
	// Acronyms

	#if acronyms != none [ #init-acronyms(acronyms) ]

	#if notations != none [ #init-notations(notations) ]

	// --------------------------------------------------------------------------
	// Text

	#set text(font: "New Computer Modern", lang: "en", region: "US")

	// --------------------------------------------------------------------------
	// PDF Metadata

	// Set document metadata
	#set document(
		title: title,
		author: if type(author) == content { author.text } else { author.at(0).text },
		keywords: content-to-string(keywords.join(", "))
	)

	// --------------------------------------------------------------------------
	// [CONTENT] Title Page
	// - Title page

	#title-page(
		title: title,
		author: author,
		curriculum: curriculum,
		supervisors: supervisors,
		institute: institute,
		date: date
	)

	// --------------------------------------------------------------------------
	// Paragraph
	#set par(
		justify: true,
		leading: 0.54em,
		spacing: 0.6em,
		first-line-indent: 0.35cm,
		linebreaks: "optimized"
	)

	// --------------------------------------------------------------------------
	// Page Header & Footer
	// - Show "Chapter 1: Title" and page number in footer

	// Number in page footer
	#let page_footer = context [
		#align(center)[
			#counter(page).display("1")
		]
	]

	// Number in page footer (roman numerals)
	#let page_footer_roman = context [
		#align(center)[
			#counter(page).display("i")
		]
	]
	#let page_footer_descent = 1.4cm

	// Chapter in header if not first page of it
	// TODO: probably its much better if it can be reworked into a lambda instead
	// of context + queries
	#let page_header = context [

		// "Chapters" that shouldn't show "Chapter 1." counter
		#let whtlt = ([Bibliography], [Contents], [List of Figures], 
									[List of Tables], [List of Listings],)

		// Get the real document page (not page counter)
		#let pageNumber = here().page()
		// Get all the level 1 headings in the document
		#let headings = query(heading.where(level: 1))
		// Match if this page has a level 1 heading
		#let isSectionPage = headings.any(it => it.location().page() == pageNumber)
		// Get its section name
		#let sectionName  = query(selector(heading.where(level: 1))
			.before(here()))

		// If it doesn't have a level 1 heading, print text
		#if not isSectionPage [
			#align(center)[
				#if sectionName == none or sectionName == () [
				] else if not whtlt.contains(sectionName.last().body) [
					_Chapter #counter(heading.where(level: 1)).display("1") 
					#sectionName.last().body _ 
				] else [
					_ #sectionName.last().body _ 
				]
			]
		]
	]
	#let page_header_ascent = 0.85cm

	// --------------------------------------------------------------------------
	// Page
	#set page(
		numbering: "1",
		margin: (
		bottom: 5.33cm,
		left: 3.15cm,
		right: 3.15cm,
		top: 3.7cm,
	),
		footer-descent: page_footer_descent,
		footer: context [ #page_footer ],
		header-ascent: page_header_ascent,
		header: context [ #page_header ],
	)

	// --------------------------------------------------------------------------
	// Sections

	// Level 1 heading (Chapter)
	#show heading.where(level: 1): set heading(supplement: "Chapter") // for @ref
	#show heading.where(level: 1): set text(size: 20pt)
	#show heading.where(level: 1): set heading(numbering: "1.")
	#show heading.where(level: 1): set par(first-line-indent: 0pt)
	#show heading.where(level: 1): it => [
		// TODO: come with a better solution...
		#let whtl = ([Bibliography], [Abstract], [Contents], [List of Figures],
								 [List of Tables], [List of Listings], [Acknowledgements], 
								 [Acronyms], [Notation],
								 if kurzfassung != none [#kurzfassung.at("title")])

		// Forced page break (new chapter)
		#pagebreak()

		#block(sticky: true)[
			#v(weak: false, 1.75cm)
			// Show Chapter + X
			#if not whtl.contains(it.body) [
				#it.supplement #counter(heading).display(it.numbering)
					#v(0.38cm)
				]

				#it.body
				#v(0.65cm)
		]
	]

	// Level 2 heading 
	#show heading.where(level: 2): set block(above: 0.86cm, below: 0.6cm,
		sticky: true)
	#show heading.where(level: 2): set text(size: 14pt)
	#show heading.where(level: 2): set heading(numbering: "1.1.")

	// Level 3 heading
	#show heading.where(level: 3): set block(above: 0.8cm, below: 0.6cm,
		sticky: true)
	#show heading.where(level: 3): set text(size: 12pt)
	#show heading.where(level: 3): set heading(numbering: "1.1.1.")

	// Level 4 heading
	#show heading.where(level: 4): set block(above: 0.6cm, below: 0.6cm,
		sticky: true)
	#show heading.where(level: 4): set text(size: 11pt)

	// --------------------------------------------------------------------------
	// [CONTENT] Document (pre)
	// - Affidavit
	// - Acknowledgements
	// - Abstract
	// - Kurzfassung
	// - Outline(s): Sections, Figures, Tables, Listings

	#context [
		// Disable showing sections in the outline
		#set heading(outlined: false)
		// Page footer is in roman numbers
		#set page(footer: page_footer_roman)

		// Show affidavit (authoring) page on the second page
		#affidavit-page()

		// Show acknowledgements page (starts on page 3)
		#acknowledgements-page(acknowledgements)

		// Show abstract page
		#abstract-page(abstract, keywords)

		// Show kurzfassung page
		#if kurzfassung != none [
			#kurzfassung-page(
					kurzfassung.at("title"),
					kurzfassung.at("abstract"),
					kurzfassung.at("ktitle"),
					kurzfassung.at("keywords"),
			)
		]

		// Table of Contents
		#toc-page(
			list-of-figures: list-of-figures,
			list-of-tables: list-of-tables,
			list-of-listings: list-of-listings,
		)
	]

	// --------------------------------------------------------------------------

	#set text(size: 11pt)
	#set page(footer: context [ #page_footer ] )

	// --------------------------------------------------------------------------
	// Figures, Tables, Listings, Equations

	// Figures (General)

	// Reset the counter H per heading: Figure H.N: caption
	#show heading.where(level: 1): it => {
		counter(figure.where(kind: image)).update(0)
		counter(figure.where(kind: table)).update(0)
		counter(figure.where(kind: raw)).update(0)
		it
	}
	// Change the nubering to H.N (section.counter)
	#set figure(numbering: num =>
		numbering("1.1", counter(heading).get().first(), num)
	)
	// Spacing from next/prev content
	#show figure: set block(above: 0.4cm, below: 0.3cm)
	// Caption style
	#show figure.caption: it => context [
		#v(0.3cm)
		#grid(
			columns: 2,
			gutter: 0cm,
			align: left,
			box[
				#it.supplement~#it.counter.display()#it.separator
			],
			box[
				#align(left)[#it.body]
			],
		)
	]
	// Special case for listings (less marging
	// TODO: these negative spaces are a bit spaghetti I recognize
	#show figure.caption.where(kind: raw): it => context [
		#v(-0.32cm)
		#grid(
			columns: 2,
			gutter: 0cm,
			align: left,
			box[
				#it.supplement~#it.counter.display()#it.separator
			],
			box[
				#align(left)[#it.body]
			],
		)
	]
	// Fix #311 issue (paragraph indent)
	#show figure: it => context [
		#it
		#fix-311
	]

	// Listings

	#show raw: set text(size: 8pt)

	// Do you want tree-sitter powered syntax highlighting in code blocks?
	// Get https://github.com/RubixDev/syntastica-typst :)

	// Set default tab-size (2 for documents)
	#set raw(tab-size: 2)
	// Code blocks taking full width and with a black border
	//#show raw.where(block: true): set block(stroke: black + 0.5pt,
	//	inset: 0.25cm, width: 100%)
	// Show line numbers in gray
	#show raw.where(block: true): code => {
		show raw.line: line => {

			// Create a box with the size of `size`
			let boxsize(size) = [
				#box(width: size)[
					#align(right + horizon)[
						#text(fill: gray)[#line.number]
					]
				]
				#line.body
			]

			// Decide the size of the box depending on the numbers of lines of code
			context {
				let loc = code.lines.first().count
				let l1 = measure(text(fill: gray)[0]).width // Get size of a digit
				boxsize(l1 * calc.ceil(loc / 10)) // Pad 0 (1 digit) 00 (2 digits) ...
			}
		}

		v(0.2cm)
		grid(gutter: 0pt, align: left, inset: 0pt, columns: (3%, 1fr, 3%),
			box[],
			block(stroke: 0.5pt + black, inset: 0.25cm, width: 100%, clip: true)[
				#code
			],
			box[],
		)
		fix-311
		v(0.2cm)
	}

	// Equations

	// Reset equation counter per section
	#show heading.where(level: 1): it => {
		counter(math.equation).update(0)
		it
	}

	// Set equation counter style
	#set math.equation(numbering: num =>
		(numbering("1.1", counter(heading).get().first(), num))
	)

	// Style to display the equation block (just to add parenthesis):
	//             |equation|         (S.N)
	#show math.equation: eq => {
		if eq.block and eq.numbering != none {
			let eqCounter = counter(math.equation).at(eq.location())
			let eqNumbering = numbering(eq.numbering, ..eqCounter)

			grid(
				// TODO: change this 0pt as its fake. The (1.1) numbering takes more
				// space. The issue is that with `auto` the centering of the equation
				// will be based on the grid's cell width and not the page width.
				columns: (1fr, 0pt),
				math.equation(eq.body, block: true, numbering: none),
				align(right+ horizon)[(#eqNumbering)],
			)
		} else {
			eq
		}
	}

	// --------------------------------------------------------------------------
	// Footnote

	#set footnote.entry(
		separator: move(dy: 0.05cm)[#line(length: 40%, stroke: 0.5pt)]
	)

	// --------------------------------------------------------------------------
	// Bibliography & Citations

	#set bibliography(title: "Bibliography")
	#set cite(style: "alphanumeric")
	#show bibliography: set par(spacing: 0.4cm)

	// --------------------------------------------------------------------------
	// Lists, Enumeration, etc

	// General listing config
	#set list(spacing: 1.15em, indent: 0.48cm, body-indent: 0.2em)
	// Padding before/after a listing
	#show list: set block(above: 0.7cm, below: 0.55cm)
	// Thicker bullet points
	//#set list(marker: text(15pt, [•], baseline: -5pt))
	//#show list.where(level: 1): set list(marker: text(15pt, [#sym.bullet]))
	#set list(marker: (
		move(dy: -0.08cm, text(size: 15pt)[#sym.bullet]),
		box[#move(dy: 0.04cm, text(size: 7pt)[#sym.bar.h #h(0.12cm)])],
		box[#move(dy: -0.04cm, text(size: 11pt)[#sym.convolve #h(0.12cm)])],
	))

	#show list: l => {
		l
		fix-311
	}
	//#set list(marker: (level) => {
	//	// move is a hotfix for #1204. Won't work with different sizes/objects, so
	//	// listing can only be used for regular text for now.
	//	// https://github.com/typst/typst/issues/1204
	//	move(dy: -0.08cm, text(size: 15pt)[#sym.bullet])
	//})


	// --------------------------------------------------------------------------
	// [CONTENT] Document (cont)
	// - User Sections
	// - Acronyms
	// - Bibliography
	// - User Acronyms

	// Reset counters to start user part of the document
	#counter(heading).update(0)
	#counter(heading.where(level: 1)).update(0)
	#counter(page).update(1)

	#body
]

#let appendix(body) = {
	show heading.where(level: 1): set heading(supplement: "Appendix")
	show heading.where(level: 1): set heading(numbering: "A.")
	show heading.where(level: 2): set heading(numbering: "A.1.")
	show heading.where(level: 3): set heading(numbering: "A.1.1.")
	set figure(numbering: num =>
		numbering("A.1", counter(heading).get().first(), num)
	)
	set math.equation(numbering: num =>
		(numbering("A.1", counter(heading).get().first(), num))
	)
	counter(heading).update(0)
	body
}

//vim:tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab colorcolumn=81
