#import "@preview/blockst:0.2.0": blockst, scratch

#set page(width: auto, height: auto, margin: 4mm, fill: white)
#set text(16pt, font: "Helvetica Neue", weight: 500)

#let blocks = ("move (10) steps
turn cw (15) degrees
turn ccw (15) degrees
point in direction (90)
point towards [mouse-pointer v]
go to x: (0) y: (0)
go to [mouse-pointer v]
glide (1) secs to x: (0) y: (0)
glide (1) secs to [mouse-pointer v]
change x by (10)
set x to (0)
change y by (10)
set y to (0)
if on edge, bounce
set rotation style [left-right v]
(x position)
(y position)
(direction)").split("\n")


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