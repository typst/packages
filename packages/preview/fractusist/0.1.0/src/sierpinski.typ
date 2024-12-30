//==============================================================================
// The Sierpiński curve
//
// Public functions:
//     sierpinski-curve, sierpinski-square-curve
//     sierpinski-arrowhead-curve
//     sierpinski-triangle
//==============================================================================


#import "util.typ": gen-svg


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
//     fill-style: fill style, can be none or color or gradient, optional
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-curve(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 0 and n <= 7, message: "`n` should be in range [0, 7]")
  assert(step-size > 0, message: "`step-size` should be positive")
  assert((fill-style == none) or (type(fill-style) == color) or (type(fill-style) == gradient and (repr(fill-style.kind()) == "linear" or repr(fill-style.kind()) == "radial")), message: "`fill-style` should be none / color / gradient.linear / gradient.radial")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "F--XF--F--XF"
  let rule-set = ("X": "XF+G+XF--F--XF+G+X")
  let fdx = (step-size, step-size/2*calc.sqrt(2), 0, -step-size/2*calc.sqrt(2), -step-size, -step-size/2*calc.sqrt(2), 0, step-size/2*calc.sqrt(2))
  let fdy = (0, step-size/2*calc.sqrt(2), step-size, step-size/2*calc.sqrt(2), 0, -step-size/2*calc.sqrt(2), -step-size, -step-size/2*calc.sqrt(2))
  let gdx = (step-size*calc.sqrt(2), step-size, 0, -step-size, -step-size*calc.sqrt(2), -step-size, 0, step-size)
  let gdy = (0, step-size, step-size*calc.sqrt(2), step-size, 0, -step-size, -step-size*calc.sqrt(2), -step-size)
  let fdx-str = fdx.map(i => repr(i))
  let fdy-str = fdy.map(i => repr(i))
  let gdx-str = gdx.map(i => repr(i))
  let gdy-str = gdy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace("X", rule-set.at("X"))}

  let dir = 7
  let path-d = "M0 0 "
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 7}
    } else if c == "+" {
      dir += 1
      if (dir == 8) {dir = 0}
    } else if c == "F" {
      path-d += "l" + fdx-str.at(dir) + " " + fdy-str.at(dir) + " "
    } else if c == "G" {
      path-d += "l" + gdx-str.at(dir) + " " + gdy-str.at(dir) + " "
    }
  }
  path-d += "Z"

  let margin = calc.max(5, stroke-width * 1.5)
  let x-min = (3/2 - calc.pow(2, n + 1)) * calc.sqrt(2) * step-size
  let x-max = step-size / 2 * calc.sqrt(2)
  let y-min = (1 - calc.pow(2, n + 1)) * calc.sqrt(2) * step-size
  let y-max = 0
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), fill-style, stroke-style)
  return image.decode(svg-code, width: width, height: height, fit: fit)
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
//     fill-style: fill style, can be none or color or gradient, optional
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-square-curve(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 0 and n <= 7, message: "`n` should be in range [0, 7]")
  assert(step-size > 0, message: "`step-size` should be positive")
  assert((fill-style == none) or (type(fill-style) == color) or (type(fill-style) == gradient and (repr(fill-style.kind()) == "linear" or repr(fill-style.kind()) == "radial")), message: "`fill-style` should be none / color / gradient.linear / gradient.radial")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "F+XF+F+XF"
  let rule-set = ("X": "XF-F+F-XF+F+XF-F+F-X")
  let dx = (step-size, 0, -step-size, 0)
  let dy = (0, step-size, 0, -step-size)
  let dx-str = dx.map(i => repr(i))
  let dy-str = dy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace("X", rule-set.at("X"))}

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
  path-d += "Z"

  let margin = calc.max(5, stroke-width)
  let x-min = (2 - calc.pow(2, n + 1)) * step-size
  let x-max = (calc.pow(2, n + 1) - 1) * step-size
  let y-min = 0
  let y-max = (calc.pow(2, n + 2) - 3) * step-size
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), fill-style, stroke-style)
  return image.decode(svg-code, width: width, height: height, fit: fit)
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
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-arrowhead-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 0 and n <= 8, message: "`n` should be in range [0, 8]")
  assert(step-size > 0, message: "`step-size` should be positive")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "XF"
  let rule-set = (X: "YF+XF+Y", Y: "XF-YF-X")
  let dx = (step-size, step-size/2, -step-size/2, -step-size, -step-size/2, step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), step-size/2*calc.sqrt(3), 0, -step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))
  let dx-str = dx.map(i => repr(i))
  let dy-str = dy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace(regex("X|Y"), x => rule-set.at(x.text))}


  let dir = if calc.even(n) {0} else {5}
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
  let x-max = calc.pow(2, n) * step-size
  let y-min = (1 - calc.pow(2, n)) * calc.sqrt(3)/2 * step-size
  let y-max = 0
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), none, stroke-style)
  return image.decode(svg-code, width: width, height: height, fit: fit)
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
//     fill-style: fill style, can be none or color or gradient, optional
//     stroke-style: stroke style, can be none or color or gradient or stroke object, optional
//     width: the width of the image, optional
//     height: the height of the image, optional
//     fit: how the image should adjust itself to a given area, "cover" / "contain" / "stretch", optional
//
// Returns:
//     content: generated vector graphic
#let sierpinski-triangle(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {
  assert(type(n) == int and n >= 0 and n <= 6, message: "`n` should be in range [0, 6]")
  assert(step-size > 0, message: "`step-size` should be positive")
  assert((fill-style == none) or (type(fill-style) == color) or (type(fill-style) == gradient and (repr(fill-style.kind()) == "linear" or repr(fill-style.kind()) == "radial")), message: "`fill-style` should be none / color / gradient.linear / gradient.radial")

  if stroke-style != none {stroke-style = stroke(stroke-style)}
  let stroke-width = if (stroke-style == none) {0} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}

  let axiom = "F-G-G"
  let rule-set = ("F": "F-G+F+G-F", "G": "GG")
  let dx = (step-size, -step-size/2, -step-size/2)
  let dy = (0, step-size/2*calc.sqrt(3), -step-size/2*calc.sqrt(3))
  let dx-str = dx.map(i => repr(i))
  let dy-str = dy.map(i => repr(i))

  let s = axiom
  for i in range(n) {s = s.replace(regex("F|G"), x => rule-set.at(x.text))}


  let dir = 0
  let path-d = "M0 0 "
  for c in s {
    if c == "-" {
      dir -= 1
      if dir < 0 {dir = 2}
    } else if c == "+" {
      dir += 1
      if (dir == 3) {dir = 0}
    } else if c == "F" or c == "G" {
      path-d += "l" + dx-str.at(dir) + " " + dy-str.at(dir) + " "
    }
  }
  path-d += "Z"

  let margin = calc.max(5, stroke-width)
  let x-min = 0
  let x-max = calc.pow(2, n) * step-size
  let y-min = -calc.pow(2, n - 1) * calc.sqrt(3) * step-size
  let y-max = 0
  x-min = calc.floor(x-min - margin)
  x-max = calc.ceil(x-max + margin)
  y-min = calc.floor(y-min - margin)
  y-max = calc.ceil(y-max + margin)

  let svg-code = gen-svg(path-d, (x-min, x-max, y-min, y-max), fill-style, stroke-style)
  return image.decode(svg-code, width: width, height: height, fit: fit)
}
