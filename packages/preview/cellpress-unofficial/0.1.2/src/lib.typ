// Cell Press template.

// Fonts.
#let font-sans-serif = "Nimbus Sans" // "Helvetica Neue"

// Colours.
#let zebra-gray     = rgb(luma(95.25%)) // rgb("#f3f3f3")
#let cellpress-red  = rgb("#a93b45")    // summary title red, table red
#let cellpress-blue = rgb("#0296d3")    // journal blue, summary blue, link blue
#let cellpress-grey = rgb("#b3b3b3")    // supertitle grey

// --- [ tables ] --------------------------------------------------------------

#let toprule(color: cellpress-red) = {
	table.hline(stroke: 0.7pt + color)
}

#let bottomrule(color: cellpress-red) = {
	table.hline(stroke: 0.7pt + color)
}

#let midrule(color: cellpress-red) = {
	table.hline(stroke: 0.5pt + color)
}

#let tabsubhdr(content, colspan: 3, color: cellpress-red) = table.header(
	level: 2, // sub header
	table.cell(
		colspan: colspan,
		inset: (y: 5pt),
		fill: none,
		{
			// TODO: move styling to `show table.header.where(level: 2)` show-set rule when https://github.com/typst/typst/issues/3640 is resolved.
			set text(fill: color)
			show text: emph
			content
		}
	)
)

#let style-table(body) = {
	// tables
	show figure.where(kind: table): set figure.caption(position: top, separator: [. ])
	show figure.where(kind: table): set block(breakable: true, above: 14pt, below: 14pt)
	show figure.where(kind: table): outer => {
		show figure.caption: it => align(
			center,
			[
				#strong[#it.supplement #context it.counter.display(it.numbering)#it.separator]
				#it.body
			]
		)
		outer
	}
	show table: set table(
		stroke: none,
		align: left,
		fill: (_, y) => {
			// TODO: remove `y != 0 and` when https://github.com/typst/typst/issues/4159#issuecomment-3124855835 is resolved
			if y != 0 and not calc.odd(y) {
				zebra-gray
			}
		},
		// TODO: uncomment when https://github.com/typst/typst/issues/4159#issuecomment-3124855835 is resolved is resolved
		//inset: (x: 2.5pt, y: 3pt),
		// TODO: remove when https://github.com/typst/typst/issues/4159#issuecomment-3124855835 is resolved is resolved
		inset: (x, y) => {
			let y_pad = 3pt
			if y == 0 {
				y_pad = 4pt
			}
			(x: 2.5pt, y: y_pad)
		}
	)
	// table header style.
	// TODO: use `show table.header.where(level: 1)` when https://github.com/typst/typst/issues/3640 is resolved.
	show table.cell.where(y: 0): it => {
		show text: strong
		set text(fill: cellpress-red)
		// TODO: uncomment when https://github.com/typst/typst/issues/4159#issuecomment-3124855835 is resolved is resolved
		//set table.cell(
		//	inset: (x: 2.5pt, y: 4pt),
		//	fill: none,
		//)
		it
	}

	body
}

// --- [ template ] ------------------------------------------------------------

// summary displays the given summary.
#let summary(body) = {
	place(
		top,
		float: true,
		scope: "parent",
	)[
		#v(2mm)
		#heading(level: 1, outlined: false)[Summary]
		#set text(font: font-sans-serif, size: 9.9pt, weight: "semibold", fill: cellpress-blue)
		#set par(
			leading: 0.33em, // adjust line height
		)
		#block(below: 3mm, body)
	]
}

// print-supertitle displays the "super" title (i.e. "Article") on the front
// page.
#let print-supertitle(supertitle) = {
	set text(font: font-sans-serif, size: 13.9pt, weight: "extrabold", tracking: -0.1pt, fill: cellpress-grey)
	// TODO: skip scale when extrabold exists (using variable fonts: https://github.com/typst/typst/issues/185)
	block(scale(origin: left+horizon, x: 110%)[#supertitle])
}

// print-title displays the title of the paper.
#let print-title(title) = {
	set text(font: font-sans-serif, size: 20pt, weight: "bold", tracking: -0.5pt)
	set par(
		justify: false,
		leading: 0.33em, // adjust line height
	)
	block(width: 75%, title)
}

// print-authors displays the list of authors.
#let print-authors(authors) = {
	let authors-str = authors
	if type(authors) == array {
		authors-str = authors.join(", ", last: " and ")
	}
	set text(font: font-sans-serif, size: 9pt, weight: "semibold")
	// TODO: skip scale when semibold exists (using variable fonts: https://github.com/typst/typst/issues/185)
	block(scale(origin: left+horizon, x: 97%)[#authors-str])
}

// print-doi displays the doi link.
#let print-doi(doi) = {
	set text(font: font-sans-serif, size: 7.9pt)
	block(link("https://doi.org/" + doi))
}

