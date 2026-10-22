// Stairs: ascending step-up process.  Import with:  #import "stairs.typ": stairs
//
//   #stairs(([Plan], [Develop], ([Launch], rgb("#e64553"))))
#import "common.typ": _arrow, _col, _label, _node, _tallest, _u

#let stairs(
  items,
  w: 3.4, h: 1.7, dx: 3.6, dy: 1.9,
  accent: luma(130),
  text-fill: white, size: 16pt, radius: 0.15,
) = context {
  let w = _u(w)
  let labels = items.map(it => _label(it, text-fill, size))
  let h = calc.max(_u(h), _tallest(labels, w - 0.5cm) + 0.8cm)
  // steps never overlap and the elbow arrows always have room
  let dx = calc.max(_u(dx), w / 2 + 0.6cm)
  let dy = calc.max(_u(dy), h + 0.2cm)
  let n = items.len()
  let c = i => (i * dx + w / 2, (n - 1 - i) * dy + h / 2)
  box(width: (n - 1) * dx + w, height: (n - 1) * dy + h, {
    for i in range(n - 1) {
      let (ax, ay) = c(i)
      let (bx, by) = c(i + 1)
      // elbow from the top of a step to the side of the next one
      _arrow((ax, ay - h / 2), (ax, by), (bx - w / 2, by), paint: accent, thickness: 3pt)
    }
    for (i, it) in items.enumerate() {
      let (x, y) = c(i)
      _node(x, y, w, h, labels.at(i), fill: _col(it, i), radius: _u(radius), inset: 0.25cm)
    }
  })
}
