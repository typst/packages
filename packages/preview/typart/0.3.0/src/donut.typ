// Donut: a ring split into labelled segments (segmented cycle).
// Import with:  #import "donut.typ": donut
//
//   #donut(([Plan], [Build], [Test], ([Ship], red)), center: [Cycle])
#import "common.typ": _arc, _canvas, _fit, _in-circle, _items, _lens, _on, _polar, _put, _theme, _txt

#let donut(
  items,
  center: none,
  radius: 8em,
  thickness: 3.5em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("donut", theme, style)
  let items = _items("donut", items, t.palette)
  let (r, th, size, em) = _lens("donut", radius: radius, thickness: thickness, text-size: text-size, em: 1em).values()
  let n = items.len()
  let ri = r - th
  let rm = r - th / 2
  let sweep = 360deg / n
  // usable label width: the segment's chord at mid radius, capped by the ring thickness
  let w = calc.min(2 * rm * calc.sin(calc.min(sweep, 180deg) / 2) - 0.65 * em, 2.4 * th)
  let mid = i => 90deg - (i + 0.5) * sweep
  // every corner of a label stays inside its ring segment
  let in-segment(i, lw, lh) = {
    let (px, py) = (rm * calc.cos(mid(i)), rm * calc.sin(mid(i)))
    let reach = calc.min(sweep, 180deg) / 2 - 2deg
    (-1, 1).all(sx => (-1, 1).all(sy => {
      let (x, y) = (px + sx * lw / 2, py + sy * lh / 2)
      let d = calc.norm(x / 1pt, y / 1pt) * 1pt
      let off = calc.abs(calc.rem-euclid((calc.atan2(x / 1pt, y / 1pt) - mid(i)) / 1deg + 180, 360) - 180) * 1deg
      d >= ri + 0.17 * em and d <= r - 0.17 * em and (n == 1 or off <= reach)
    }))
  }
  let s = _fit(items.map(it => it.label), t.ink, size, w, in-segment)
  _canvas("donut", t, width, area, 2 * r, 2 * r, {
    for (i, it) in items.enumerate() {
      let a0 = 90deg - i * sweep
      let a1 = a0 - sweep
      place(top + left, curve(fill: it.fill, stroke: t.surface + 0.18 * em,
        curve.move(_polar(r, r, r, a0)), .._arc(r, r, r, a0, a1),
        curve.line(_polar(r, r, ri, a1)), .._arc(r, r, ri, a1, a0), curve.close(mode: "straight")))
      let (x, y) = _polar(r, r, rm, mid(i))
      _put(x, y, _txt(it.label, _on(t, it.fill), s), w: w)
    }
    if center != none {
      let cw = 2 * ri - em
      _put(r, r, _txt(center, t.ink, _fit((center,), t.ink, size * t.large, cw, _in-circle(ri - 0.33 * em))), w: cw)
    }
  })
})