// template applies the Cell Press article format to the document.
#let template(
	journal:      "Neuron",  // "Cell Reports"
	supertitle:   "Article", // "Resource"
	title:        "Paper Title",
	authors:      ("John Doe", "Jane Rue"),
	doi:          none, // 10.1016/j.cell.2006.07.024
	date:         datetime.today(),
	body
) = {
	set page(
		width: 8.37in,
		height: 10.87in,
		margin: (
			inside: 1.88cm,
			outside: 2.1cm,
			top: 3.555cm,
		),
		columns: 2,
		header: context {
			if calc.odd(here().page()) [
				// odd page
				#if here().page() == 1 [
					// first page
					#grid(
						columns: (1fr, 1fr),
						//rows: 100%,
						align: (left, right),
						[
							#block(text(font: font-sans-serif, size: 24pt, weight: "bold", tracking: -1pt, fill: cellpress-blue)[#journal])
							#v(0.57cm)
						],
						[
							#place(top+right, dx: 0.3mm, dy: 1mm)[#image("/inc/cell_press_logo.pdf")]
						],
					)
					#place(
						top+right,
						dy: 1.475cm,
						dx: 2.485cm,
						rect(width: 2cm, height: 1.2cm, fill: cellpress-blue),
					)
				] else [
					#grid(
						columns: (1fr, 1fr),
						align: (left, right),
						[
							#block(text(font: font-sans-serif, size: 19pt, weight: "bold", tracking: -1pt, fill: cellpress-blue)[#journal])
							#v(-2mm)
							#block(text(font: font-sans-serif, size: 13.9pt, weight: "bold", fill: cellpress-grey)[#supertitle])
						],
						[
							#place(top+right, dx: 0.3mm, dy: -0.9mm)[#image("/inc/cell_press_logo.pdf")]
						],
					)
					#place(
						top+right,
						dy: 1.475cm,
						dx: 2.485cm,
						rect(width: 2cm, height: 1.2cm, fill: cellpress-blue),
					)
				]
			] else [
				// even page
				#grid(
					columns: (1fr, 1fr),
					align: (left, right),
					[
						#place(top+left, dx: -0.3mm, dy: -0.9mm)[#image("/inc/cell_press_logo.pdf")]
					],
					[
						#block(text(font: font-sans-serif, size: 19pt, weight: "bold", tracking: -1pt, fill: cellpress-blue)[#journal])
						#v(-2mm)
						#block(text(font: font-sans-serif, size: 13.9pt, weight: "bold", fill: cellpress-grey)[#supertitle])
					],
				)
				#place(
					top+left,
					dy: 1.475cm,
					dx: -2.485cm,
					rect(width: 2cm, height: 1.2cm, fill: cellpress-blue),
				)
			]
		},
		header-ascent: 20%,
	)
	set par(justify: true)
	set text(font: font-sans-serif, size: 8.4pt)

	// Set link colour.
	show ref: set text(fill: cellpress-blue)
	show link: set text(fill: cellpress-blue)
	show cite: set text(fill: cellpress-blue)
	show footnote: set text(fill: cellpress-blue)

	// Style tables.
	show: style-table

	// Style headings.
	show heading.where(level: 1): it => {
		set text(font: font-sans-serif, size: 8.4pt, weight: "extrabold", tracking: -0.2pt, fill: cellpress-red)
		// TODO: skip scale when extrabold exists (using variable fonts: https://github.com/typst/typst/issues/185)
		set block(below: 0.55cm)
		scale(origin: left+horizon, x: 110%)[#upper(it)]
	}
	show heading.where(level: 2): it => {
		set text(font: font-sans-serif, size: 8.4pt, weight: "extrabold", tracking: -0.2pt, fill: cellpress-red)
		// TODO: skip scale when extrabold exists (using variable fonts: https://github.com/typst/typst/issues/185)
		set block(below: 0.55cm)
		scale(origin: left+horizon, x: 110%)[#it]
	}

	// Use Cell citation style.
	set bibliography(style: "cell")

	// Display title and authors.
	place(
		top+left,
		scope: "parent",
		float: true,
	)[
		#print-supertitle(supertitle)
		#v(-6.5mm)
		#print-title(title)
		#v(-2mm)
		#print-authors(authors)
		#if doi != none {
			print-doi(doi)
		}
	]

	// Display body.
	body
}
