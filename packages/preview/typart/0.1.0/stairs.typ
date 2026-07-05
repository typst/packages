// Stairs: ascending step-up process.  Import with:  #import "stairs.typ": stairs
//
//   #stairs(([Plan], [Develop], ([Launch], rgb("#e64553"))))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let stairs(
  items,
  w: 3.4, h: 1.7, dx: 3.6, dy: 1.9,
  accent: luma(130),
  text-fill: white, size: 16pt, radius: 0.15,
) = canvas({
  import draw: *
  let n = items.len()
  let c = i => (i * dx, i * dy)
  for i in range(n - 1) {
    let a = c(i)
    let b = c(i + 1)
    line((a.at(0) + w / 2, a.at(1)), (b.at(0) - w / 2, b.at(1)),
      mark: (end: ">", fill: accent), stroke: accent + 3pt)
  }
  for (i, it) in items.enumerate() {
    let p = c(i)
    rect((p.at(0) - w / 2, p.at(1) - h / 2), (p.at(0) + w / 2, p.at(1) + h / 2),
      fill: _col(it, i), stroke: none, radius: radius)
    content(p, box(width: (w - 0.5) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
