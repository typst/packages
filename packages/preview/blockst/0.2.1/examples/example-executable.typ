#import "@preview/blockst:0.2.1": scratch, scratch-run, set-blockst, set-scratch-run

#set page(width: auto, height: auto, margin: 3mm, fill: none)

#set-blockst(scale: 60%)

#let square-program = "
go to x: (-45) y: (45)
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
go to x: (0) y: (90)
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
go to x: (-50) y: (0)
call triangle (100) (200)
go to x: (50) y: (50)
call triangle (50) (60)
"

#let grid-square-program = "
go to x: (-6) y: (-4)
point in direction (0)
pen down
set pen size to (2)
repeat (2)
  move (12) steps
  turn cw (90) degrees
  move (8) steps
  turn cw (90) degrees
end
"

#set-scratch-run(
  stage: (size: (300, 240)),
  start: (x: 0, y: 0, angle: 90),
  grid: (visible: false, axes: false),
  cursor: false,
  scale: 2,
)

#stack(
  spacing: 6mm,

  [*1) Hue Square*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(square-program)], [#scratch-run.stage(square-program)],
  ),

  [*2) Star Rosette (Nested repeat)*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(star-rosette-program)], [#scratch-run.stage(star-rosette-program)],
  ),

  [*3) Colored Spiral (Hue + pen size)*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(spiral-program)], [#scratch-run.stage(spiral-program)],
  ),

  [*4) Conditional Loop*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(conditional-program)], [#scratch-run.stage(conditional-program)],
  ),

  [*5) Custom Block: Triangle Pattern*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(custom-block-program)], [#scratch-run.stage(custom-block-program, cursor: false)],
  ),

  [*6) Grid Preview (Axes + fixed bounds)*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(grid-square-program)],
    [#scratch-run.grid(
      grid-square-program,
      step: 1,
      scale: 0.5,
      grid: true,
      fit: true,
      cursor: false,
    )],
  ),
)