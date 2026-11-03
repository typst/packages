#import "@preview/blockst:0.2.1": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("erase all
stamp
pen down
pen up
set pen color to [#ff0000]
change pen color by (10)
set pen color to (50)
change pen shade by (10)
set pen shade to (50)
change pen size by (1)
set pen size to (1)").split("\n")


#grid(
	columns: (auto, auto),
	align: horizon,
	gutter: 0mm,
	inset: 2mm,
	grid.header(
		[*Block*],
		[*Code*],
	),
	grid.hline(),
	..blocks.map(block => (
		grid.cell[#scratch(block)],
		grid.cell[#block]
	)).flatten()
)
