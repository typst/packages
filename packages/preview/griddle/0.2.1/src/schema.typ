// Importing package files
#import "utils.typ": *

// Show the grid schema in a table format, given the crossword schema.
#let show-schema(schema, 
		cell-size: (24pt, 24pt),
		cell-fill: white,
		cell-stroke: 1pt + black,
		wall-fill: black,
		wall-stroke: 1pt + black,
		solved: false,
	) = {
	let grid = schema.grid
	// Formatting table
	show text: upper
	set table.cell(align: center, inset: 0pt, fill: red)
	let wall-tide = table.cell(fill: wall-fill, stroke: wall-stroke)[]

	// Defining an *auxiliary function* that maps every cell-structure into a visualizable table cell.
	let map-for-visualization(cell) = {
		// Check input
		assert("body" in cell)
		assert("number" in cell)
		let has-errors = "errors" in cell and cell.errors.len() > 0
		
		// Setting the type and content of the cell
		if cell.body == none {
			// By default, uninitialized cells are represented as walls
			wall-tide
		} else {
			let cell-content = if solved or cell.solved {
				cell.body
			} else {
				[ ]
			}
			// If content is valid, we have a normal cell
			table.cell(fill: cell-fill, stroke: cell-stroke)[
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

	table(
		columns: (cell-size.at(0), ) * (schema.cols),
		rows: (cell-size.at(1), ) * (schema.rows),
		..grid.map(map-for-visualization)
	)

	for cell in grid {
		if "errors" in cell and cell.errors.len() > 0 {
			for error in cell.at("errors") {
				[ - #error]
			}
		}
	}
}

