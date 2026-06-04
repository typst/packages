//==============================================================================
// The dragon curve
//
// Public functions:
//     dragon-curve
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate dragon curve
//
// iterations: [0, 16]
// axiom: "FX"
// rule set:
//     "X" -> "X+YF+"
//     "Y" -> "-FX-Y"
// angle: 90 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let dragon-curve(n, step-size: 10, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 0 and n <= 16, message: "`n` should be in range [0, 16]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "FX"
  let rule-set = (X: "X+YF+", Y: "-FX-Y")
  let dx = (step-size, 0, -step-size, 0)
  let dy = (0, step-size, 0, -step-size)

  let s = axiom
  for i in range(n) {s = s.replace(regex("X|Y"), x => rule-set.at(x.text))}

  let dir = 0
  let cmd = ()
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 3}
    } else if c == "+" {
      dir += 1
      if (dir == 4) {dir = 0}
    } else if c == "F" {
      cmd.push(std.curve.line((dx.at(dir) * 1pt, dy.at(dir) * 1pt), relative: true))
    }
  }

  let tbl-x-min = (0, 0, 0, -2, -4, -5, -5, -5, -5, -5, -10, -42, -74, -85, -85, -85, -85)
  let tbl-x-max = (0, 1, 1, 1, 1, 1, 2, 10, 18, 21, 21, 21, 21, 21, 42, 170, 298)
  let tbl-y-min = (0, 0, 0, 0, -1, -5, -9, -10, -10, -10, -10, -10, -21, -85, -149, -170, -170)
  let tbl-y-max = (0, 1, 2, 2, 2, 2, 2, 2, 5, 21, 37, 42, 42, 42, 42, 42, 85)
  let x-min = tbl-x-min.at(n) * step-size * 1pt
  let x-max = tbl-x-max.at(n) * step-size * 1pt
  let y-min = tbl-y-min.at(n) * step-size * 1pt
  let y-max = tbl-y-max.at(n) * step-size * 1pt

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(stroke: stroke, ..cmd)
  )
}
