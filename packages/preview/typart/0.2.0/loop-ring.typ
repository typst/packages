// Loop ring: an open ellipse with an arrowhead around any content ("repeat", "continuous").
// Import with:  #import "loop-ring.typ": loop-ring
//
//   #loop-ring[Verification]
#import "common.typ": _loop, _put

#let loop-ring(body, stroke: 3pt + rgb("#a7dd9b"), inset: 6pt) = context {
  let st = std.stroke(stroke)
  let t = if st.thickness == auto { 1pt } else { st.thickness }
  let m = measure(body)
  // the ellipse through the corners of the padded content box
  let (rx, ry) = ((m.width / 2 + inset) * calc.sqrt(2), (m.height / 2 + inset) * calc.sqrt(2))
  box(width: 2 * rx + t, height: 2 * ry + t, {
    _loop(rx + t / 2, ry + t / 2, rx, ry, if st.paint == auto { black } else { st.paint }, t)
    _put(rx + t / 2, ry + t / 2, body, w: m.width + 1pt)
  })
}
