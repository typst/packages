//==============================================================================
// The Koch curve
//
// Public functions:
//     koch-curve, koch-snowflake
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate Koch curve
//
// iterations: [0, 6]
// axiom: "F"
// rule set:
//     "F" -> "F-F++F-F"
// angle: 60 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     fill: how to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let koch-curve(n, step-size: 10, fill: none, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 0 and n <= 6, message: "`n` should be in range [0, 6]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "F"
  let rule-set = ("F": "F-F++F-F")
  let dx = (step-size, step-size/2, -step-size/2, -step-size, -step-size/2, step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), step-size/2*calc.sqrt(3), 0, -step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))

  let s = axiom
  for i in range(n) {s = s.replace("F", rule-set.at("F"))}

  let dir = 0
  let cmd = ()
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 5}
    } else if c == "+" {
      dir += 1
      if (dir == 6) {dir = 0}
    } else if c == "F" {
      cmd.push(std.curve.line((dx.at(dir) * 1pt, dy.at(dir) * 1pt), relative: true))
    }
  }

  let x-min = 0pt
  let x-max = calc.pow(3, n) * step-size * 1pt
  let y-min = -calc.pow(3, n - 1) * calc.sqrt(3)/2 * step-size * 1pt
  let y-max = 0pt

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(fill: fill, stroke: stroke, ..cmd)
  )
}


// Generate Koch snowflake
//
// iterations: [0, 6]
// axiom: "F++F++F"
// rule set:
//     "F" -> "F-F++F-F"
// angle: 60 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     fill: how to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let koch-snowflake(n, step-size: 10, fill: none, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 0 and n <= 6, message: "`n` should be in range [0, 6]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "F++F++F"
  let rule-set = ("F": "F-F++F-F")
  let dx = (step-size, step-size/2, -step-size/2, -step-size, -step-size/2, step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), step-size/2*calc.sqrt(3), 0, -step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))

  let s = axiom
  for i in range(n) {s = s.replace("F", rule-set.at("F"))}

  let dir = 0
  let cmd = ()
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 5}
    } else if c == "+" {
      dir += 1
      if (dir == 6) {dir = 0}
    } else if c == "F" {
      cmd.push(std.curve.line((dx.at(dir) * 1pt, dy.at(dir) * 1pt), relative: true))
    }
  }
  cmd.push(std.curve.close())

  let x-min = 0pt
  let x-max = calc.pow(3, n) * step-size * 1pt
  let y-min = -calc.pow(3, n - 1) * calc.sqrt(3)/2 * step-size * 1pt
  let y-max = calc.pow(3, n - 1) * calc.sqrt(3)*3/2 * step-size * 1pt

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(fill: fill, stroke: stroke, ..cmd)
  )
}
