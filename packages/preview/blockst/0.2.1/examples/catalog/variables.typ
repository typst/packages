#import "@preview/blockst:0.2.1": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("set [my variable v] to (0)
change [my variable v] by (1)
show variable [my variable v]
hide variable [my variable v]
(my variable)").split("\n")


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
