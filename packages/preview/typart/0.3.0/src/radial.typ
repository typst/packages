// Radial: a centre joined by spokes to satellite circles.  Import with:  #import "radial.typ": radial
//
//   #radial([Goal], ([People], [Process], ([Tools], red), [Data]))
#import "common.typ": _canvas, _dot, _fit, _in-circle, _items, _lens, _on, _or, _put, _theme, _txt

#let radial(
  center,
  items,
  radius: auto,
  node-radius: 2.3em,
  core-radius: 3em,
  core-fill: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("radial", theme, style)
  let items = _items("radial", items, t.palette)
  let (node, core, size, em) = _lens("radial", node-radius: node-radius, core-radius: core-radius,
    text-size: text-size, em: 1em).values()
  let n = items.len()
  // satellites stay apart and clear of the centre (radius is a minimum)
  let r = calc.max(if radius == auto { 0pt } else { _lens("radial", radius: radius).radius }, core + node + 1.5 * em,
    (node + 0.6 * em) / calc.sin(180deg / calc.max(n, 2)))
  let dirs = range(n).map(i => {
    let a = 90deg - i * 360deg / n
    (calc.cos(a), -calc.sin(a))
  })
  let reach(pick, sign) = calc.max(core, ..dirs.map(d => sign * r * pick(d) + node))
  let (x0, y0) = (reach(d => d.at(0), -1), reach(d => d.at(1), -1))
  let w = 2 * node - 0.65 * em
  let s = _fit(items.map(it => it.label), t.ink, size, w, _in-circle(node - 0.25 * em))
  let core-w = 2 * core - 0.65 * em
  let core-s = _fit((center,), t.ink, size, core-w, _in-circle(core - 0.25 * em))
  _canvas("radial", t, width, area, x0 + reach(d => d.at(0), 1), y0 + reach(d => d.at(1), 1), {
    for (ux, uy) in dirs {
      place(top + left, line(start: (x0, y0), end: (x0 + r * ux, y0 + r * uy), stroke: t.accent + t.thick))
    }
    _dot(shadow: t.shadow, x0, y0, core, fill: _or(core-fill, t.line), stroke: t.surface + 0.12 * em)
    _put(x0, y0, _txt(center, _on(t, _or(core-fill, t.line)), core-s), w: core-w)
    for (it, (ux, uy)) in items.zip(dirs) {
      _dot(shadow: t.shadow, x0 + r * ux, y0 + r * uy, node, fill: it.fill, stroke: t.surface + 0.12 * em)
      _put(x0 + r * ux, y0 + r * uy, _txt(it.label, _on(t, it.fill), s), w: w)
    }
  })
})
