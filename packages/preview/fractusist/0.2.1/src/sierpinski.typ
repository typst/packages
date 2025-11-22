//==============================================================================
// The Sierpiński curve
//
// Public functions:
//     sierpinski-curve, sierpinski-square-curve
//     sierpinski-arrowhead-curve
//     sierpinski-triangle
//==============================================================================


//----------------------------------------------------------
// Public functions
//----------------------------------------------------------

// Generate classic Sierpiński curve
//
// iterations: [0, 7]
// axiom: "F--XF--F--XF"
// rule set:
//     "X" -> "XF+G+XF--F--XF+G+X"
// angle: 45 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     fill: how to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-curve(n, step-size: 10, fill: none, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 0 and n <= 7, message: "`n` should be in range [0, 7]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "F--XF--F--XF"
  let rule-set = ("X": "XF+G+XF--F--XF+G+X")
  let fdx = (step-size, step-size/2*calc.sqrt(2), 0, -step-size/2*calc.sqrt(2), -step-size, -step-size/2*calc.sqrt(2), 0, step-size/2*calc.sqrt(2))
  let fdy = (0, step-size/2*calc.sqrt(2), step-size, step-size/2*calc.sqrt(2), 0, -step-size/2*calc.sqrt(2), -step-size, -step-size/2*calc.sqrt(2))
  let gdx = (step-size*calc.sqrt(2), step-size, 0, -step-size, -step-size*calc.sqrt(2), -step-size, 0, step-size)
  let gdy = (0, step-size, step-size*calc.sqrt(2), step-size, 0, -step-size, -step-size*calc.sqrt(2), -step-size)

  let s = axiom
  for i in range(n) {s = s.replace("X", rule-set.at("X"))}

  let dir = 7
  let cmd = ()
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 7}
    } else if c == "+" {
      dir += 1
      if (dir == 8) {dir = 0}
    } else if c == "F" {
      cmd.push(std.curve.line((fdx.at(dir) * 1pt, fdy.at(dir) * 1pt), relative: true))
    } else if c == "G" {
      cmd.push(std.curve.line((gdx.at(dir) * 1pt, gdy.at(dir) * 1pt), relative: true))
    }
  }
  cmd.push(std.curve.close())

  let x-min = (3/2 - calc.pow(2, n + 1)) * calc.sqrt(2) * step-size * 1pt
  let x-max = step-size / 2 * calc.sqrt(2) * 1pt
  let y-min = (1 - calc.pow(2, n + 1)) * calc.sqrt(2) * step-size * 1pt
  let y-max = 0pt

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(fill: fill, stroke: stroke, ..cmd)
  )
}


// Generate Sierpiński square curve
//
// iterations: [0, 7]
// axiom: "F+XF+F+XF"
// rule set:
//     "X" -> "XF-F+F-XF+F+XF-F+F-X"
// angle: 90 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     fill: how to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-square-curve(n, step-size: 10, fill: none, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 0 and n <= 7, message: "`n` should be in range [0, 7]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "F+XF+F+XF"
  let rule-set = ("X": "XF-F+F-XF+F+XF-F+F-X")
  let dx = (step-size, 0, -step-size, 0)
  let dy = (0, step-size, 0, -step-size)

  let s = axiom
  for i in range(n) {s = s.replace("X", rule-set.at("X"))}

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
  cmd.push(std.curve.close())

  let x-min = (2 - calc.pow(2, n + 1)) * step-size * 1pt
  let x-max = (calc.pow(2, n + 1) - 1) * step-size * 1pt
  let y-min = 0pt
  let y-max = (calc.pow(2, n + 2) - 3) * step-size * 1pt

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(fill: fill, stroke: stroke, ..cmd)
  )
}


// Generate Sierpiński arrowhead curve
//
// iterations: [0, 8]
// axiom: "XF"
// rule set:
//     "X" -> "YF+XF+Y"
//     "Y" -> "XF-YF-X"
// angle: 60 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-arrowhead-curve(n, step-size: 10, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 0 and n <= 8, message: "`n` should be in range [0, 8]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "XF"
  let rule-set = (X: "YF+XF+Y", Y: "XF-YF-X")
  let dx = (step-size, step-size/2, -step-size/2, -step-size, -step-size/2, step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), step-size/2*calc.sqrt(3), 0, -step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))

  let s = axiom
  for i in range(n) {s = s.replace(regex("X|Y"), x => rule-set.at(x.text))}

  let dir = if calc.even(n) {0} else {5}
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
  let x-max = calc.pow(2, n) * step-size * 1pt
  let y-min = (1 - calc.pow(2, n)) * calc.sqrt(3)/2 * step-size * 1pt
  let y-max = 0pt

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(stroke: stroke, ..cmd)
  )
}


// Generate 2D Sierpiński triangle
//
// iterations: [0, 6]
// axiom: "F-G-G"
// rule set:
//     "F" -> "F-G+F+G-F"
//     "G" -> "GG"
// angle: 120 deg
//
// Arguments:
//     n: the number of iterations
//     step-size: step size (in pt), optional
//     fill: how to fill the curve, optional
//     stroke: how to stroke the curve, optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-triangle(n, step-size: 10, fill: none, stroke: black + 1pt) = {
  assert(type(n) == int and n >= 0 and n <= 6, message: "`n` should be in range [0, 6]")
  assert(step-size > 0, message: "`step-size` should be positive")

  let axiom = "F-G-G"
  let rule-set = ("F": "F-G+F+G-F", "G": "GG")
  let dx = (step-size, -step-size/2, -step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))

  let s = axiom
  for i in range(n) {s = s.replace(regex("F|G"), x => rule-set.at(x.text))}

  let dir = 0
  let cmd = ()
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 2}
    } else if c == "+" {
      dir += 1
      if (dir == 3) {dir = 0}
    } else if c == "F" or c == "G" {
      cmd.push(std.curve.line((dx.at(dir) * 1pt, dy.at(dir) * 1pt), relative: true))
    }
  }
  cmd.push(std.curve.close())

  let x-min = 0pt
  let x-max = calc.pow(2, n) * step-size * 1pt
  let y-min = -calc.pow(2, n - 1) * calc.sqrt(3) * step-size * 1pt
  let y-max = 0pt

  cmd.insert(0, std.curve.move((-x-min, -y-min)))

  box(
    width: x-max - x-min, height: y-max - y-min,
    std.curve(fill: fill, stroke: stroke, ..cmd)
  )
}
