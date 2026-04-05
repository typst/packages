//==============================================================================
// The Hilbert curve
//
// Public functions:
//     hilbert-curve, peano-curve
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate 2D Hilbert curve
//
// iterations: [1, 8]
// axiom: "W"
// rule set:
//     "V" -> "-WF+VFV+FW-"
//     "W" -> "+VF-WFW-FV+"
// angle: 90 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let hilbert-curve(n, step-size: 10, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 1 and n <= 8, message: "`n` should be in range [1, 8]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "W"
  let rule-set = (V: "-WF+VFV+FW-", W: "+VF-WFW-FV+")
  let dx = (step-size, 0, -step-size, 0)
  let dy = (0, step-size, 0, -step-size)

  let s = axiom
  for i in range(n) {s = s.replace(regex("V|W"), x => rule-set.at(x.text))}

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

  let x-min = 0pt
  let x-max = (calc.pow(2, n) - 1) * step-size * 1pt
  let y-min = 0pt
  let y-max = x-max

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(stroke: stroke, ..cmd)
  )
}


// Generate 2D Peano curve (Hilbert II curve)
//
// iterations: [1, 5]
// axiom: "X"
// rule set:
//     "X" -> "XFYFX+F+YFXFY-F-XFYFX"
//     "Y" -> "YFXFY-F-XFYFX+F+YFXFY"
// angle: 90 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let peano-curve(n, step-size: 10, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 1 and n <= 5, message: "`n` should be in range [1, 5]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "X"
  let rule-set = (X: "XFYFX+F+YFXFY-F-XFYFX", Y: "YFXFY-F-XFYFX+F+YFXFY")
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

  let x-min = 0pt
  let x-max = (calc.pow(3, n) - 1) * step-size * 1pt
  let y-min = 0pt
  let y-max = x-max

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(stroke: stroke, ..cmd)
  )
}
