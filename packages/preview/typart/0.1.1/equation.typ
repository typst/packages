// Equation: A + B = C (last item is result).  Import with:  #import "equation.typ": equation
//
//   #equation(([Input 1], [Input 2], [Output]))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let equation(
  items,
  w: 3.6, h: 2.4, gap: 1.6,
  text-fill: white, size: 18pt, op-size: 32pt,
  op-fill: rgb("#1f1f3a"), radius: 0.15,
) = canvas({
  import draw: *
  let n = items.len()
  let pitch = w + gap
  let x0 = -((n - 1) * pitch) / 2
  for (i, it) in items.enumerate() {
    let cx = x0 + i * pitch
    if i > 0 {
      content((cx - pitch / 2, 0),
        text(fill: op-fill, weight: "bold", size: op-size)[#(if i == n - 1 { "=" } else { "+" })])
    }
    rect((cx - w / 2, -h / 2), (cx + w / 2, h / 2), fill: _col(it, i), stroke: none, radius: radius)
    content((cx, 0), box(width: (w - 0.4) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
