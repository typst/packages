// Gauges: progress rings with a big percentage and a caption.
// Import with:  #import "gauges.typ": gauges
//
//   #gauges(((72, [Recall]), (91, [Precision], rgb("#e64553")), (45, [Coverage])))
#import "common.typ": _arc, _col, _dot, _polar, _put, _txt, _u

#let gauges(
  items,
  radius: 1.8,
  thickness: 0.35,
  track: luma(232),
  text-fill: rgb("#1f1f3a"),
  value-size: 24pt, label-size: 14pt,
  gutter: 12pt,
) = {
  let (r, t) = (_u(radius), _u(thickness))
  let ring(value, col) = box(width: 2 * r, height: 2 * r, {
    _dot(r, r, r - t / 2, stroke: track + t)
    // clockwise from twelve o'clock; a full ring needs no arc maths
    if value >= 100 { _dot(r, r, r - t / 2, stroke: col + t) } else if value > 0 {
      let a1 = 90deg - value * 3.6deg
      place(top + left, curve(stroke: (paint: col, thickness: t, cap: "round"),
        curve.move(_polar(r, r, r - t / 2, 90deg)), .._arc(r, r, r - t / 2, 90deg, a1)))
    }
    _put(r, r, _txt([#value%], text-fill, value-size), w: 2 * r - 2 * t)
  })
  grid(columns: items.len(), column-gutter: gutter, row-gutter: 8pt, align: center + top,
    ..items.enumerate().map(((i, it)) => ring(it.at(0), _col(it, i, at: 2))),
    ..items.map(it => box(width: 2 * r, _txt(it.at(1), text-fill, label-size, weight: auto))))
}
