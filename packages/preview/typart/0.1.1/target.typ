// Target: concentric rings, outermost first.  Import with:  #import "target.typ": target
//
//   #target(([Vision], [Mission], ([Goal], rgb("#e64553"))))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let target(
  items,
  radius: 5,
  text-fill: white,
  size: 16pt,
) = canvas({
  import draw: *
  let n = items.len()
  for (i, it) in items.enumerate() {
    circle((0, 0), radius: radius * (n - i) / n, fill: _col(it, i), stroke: white + 2pt)
  }
  for (i, it) in items.enumerate() {
    let ro = radius * (n - i) / n
    let ri = radius * (n - i - 1) / n
    let y = if i == n - 1 { 0 } else { (ro + ri) / 2 }
    let w = calc.max(1.0, 2 * calc.sqrt(calc.max(0.01, ro * ro - y * y)) - 0.4)
    content((0, y), box(width: w * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
