// Cycle: nodes on a ring joined by curved arrows.  Import with:  #import "cycle.typ": cycle
//
//   #cycle(([Plan], [Do], [Check], ([Act], red)))
#import "common.typ": _arc, _canvas, _dot, _fit, _head, _in-circle, _items, _lens, _on, _polar, _put, _theme, _txt

#let cycle(
  items,
  radius: auto,
  node-radius: 2.4em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("cycle", theme, style)
  let items = _items("cycle", items, t.palette)
  let (node, size, em) = _lens("cycle", node-radius: node-radius, text-size: text-size, em: 1em).values()
  let n = items.len()
  let head = t.thick * 3.6
  // neighbours must leave room for an arrow between them (radius is a minimum)
  let r = calc.max(if radius == auto { calc.max(4.5, n * 1.4) * em } else { _lens("cycle", radius: radius).radius },
    if n > 1 { (node + 0.8 * em) / calc.sin(180deg / n) } else { 0pt })
  let ang = i => 90deg - i * 360deg / n
  let gap = calc.min(calc.asin(node / r) + 7deg, 180deg / n - (head + 0.5 * em) / (2 * r) * 1rad)
  let w = 2 * node - 0.8 * em
  let s = _fit(items.map(it => it.label), t.ink, size, w, _in-circle(node - 0.25 * em))
  // reach in direction th: the farthest node, or the ring where an arrow crosses it
  let reach(th) = calc.max(
    ..range(n).map(i => r * calc.cos(ang(i) - th) + node),
    if n > 1 and range(n).all(i => calc.abs(calc.rem-euclid((ang(i) - th) / 1deg + 180, 360) - 180) * 1deg > gap) { r + t.thick / 2 } else { 0pt })
  let cx = reach(180deg)
  let cy = reach(90deg)
  _canvas("cycle", t, width, area, cx + reach(0deg), cy + reach(270deg), {
    for i in range(if n > 1 { n } else { 0 }) {
      let a0 = ang(i) - gap
      let a1 = ang(calc.rem(i + 1, n)) + gap
      if a1 > a0 { a1 -= 360deg }
      place(top + left, curve(stroke: t.accent + t.thick, curve.move(_polar(cx, cy, r, a0)),
        .._arc(cx, cy, r, a0, a1 + head * 0.8 / r * 1rad)))
      _head(_polar(cx, cy, r, a1 + head / r * 1rad), _polar(cx, cy, r, a1), t.accent, head / 2)
    }
    for (i, it) in items.enumerate() {
      let (x, y) = _polar(cx, cy, r, ang(i))
      _dot(shadow: t.shadow, x, y, node, fill: it.fill, stroke: t.surface + 0.12 * em)
      _put(x, y, _txt(it.label, _on(t, it.fill), s), w: w)
    }
  })
})
