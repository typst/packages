#import "@preview/blockst:0.2.0": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: white)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("add [thing] to [my list v]
delete (1) of [my list v]
delete all of [my list v]
insert [thing] at (1) of [my list v]
replace item (1) of [my list v] with [thing]
(item (1) of [my list v])
(item # of [thing] in [my list v])
(length of [my list v])
<[my list v] contains [thing]?>
show list [my list v]
hide list [my list v]").split("\n")


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
