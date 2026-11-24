// Pyramid (or funnel) diagram.  Import with:  #import "pyramid.typ": pyramid
//
//   #pyramid((([Vision],), [Strategy], ([Tactics], rgb("#e64553"))))
//   #pyramid(([Top], [Middle], [Bottom]), flip: true)   // funnel
#import "common.typ": _col, _fit, _lab, _poly, _put, _txt, _u

#let pyramid(
  levels,
  width: 18,
  height: 12,
  text-fill: white,
  size: 22pt,
  gap: 0.18,
  flip: false,
) = context {
  let (width, height, gap) = (_u(width), _u(height), _u(gap))
  let n = levels.len()
  let cx = width / 2
  // half-width at depth y below the top edge
  let hw(y) = cx * (if flip { 1 - y / height } else { y / height })
  let band = height / n - gap
  let top(i) = height * i / n + (if i == 0 { 0pt } else { gap / 2 })
  // labels sit 32% of a band from its wide edge
  let label-y(i) = if flip { top(i) + band * 0.32 } else { top(i) + band * 0.68 }
  let ws = range(n).map(i => calc.max(1.2cm, 2 * hw(label-y(i)) - 0.6cm))
  // a label stays inside its trapezoid: checked at its narrow (pointed) side
  let in-band(i, lw, lh) = {
    let (yl, yt) = (label-y(i), top(i))
    let narrow = if flip { yl + lh / 2 } else { yl - lh / 2 }
    yl - lh / 2 >= yt + 0.05cm and yl + lh / 2 <= yt + band - 0.05cm and lw / 2 + 0.2cm <= hw(narrow)
  }
  let s = _fit(levels.map(_lab), text-fill, size, ws, in-band)
  box(width: width, height: height, {
    for (i, it) in levels.enumerate() {
      let (yt, yb) = (top(i), height * (i + 1) / n - gap / 2)
      _poly((cx - hw(yt), yt), (cx + hw(yt), yt), (cx + hw(yb), yb), (cx - hw(yb), yb),
        fill: _col(it, i), stroke: white + 2pt)
      _put(cx, label-y(i), _txt(_lab(it), text-fill, s), w: ws.at(i))
    }
  })
}
