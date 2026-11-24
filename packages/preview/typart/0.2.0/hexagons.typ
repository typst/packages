// Hexagons: a zig-zag honeycomb strip.  Import with:  #import "hexagons.typ": hexagons
//
//   #hexagons(([Idea], [Design], ([Build], rgb("#e64553")), [Launch]))
#import "common.typ": _col, _fit, _in-circle, _lab, _polar, _poly, _put, _txt, _u

#let hexagons(
  items,
  r: 2,
  gap: 0.15,
  text-fill: white,
  size: 16pt,
) = context {
  let (r, gap) = (_u(r), _u(gap))
  let n = items.len()
  let half-h = r * calc.sqrt(3) / 2
  // flat-top hexagons; odd ones drop half a cell so the edges nest
  let dx = r * 1.5 + gap * calc.sqrt(3) / 2
  let dy = half-h + gap / 2
  let s = _fit(items.map(_lab), text-fill, size, r * 1.5, _in-circle(r * 0.866 - 0.1cm))
  box(width: (n - 1) * dx + 2 * r, height: 2 * half-h + (if n > 1 { dy } else { 0pt }), {
    for (i, it) in items.enumerate() {
      let cx = r + i * dx
      let cy = half-h + (if calc.odd(i) { dy } else { 0pt })
      _poly(fill: _col(it, i), ..range(6).map(k => _polar(cx, cy, r, k * 60deg)))
      _put(cx, cy, _txt(_lab(it), text-fill, s), w: r * 1.5)
    }
  })
}
