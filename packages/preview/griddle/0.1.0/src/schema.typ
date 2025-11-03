// Importing package files
#import "utils.typ": *

// _Auxiliary data structure_.
// This aggregates the options for wall tides in the crossword grid. 
#let wall-tides = (
	black: table.cell(fill: black)[],
	empty: table.cell(fill: auto, stroke: none)[],
	rainbow: table.cell(fill: gradient.conic(..color.map.rainbow, angle: -60deg))[],
)

// _Auxiliary function_.
// Maps every cell-structure into a visualizable table cell.
#let map-for-visualization(cell, wall-tide: wall-tides.at(default-wall), solved: false) = {
	assert("body" in cell)
	assert("number" in cell)

	let has-errors = "errors" in cell and cell.errors.len() > 0
	let bg-color = if has-errors {red} else {default-bg-color}
	
	if cell.body == none {
		wall-tide
	} else {
		let cell-content = if cell.solved or solved {
			cell.body
		} else {
			[ ]
		}
		table.cell(fill: bg-color, inset: 0pt)[
			#box(width: 1fr, height: 100%)[#place(top + left, dx: 1.5pt, dy: 8%, float: true, scope: "parent")[
				#text(black, size: 10pt, weight: "bold")[
					#if cell.number > 0 {cell.number} else []
				]
			]]
			#box(width: 100%, height: 100%)[#place(top + center, dx: 0pt, dy: -100%, float: true, scope: "parent")[
				#text(
					writing-color, 
					font: writing-font, 
					weight: "bold", 
					baseline: 2pt, 
					size: 18pt)[
				#cell-content
			]]]
		]
	}
}


// Show the grid schema in a table format, given the crossword schema.
#let show-schema(schema, cell-size: default-cell-size, wall: default-wall, solved: false) = {
	let grid = schema.grid

	// Formatting table
	show text: upper
	set table.cell(align: center)

	let wall-tide = wall-tides.at(wall, default: wall-tides.at(default-wall))

	table(
		columns: (cell-size.at(0), ) * (schema.cols),
		rows: (cell-size.at(1), ) * (schema.rows),
		..grid.map(map-for-visualization.with(wall-tide: wall-tide, solved: solved))
	)

	for cell in grid {
		if "errors" in cell and cell.errors.len() > 0 {
			for error in cell.at("errors") {
				[ - #error]
			}
		}
	}
}

