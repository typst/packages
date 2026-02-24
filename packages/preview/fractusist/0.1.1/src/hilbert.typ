//==============================================================================
// The Hilbert curve
//
// Public functions:
//     hilbert-curve, peano-curve
//==============================================================================


#import "util.typ": gen-svg


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
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let hilbert-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 1 and n <= 8, message: "`n` should be in range [1, 8]")
  assert(step-size > 0, message: "`step-size` should be positive")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "W"
  let rule-set = (V: "-WF+VFV+FW-", W: "+VF-WFW-FV+")
  let dx = (step-size, 0, -step-size, 0)
  let dy = (0, step-size, 0, -step-size)
  let dx-str = dx.map(i => repr(i))
  let dy-str = dy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace(regex("V|W"), x => rule-set.at(x.text))}

  let dir = 0
  let path-d = "M0 0 "
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 3}
    } else if c == "+" {
      dir += 1
      if (dir == 4) {dir = 0}
    } else if c == "F" {
      path-d += "l" + dx-str.at(dir) + " " + dy-str.at(dir) + " "
    }
  }

  let margin = calc.max(5, stroke-width)
  let x-min = 0
  let x-max = (calc.pow(2, n) - 1) * step-size
  let y-min = 0
  let y-max = x-max
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), none, stroke-style)
  return image(bytes(svg-code), width: width, height: height, fit: fit)
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
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let peano-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 1 and n <= 5, message: "`n` should be in range [1, 5]")
  assert(step-size > 0, message: "`step-size` should be positive")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "X"
  let rule-set = (X: "XFYFX+F+YFXFY-F-XFYFX", Y: "YFXFY-F-XFYFX+F+YFXFY")
  let dx = (step-size, 0, -step-size, 0)
  let dy = (0, step-size, 0, -step-size)
  let dx-str = dx.map(i => repr(i))
  let dy-str = dy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace(regex("X|Y"), x => rule-set.at(x.text))}

  let dir = 0
  let path-d = "M0 0 "
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 3}
    } else if c == "+" {
      dir += 1
      if (dir == 4) {dir = 0}
    } else if c == "F" {
      path-d += "l" + dx-str.at(dir) + " " + dy-str.at(dir) + " "
    }
  }

  let margin = calc.max(5, stroke-width)
  let x-min = 0
  let x-max = (calc.pow(3, n) - 1) * step-size
  let y-min = 0
  let y-max = x-max
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), none, stroke-style)
  return image(bytes(svg-code), width: width, height: height, fit: fit)
}
