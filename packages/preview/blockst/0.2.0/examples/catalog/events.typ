#import "@preview/blockst:0.2.0": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: white)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("when green flag clicked
when [space v] key pressed
when this sprite clicked
when backdrop switches to [backdrop1 v]
when [loudness v] > (10)
when I receive [message1 v]
broadcast [message1 v]
broadcast [message1 v] and wait").split("\n")


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
