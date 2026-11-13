// Gears: up to 3 interlocking cogs.  Import with:  #import "gears.typ": gears
//
//   #gears(([Research], [Development], ([Production], rgb("#e64553"))))
#import "common.typ": _col, _fit, _in-circle, _lab, _polar, _poly, _put, _txt, _u

#let gears(
  items,
  r: 2.6, teeth: 10,
  text-fill: rgb("#1f1f3a"), size: 15pt,
) = context {
  let r = _u(r)
  let n = calc.min(items.len(), 3)
  let d = r * 1.8
  let step = 360deg / teeth
  let cog(cx, fill, phase) = _poly(fill: fill, ..range(teeth).map(t => {
    let a = phase + t * step
    (
      _polar(cx, r, r * 0.8, a),
      _polar(cx, r, r, a + step * 0.25),
      _polar(cx, r, r, a + step * 0.5),
      _polar(cx, r, r * 0.8, a + step * 0.75),
    )
  }).join())
  let items = items.slice(0, n)
  let s = _fit(items.map(_lab), text-fill, size, r * 1.4, _in-circle(r * 0.8 - 0.1cm))
  box(width: (n - 1) * d + 2 * r, height: 2 * r, {
    for (i, it) in items.enumerate() {
      let cx = r + i * d
      // a gap of one cog faces a tooth of the next at the contact point
      cog(cx, _col(it, i), if calc.even(i) { 0deg } else { 180deg - step / 4 })
      _put(cx, r, _txt(_lab(it), text-fill, s), w: r * 1.4)
    }
  })
}
