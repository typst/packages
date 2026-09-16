#import "@preview/blockst:0.2.0": scratch, scratch-execute, scratch-run, set-scratch-run, set-blockst

#set page(width: auto, height: auto, margin: 3mm, fill: white)

#set-blockst(scale: 60%)

#let square-program = "
go to x: (-45) y: (-45)
pen down
set pen [color v] to (0)
set pen size to (45)
repeat (4)
  move (90) steps
  turn cw (90) degrees
  change pen [color v] by (25)
end"

#let star-rosette-program = "
go to x: (0) y: (0)
point in direction (90)
pen down
set pen size to (3)
repeat (9)
  repeat (5)
    move (90) steps
    turn cw (144) degrees
  end
  turn cw (40) degrees
  change pen [color v] by (10)
end"

#let spiral-program = "
go to x: (-95) y: (-10)
point in direction (90)
pen down
set pen size to (50)
repeat (60)
  move (10) steps
  turn cw (6) degrees
  change pen [color v] by (8)
  change pen size by (-0.5)
end"

#let conditional-program = "
when green flag clicked
set [i v] to (6)
go to x: (0) y: (0)
point in direction (90)
pen down
set pen size to (8)
repeat until <(i) > (200)>
  move (i) steps
  turn cw (90) degrees
  change [i v] by (7)
  change pen [color v] by (4)
end"

#let custom-block-program = "
define triangle (var [size]) (color)
set pen [color v] to (var [color])
pen down
repeat (3)
  move (var [size]) steps
  turn cw (120) degrees
end
pen up

when green flag clicked
set pen size to (8)
go to x: (-50) y: (-50)
call triangle (100) (200)
go to x: (50) y: (50)
call triangle (50) (60)
"

#set-scratch-run(
  width: 300,
  height: 240,
  start-x: 0,
  start-y: 0,
  start-angle: 90,
  show-grid: false,
  show-axes: false,
  show-cursor: false,
  unit: 2
)

#stack(
  spacing: 6mm,

  [*1) Hue Square*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(square-program)],
    [#scratch-run(..scratch-execute(square-program))],
  ),

  [*2) Star Rosette (Nested repeat)*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(star-rosette-program)],
    [#scratch-run(..scratch-execute(star-rosette-program))],
  ),

  [*3) Colored Spiral (Hue + pen size)*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(spiral-program)],
    [#scratch-run(..scratch-execute(spiral-program))],
  ),

  [*4) Conditional Loop*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(conditional-program)],
    [#scratch-run(..scratch-execute(conditional-program))],
  ),

  [*5) Custom Block: Triangle Pattern*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(custom-block-program)],
    [#scratch-run(..scratch-execute(custom-block-program), show-cursor: false)],
  ),
)
