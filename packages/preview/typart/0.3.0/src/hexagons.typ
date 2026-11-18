// Hexagons: a zig-zag honeycomb strip.  Import with:  #import "hexagons.typ": hexagons
//
//   #hexagons(([Idea], [Design], ([Build], red), [Launch]))
#import "common.typ": _canvas, _fit, _in-circle, _items, _lens, _on, _polar, _poly, _put, _theme, _txt

#let hexagons(
  items,
  radius: 3.3em,
  gap: 0.25em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("hexagons", theme, style)
  let items = _items("hexagons", items, t.palette)
  let (r, gap, size, em) = _lens("hexagons", radius: radius, gap: gap, text-size: text-size, em: 1em).values()
  let n = items.len()
  let half-h = r * calc.sqrt(3) / 2
  // flat-top hexagons; odd ones drop half a cell so the edges nest
  let dx = r * 1.5 + gap * calc.sqrt(3) / 2
  let dy = half-h + gap / 2
  let s = _fit(items.map(it => it.label), t.ink, size, r * 1.5, _in-circle(r * 0.866 - 0.17 * em))
  _canvas("hexagons", t, width, area, (n - 1) * dx + 2 * r, 2 * half-h + (if n > 1 { dy } else { 0pt }), {
    for (i, it) in items.enumerate() {
      let cx = r + i * dx
      let cy = half-h + (if calc.odd(i) { dy } else { 0pt })
      _poly(shadow: t.shadow, fill: it.fill, ..range(6).map(k => _polar(cx, cy, r, k * 60deg)))
      _put(cx, cy, _txt(it.label, _on(t, it.fill), s), w: r * 1.5)
    }
  })
})
