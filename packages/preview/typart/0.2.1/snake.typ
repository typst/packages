// Snake: bending process that wraps into rows.  Import with:  #import "snake.typ": snake
//
//   #snake(([Step 1], [Step 2], [Step 3], [Step 4], [Step 5], [Step 6]))
#import "common.typ": _arrow, _col, _label, _node, _tallest, _u

#let snake(
  items,
  cols: 4,
  w: 4.5, h: 2.2, gx: 1.4, gy: 1.4,
  accent: rgb("#73c25a"),
  text-fill: white, size: 16pt, radius: 0.15,
) = context {
  let (w, gx, gy) = (_u(w), _u(gx), _u(gy))
  let labels = items.map(it => _label(it, text-fill, size))
  let h = calc.max(_u(h), _tallest(labels, w - 0.6cm) + 0.8cm)
  let n = items.len()
  let rows = calc.quo(n - 1, cols) + 1
  let pos = i => {
    let row = calc.quo(i, cols)
    let inrow = calc.rem(i, cols)
    let col = if calc.even(row) { inrow } else { cols - 1 - inrow }
    (col * (w + gx) + w / 2, row * (h + gy) + h / 2)
  }
  box(width: calc.min(n, cols) * (w + gx) - gx, height: rows * (h + gy) - gy, {
    for i in range(n - 1) {
      let (ax, ay) = pos(i)
      let (bx, by) = pos(i + 1)
      if ay == by {
        let dir = if bx > ax { 1 } else { -1 }
        _arrow((ax + dir * w / 2, ay), (bx - dir * w / 2, by), paint: accent, thickness: 3pt)
      } else {
        _arrow((ax, ay + h / 2), (bx, by - h / 2), paint: accent, thickness: 3pt)
      }
    }
    for (i, it) in items.enumerate() {
      let (x, y) = pos(i)
      _node(x, y, w, h, labels.at(i), fill: _col(it, i), radius: _u(radius), inset: 0.3cm)
    }
  })
}
