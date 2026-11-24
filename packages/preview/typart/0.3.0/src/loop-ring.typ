// Loop ring: an open ellipse with an arrowhead around any content ("repeat", "continuous").
// Import with:  #import "loop-ring.typ": loop-ring
//
//   #loop-ring[Verification]
#import "common.typ": _lens, _loop, _put, _theme

#let loop-ring(body, inset: 0.4em, theme: (:), ..style) = context {
  let t = _theme("loop-ring", theme, style)
  let (inset,) = _lens("loop-ring", inset: inset).values()
  let m = measure(body)
  // the ellipse through the corners of the padded content box
  let (rx, ry) = ((m.width / 2 + inset) * calc.sqrt(2), (m.height / 2 + inset) * calc.sqrt(2))
  box(width: 2 * rx + t.thick, height: 2 * ry + t.thick, {
    _loop(rx + t.thick / 2, ry + t.thick / 2, rx, ry, t.accent, t.thick)
    _put(rx + t.thick / 2, ry + t.thick / 2, body, w: m.width + 1pt)
  })
}
