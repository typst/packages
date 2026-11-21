// Radial: a centre joined by spokes to satellite circles.  Import with:  #import "radial.typ": radial
//
//   #radial([Goal], ([People], [Process], ([Tools], rgb("#e64553")), [Data]))
#import "common.typ": _col, _dot, _fit, _in-circle, _lab, _put, _txt, _u

#let radial(
  center,
  items,
  radius: auto,
  node: 1.4,
  core-r: 1.9,
  core-fill: rgb("#1f1f3a"),
  accent: luma(190),
  text-fill: white,
  size: 16pt,
) = context {
  let n = items.len()
  let (node, core-r) = (_u(node), _u(core-r))
  // satellites stay apart and clear of the centre (radius is a minimum)
  let r = calc.max(if radius == auto { 0pt } else { _u(radius) }, core-r + node + 0.9cm,
    (node + 0.35cm) / calc.sin(180deg / calc.max(n, 2)))
  let dirs = range(n).map(i => {
    let a = 90deg - i * 360deg / n
    (calc.cos(a), -calc.sin(a))
  })
  let reach(pick, sign) = calc.max(core-r, ..dirs.map(d => sign * r * pick(d) + node))
  let (x0, y0) = (reach(d => d.at(0), -1), reach(d => d.at(1), -1))
  let w = 2 * node - 0.4cm
  let s = _fit(items.map(_lab), text-fill, size, w, _in-circle(node - 0.15cm))
  let core-w = 2 * core-r - 0.4cm
  let core-s = _fit((center,), white, size + 2pt, core-w, _in-circle(core-r - 0.15cm))
  box(width: x0 + reach(d => d.at(0), 1), height: y0 + reach(d => d.at(1), 1), {
    for (ux, uy) in dirs {
      place(top + left, line(start: (x0, y0), end: (x0 + r * ux, y0 + r * uy), stroke: accent + 3pt))
    }
    _dot(x0, y0, core-r, fill: core-fill, stroke: white + 2pt)
    _put(x0, y0, _txt(center, white, core-s), w: core-w)
    for (i, it) in items.enumerate() {
      let (ux, uy) = dirs.at(i)
      _dot(x0 + r * ux, y0 + r * uy, node, fill: _col(it, i), stroke: white + 2pt)
      _put(x0 + r * ux, y0 + r * uy, _txt(_lab(it), text-fill, s), w: w)
    }
  })
}
