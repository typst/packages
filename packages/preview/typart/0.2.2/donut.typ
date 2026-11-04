// Donut: a ring split into labelled segments (segmented cycle).
// Import with:  #import "donut.typ": donut
//
//   #donut(([Plan], [Build], [Test], ([Ship], rgb("#e64553"))), center: [Cycle])
#import "common.typ": _arc, _col, _fit, _in-circle, _lab, _polar, _put, _txt, _u

#let donut(
  items,
  center: none,
  radius: 5,
  thickness: 2.2,
  text-fill: white,
  center-fill: rgb("#1f1f3a"),
  size: 16pt,
) = context {
  let (r, t) = (_u(radius), _u(thickness))
  let n = items.len()
  let ri = r - t
  let rm = r - t / 2
  let sweep = 360deg / n
  // usable label width: the segment's chord at mid radius, capped by the ring thickness
  let w = calc.min(2 * rm * calc.sin(calc.min(sweep, 180deg) / 2) - 0.4cm, 2.4 * t)
  let mid = i => 90deg - (i + 0.5) * sweep
  // every corner of a label stays inside its ring segment
  let in-segment(i, lw, lh) = {
    let (px, py) = (rm * calc.cos(mid(i)), rm * calc.sin(mid(i)))
    let reach = calc.min(sweep, 180deg) / 2 - 2deg
    (-1, 1).all(sx => (-1, 1).all(sy => {
      let (x, y) = (px + sx * lw / 2, py + sy * lh / 2)
      let d = calc.norm(x / 1pt, y / 1pt) * 1pt
      let off = calc.abs(calc.rem-euclid((calc.atan2(x / 1pt, y / 1pt) - mid(i)) / 1deg + 180, 360) - 180) * 1deg
      d >= ri + 0.1cm and d <= r - 0.1cm and (n == 1 or off <= reach)
    }))
  }
  let s = _fit(items.map(_lab), text-fill, size, w, in-segment)
  box(width: 2 * r, height: 2 * r, {
    for (i, it) in items.enumerate() {
      let a0 = 90deg - i * sweep
      let a1 = a0 - sweep
      place(top + left, curve(fill: _col(it, i), stroke: white + 3pt,
        curve.move(_polar(r, r, r, a0)), .._arc(r, r, r, a0, a1),
        curve.line(_polar(r, r, ri, a1)), .._arc(r, r, ri, a1, a0), curve.close(mode: "straight")))
      let (x, y) = _polar(r, r, rm, mid(i))
      _put(x, y, _txt(_lab(it), text-fill, s), w: w)
    }
    if center != none {
      let cw = 2 * ri - 0.6cm
      _put(r, r, _txt(center, center-fill, _fit((center,), center-fill, size + 4pt, cw, _in-circle(ri - 0.2cm))), w: cw)
    }
  })
}
