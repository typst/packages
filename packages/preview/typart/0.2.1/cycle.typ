// Cycle: nodes on a ring joined by curved arrows.  Import with:  #import "cycle.typ": cycle
//
//   #cycle(([Plan], [Do], [Check], ([Act], rgb("#e64553"))))
#import "common.typ": _arc, _col, _dot, _fit, _head, _in-circle, _lab, _polar, _put, _txt, _u

#let cycle(
  items,
  radius: auto,
  node: 1.5,
  arrow: rgb("#73c25a"),
  text-fill: white,
  size: 16pt,
) = context {
  let n = items.len()
  let node = _u(node)
  let head = 3pt * 2.6 + 3pt
  // neighbours must leave room for an arrow between them (radius is a minimum)
  let r = calc.max(_u(if radius == auto { calc.max(3, n * 0.9) } else { radius }),
    if n > 1 { (node + 0.5cm) / calc.sin(180deg / n) } else { 0pt })
  let ang = i => 90deg - i * 360deg / n
  let gap = calc.min(calc.asin(node / r) + 7deg, 180deg / n - (head + 0.3cm) / (2 * r) * 1rad)
  let w = 2 * node - 0.5cm
  let s = _fit(items.map(_lab), text-fill, size, w, _in-circle(node - 0.15cm))
  // reach in direction th: the farthest node, or the ring where an arrow crosses it
  let reach(th) = calc.max(
    ..range(n).map(i => r * calc.cos(ang(i) - th) + node),
    if n > 1 and range(n).all(i => calc.abs(calc.rem-euclid((ang(i) - th) / 1deg + 180, 360) - 180) * 1deg > gap) { r + 1.5pt } else { 0pt })
  let cx = reach(180deg)
  let cy = reach(90deg)
  box(width: cx + reach(0deg), height: cy + reach(270deg), {
    for i in range(if n > 1 { n } else { 0 }) {
      let a0 = ang(i) - gap
      let a1 = ang(calc.rem(i + 1, n)) + gap
      if a1 > a0 { a1 -= 360deg }
      place(top + left, curve(stroke: arrow + 3pt, curve.move(_polar(cx, cy, r, a0)),
        .._arc(cx, cy, r, a0, a1 + head * 0.8 / r * 1rad)))
      _head(_polar(cx, cy, r, a1 + head / r * 1rad), _polar(cx, cy, r, a1), arrow, head / 2)
    }
    for (i, it) in items.enumerate() {
      let (x, y) = _polar(cx, cy, r, ang(i))
      _dot(x, y, node, fill: _col(it, i), stroke: white + 2pt)
      _put(x, y, _txt(_lab(it), text-fill, s), w: w)
    }
  })
}
