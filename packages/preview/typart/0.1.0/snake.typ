// Snake: bending process that wraps into rows.  Import with:  #import "snake.typ": snake
//
//   #snake(([Step 1], [Step 2], [Step 3], [Step 4], [Step 5], [Step 6]))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let snake(
  items,
  cols: 4,
  w: 4.5, h: 2.2, gx: 1.4, gy: 1.4,
  accent: rgb("#73c25a"),
  text-fill: white, size: 16pt, radius: 0.15,
) = canvas({
  import draw: *
  let n = items.len()
  let pos = i => {
    let row = calc.quo(i, cols)
    let inrow = calc.rem(i, cols)
    let col = if calc.rem(row, 2) == 0 { inrow } else { cols - 1 - inrow }
    (col * (w + gx), -row * (h + gy))
  }
  for i in range(n - 1) {
    let a = pos(i)
    let b = pos(i + 1)
    if calc.quo(i, cols) == calc.quo(i + 1, cols) {
      let dir = if calc.rem(calc.quo(i, cols), 2) == 0 { 1 } else { -1 }
      line((a.at(0) + dir * w / 2, a.at(1)), (b.at(0) - dir * w / 2, b.at(1)),
        mark: (end: ">", fill: accent), stroke: accent + 3pt)
    } else {
      line((a.at(0), a.at(1) - h / 2), (b.at(0), b.at(1) + h / 2),
        mark: (end: ">", fill: accent), stroke: accent + 3pt)
    }
  }
  for (i, it) in items.enumerate() {
    let c = pos(i)
    rect((c.at(0) - w / 2, c.at(1) - h / 2), (c.at(0) + w / 2, c.at(1) + h / 2),
      fill: _col(it, i), stroke: none, radius: radius)
    content(c, box(width: (w - 0.6) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
