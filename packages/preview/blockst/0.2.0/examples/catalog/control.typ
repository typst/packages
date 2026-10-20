#import "@preview/blockst:0.2.0": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: white)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("wait (1) seconds
repeat (10)
end
forever
end
if <> then
end
if <> then
else
end
wait until <>
repeat until <>
end
stop [all v]
when I start as a clone
create clone of [myself v]
delete this clone").split("\n")


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
