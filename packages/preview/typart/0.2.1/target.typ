// Target: concentric rings, outermost first.  Import with:  #import "target.typ": target
//
//   #target(([Vision], [Mission], ([Goal], rgb("#e64553"))))
#import "common.typ": _col, _dot, _fit, _lab, _put, _txt, _u

#let target(
  items,
  radius: 5,
  text-fill: white,
  size: 16pt,
) = context {
  let n = items.len()
  let r = _u(radius)
  let band = r / n
  // label centre (as a fraction of r above the centre) and its slot inside the ring
  let ys = range(n).map(i => if i == n - 1 { 0 } else { (2 * (n - i) - 1) / (2 * n) })
  let ws = range(n).map(i => {
    let ro = (n - i) / n
    calc.max(1cm, 2 * r * calc.sqrt(calc.max(0.0004, ro * ro - ys.at(i) * ys.at(i))) - 0.4cm)
  })
  // a ring label stays between its two circles; the centre label inside the disc
  let in-ring(i, lw, lh) = {
    let (yc, ro) = (r * ys.at(i), band * (n - i))
    if i == n - 1 { return calc.norm(lw / 2pt, lh / 2pt) * 1pt <= ro - 0.15cm }
    calc.norm(lw / 2pt, (yc + lh / 2) / 1pt) * 1pt <= ro - 0.1cm and yc - lh / 2 >= ro - band + 0.1cm
  }
  let s = _fit(items.map(_lab), text-fill, size, ws, in-ring)
  box(width: 2 * r, height: 2 * r, {
    for (i, it) in items.enumerate() {
      _dot(r, r, band * (n - i), fill: _col(it, i), stroke: white + 2pt)
    }
    for (i, it) in items.enumerate() {
      _put(r, r * (1 - ys.at(i)), _txt(_lab(it), text-fill, s), w: ws.at(i))
    }
  })
}
