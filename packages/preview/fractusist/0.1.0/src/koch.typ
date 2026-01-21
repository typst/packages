//==============================================================================
// The Koch curve
//
// Public functions:
//     koch-curve, koch-snowflake
//==============================================================================


#import "util.typ": gen-svg


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
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let koch-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 0 and n <= 6, message: "`n` should be in range [0, 6]")
  assert(step-size > 0, message: "`step-size` should be positive")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "F"
  let rule-set = ("F": "F-F++F-F")
  let dx = (step-size, step-size/2, -step-size/2, -step-size, -step-size/2, step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), step-size/2*calc.sqrt(3), 0, -step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))
  let dx-str = dx.map(i => repr(i))
  let dy-str = dy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace("F", rule-set.at("F"))}

  let dir = 0
  let path-d = "M0 0 "
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 5}
    } else if c == "+" {
      dir += 1
      if (dir == 6) {dir = 0}
    } else if c == "F" {
      path-d += "l" + dx-str.at(dir) + " " + dy-str.at(dir) + " "
    }
  }

  let margin = calc.max(5, stroke-width * 1.5)
  let x-min = 0
  let x-max = calc.pow(3, n) * step-size
  let y-min = -calc.pow(3, n - 1) * calc.sqrt(3)/2 * step-size
  let y-max = 0
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), none, stroke-style)
  return image.decode(svg-code, width: width, height: height, fit: fit)
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
//     fill-style: fill style, can be none or color or gradient, optional
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let koch-snowflake(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 0 and n <= 6, message: "`n` should be in range [0, 6]")
  assert(step-size > 0, message: "`step-size` should be positive")
  assert((fill-style == none) or (type(fill-style) == color) or (type(fill-style) == gradient and (repr(fill-style.kind()) == "linear" or repr(fill-style.kind()) == "radial")), message: "`fill-style` should be none / color / gradient.linear / gradient.radial")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "F++F++F"
  let rule-set = ("F": "F-F++F-F")
  let dx = (step-size, step-size/2, -step-size/2, -step-size, -step-size/2, step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), step-size/2*calc.sqrt(3), 0, -step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))
  let dx-str = dx.map(i => repr(i))
  let dy-str = dy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace("F", rule-set.at("F"))}

  let dir = 0
  let path-d = "M0 0 "
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 5}
    } else if c == "+" {
      dir += 1
      if (dir == 6) {dir = 0}
    } else if c == "F" {
      path-d += "l" + dx-str.at(dir) + " " + dy-str.at(dir) + " "
    }
  }
  path-d += "Z"

  let margin = calc.max(5, stroke-width * 1.5)
  let x-min = 0
  let x-max = calc.pow(3, n) * step-size
  let y-min = -calc.pow(3, n - 1) * calc.sqrt(3)/2 * step-size
  let y-max = calc.pow(3, n - 1) * calc.sqrt(3)*3/2 * step-size
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), fill-style, stroke-style)
  return image.decode(svg-code, width: width, height: height, fit: fit)
}
