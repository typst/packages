// Gears: up to 3 interlocking cogs.  Import with:  #import "gears.typ": gears
//
//   #gears(([Research], [Development], ([Production], red)))
#import "common.typ": _canvas, _fit, _in-circle, _items, _lens, _on, _polar, _poly, _put, _theme, _txt

#let gears(
  items,
  radius: 4.2em,
  teeth: 10,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("gears", theme, style)
  let items = _items("gears", items, t.palette, max: 3)
  let (r, size, em) = _lens("gears", radius: radius, text-size: text-size, em: 1em).values()
  let n = items.len()
  let d = r * 1.8
  let step = 360deg / teeth
  let cog(cx, fill, phase) = _poly(shadow: t.shadow, fill: fill, ..range(teeth).map(k => {
    let a = phase + k * step
    (
      _polar(cx, r, r * 0.8, a),
      _polar(cx, r, r, a + step * 0.25),
      _polar(cx, r, r, a + step * 0.5),
      _polar(cx, r, r * 0.8, a + step * 0.75),
    )
  }).join())
  let s = _fit(items.map(it => it.label), t.ink, size, r * 1.4, _in-circle(r * 0.8 - 0.17 * em))
  _canvas("gears", t, width, area, (n - 1) * d + 2 * r, 2 * r, {
    for (i, it) in items.enumerate() {
      let cx = r + i * d
      // a gap of one cog faces a tooth of the next at the contact point
      cog(cx, it.fill, if calc.even(i) { 0deg } else { 180deg - step / 4 })
      _put(cx, r, _txt(it.label, _on(t, it.fill), s), w: r * 1.4)
    }
  })
})
