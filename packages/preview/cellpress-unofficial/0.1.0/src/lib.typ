// Cell Press template.

#let cellpress-red = rgb(169, 59, 69)  // Cell Press red
#let zebra-gray    = rgb(luma(95.25%)) // rgb("#f3f3f3")

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
	show figure.where(kind: table): it => {
		show figure.caption: it => align(
			center,
			[
				#strong[#it.supplement #context it.counter.display(it.numbering)#it.separator]
				#it.body
			]
		)
		it
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
