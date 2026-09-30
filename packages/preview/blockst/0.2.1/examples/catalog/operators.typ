#import "@preview/blockst:0.2.1": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("(() + ())
(() - ())
(() * ())
(() / ())
(pick random (1) to (10))
<() > ()>
<() < ()>
<() = ()>
<> and <>
<> or <>
not <>
(join [apple] [banana])
(letter (1) of [apple])
(length of [apple])
([apple] contains [a]?)
(() mod ())
(round ())
([sqrt v] of (9))").split("\n")


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
