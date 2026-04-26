//==============================================================================
// Utilities for SVG code generation
//==============================================================================


// SVG template strings
#let SVG-HEADER = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"WIDTH\" height=\"HEIGHT\">\n"
#let SVG-TAIL = "</svg>\n"
#let SVG-DEFS = "<defs>\nDEFS</defs>\n"
#let SVG-PATH = "<path\nstyle=\"STYLE\" transform=\"TRANSFORM\" d=\"PATHD\"\n/>\n"


// Generate linear gradient code
#let gen-svg-lineargradient(grad, id) = {
  let t = calc.rem-euclid(grad.angle().deg(), 360)
  let t2 = calc.rem-euclid(t, 90)
  if t2 > 45 {t2 = 90 - t2}
  let k = 0.5 / calc.cos(t2 * 1deg)
  let x1 = 0.5 - k * calc.cos(t * 1deg)
  let y1 = 0.5 - k * calc.sin(t * 1deg)
  let x2 = 1 - x1
  let y2 = 1 - y1

  let s = "<linearGradient id=\"ID\" x1=\"X1\" y1=\"Y1\" x2=\"X2\" y2=\"Y2\">".replace("ID", id).replace("X1", repr(x1)).replace("Y1", repr(y1)).replace("X2", repr(x2)).replace("Y2", repr(y2))
  for (c, r) in grad.stops() {
    s += "<stop offset=\"RATIO\" stop-color=\"COLOR\"/>".replace("RATIO", repr(r)).replace("COLOR", c.to-hex())
  }
  s += "</linearGradient>\n"
  return s
}


// Generate radial gradient code
#let gen-svg-radialgradient(grad, id) = {
  let cx = 0.5
  let cy = 0.5
  let r = 0.5
  let fx = 0.5
  let fy = 0.5

  let cxy-match = repr(grad).match(regex("[^-]center:\s\(([\.\d]*)%,\s([\.\d]*)%\)"))
  if cxy-match != none {
    cx = float(cxy-match.captures.at(0)) / 100
    cy = float(cxy-match.captures.at(1)) / 100
  }

  let r-match = repr(grad).match(regex("[^-]radius:\s([\.\d]*)%"))
  if r-match != none {
    r = float(r-match.captures.at(0)) / 100
  }

  let fxy-match = repr(grad).match(regex("focal-center:\s\(([\.\d]*)%,\s([\.\d]*)%\)"))
  if fxy-match != none {
    fx = float(fxy-match.captures.at(0)) / 100
    fy = float(fxy-match.captures.at(1)) / 100
  }

  let s = "<radialGradient id=\"ID\" cx=\"CX\" cy=\"CY\" r=\"R\" fx=\"FX\" fy=\"FY\">".replace("ID", id).replace("CX", repr(cx)).replace("CY", repr(cy)).replace("R", repr(r)).replace("FX", repr(fx)).replace("FY", repr(fy))
  for (c, r) in grad.stops() {
    s += "<stop offset=\"RATIO\" stop-color=\"COLOR\"/>".replace("RATIO", repr(r)).replace("COLOR", c.to-hex())
  }
  s += "</radialGradient>\n"
  return s
}


// Generate full code
#let gen-svg(path-d, bbox, fill-style, stroke-style) = {
  let stroke-color = if (stroke-style == none) {none} else if (stroke-style.paint == auto) {black} else {stroke-style.paint}
  let stroke-width = if (stroke-style == none) {none} else if (stroke-style.thickness == auto) {1} else {calc.abs(stroke-style.thickness.pt())}
  let stroke-linecap = if (stroke-style == none or stroke-style.cap == auto) {none} else {stroke-style.cap}
  let stroke-linejoin = if (stroke-style == none or stroke-style.join == auto) {none} else {stroke-style.join}
  let stroke-miterlimit = if (stroke-style == none or stroke-style.miter-limit == auto) {none} else {stroke-style.miter-limit}

  let fill-color-str = "none"
  let stroke-color-str = "none"
  let grad-str = ""

  if type(fill-style) == color {
    fill-color-str = fill-style.to-hex()
  } else if type(fill-style) == gradient and repr(fill-style.kind()) == "linear" {
    grad-str += gen-svg-lineargradient(fill-style, "GradFill")
    fill-color-str = "url(#GradFill)"
  } else if type(fill-style) == gradient and repr(fill-style.kind()) == "radial" {
    grad-str += gen-svg-radialgradient(fill-style, "GradFill")
    fill-color-str = "url(#GradFill)"
  }

  if type(stroke-color) == color {
    stroke-color-str = stroke-color.to-hex()
  } else if type(stroke-color) == gradient and repr(stroke-color.kind()) == "linear" {
    grad-str += gen-svg-lineargradient(stroke-color, "GradStroke")
    stroke-color-str = "url(#GradStroke)"
  } else if type(stroke-color) == gradient and repr(stroke-color.kind()) == "radial" {
    grad-str += gen-svg-radialgradient(stroke-color, "GradStroke")
    stroke-color-str = "url(#GradStroke)"
  }

  let path-style = "fill:" + fill-color-str + ";stroke:" + stroke-color-str + ";stroke-width:" + repr(stroke-width)
  if stroke-linecap != none {path-style += ";stroke-linecap:" + stroke-linecap}
  if stroke-linejoin != none {path-style += ";stroke-linejoin:" + stroke-linejoin}
  if stroke-miterlimit != none {path-style += ";stroke-miterlimit:" + repr(stroke-linejoin)}

  let path-transform = "translate" + repr((-bbox.at(0), -bbox.at(2)))

  let s = SVG-HEADER.replace("WIDTH", repr(bbox.at(1) - bbox.at(0))).replace("HEIGHT", repr(bbox.at(3) - bbox.at(2)))
  if grad-str != "" {s += SVG-DEFS.replace("DEFS", grad-str)}
  s += SVG-PATH.replace("STYLE", path-style).replace("TRANSFORM", path-transform).replace("PATHD", path-d)
  s += SVG-TAIL
  return s
}
