#import "@preview/blockst:0.2.0": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: white)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("<touching [mouse-pointer v]?>
<touching color [#ff0000]?>
<color [#ff0000] is touching [#00ff00]?>
(distance to [mouse-pointer v])
ask [What's your name?] and wait
(answer)
<key [space v] pressed?>
<mouse down?>
(mouse x)
(mouse y)
(loudness)
(timer)
reset timer
([x position v] of [Sprite1 v])
(current [year v])
(days since 2000)
(username)
<online?>").split("\n")


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
