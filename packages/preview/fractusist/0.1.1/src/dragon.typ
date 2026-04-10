//==============================================================================
// The dragon curve
//
// Public functions:
//     dragon-curve
//==============================================================================


#import "util.typ": gen-svg


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
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let dragon-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 0 and n <= 16, message: "`n` should be in range [0, 16]")
  assert(step-size > 0, message: "`step-size` should be positive")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "FX"
  let rule-set = (X: "X+YF+", Y: "-FX-Y")
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

  let tbl-x-min = (0, 0, 0, -2, -4, -5, -5, -5, -5, -5, -10, -42, -74, -85, -85, -85, -85)
  let tbl-x-max = (0, 1, 1, 1, 1, 1, 2, 10, 18, 21, 21, 21, 21, 21, 42, 170, 298)
  let tbl-y-min = (0, 0, 0, 0, -1, -5, -9, -10, -10, -10, -10, -10, -21, -85, -149, -170, -170)
  let tbl-y-max = (0, 1, 2, 2, 2, 2, 2, 2, 5, 21, 37, 42, 42, 42, 42, 42, 85)
  let margin = calc.max(5, stroke-width)
  let x-min = tbl-x-min.at(n) * step-size
  let x-max = tbl-x-max.at(n) * step-size
  let y-min = tbl-y-min.at(n) * step-size
  let y-max = tbl-y-max.at(n) * step-size
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), none, stroke-style)
  return image(bytes(svg-code), width: width, height: height, fit: fit)
}
