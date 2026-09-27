// Cycle: nodes on a ring joined by curved arrows.  Import with:  #import "cycle.typ": cycle
//
//   #cycle(([Plan], [Do], [Check], ([Act], rgb("#e64553"))))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let cycle(
  items,
  radius: auto,
  node: 1.5,
  arrow: rgb("#73c25a"),
  text-fill: white,
  size: 16pt,
) = canvas({
  import draw: *
  let n = items.len()
  let R = if radius == auto { calc.max(3, n * 0.9) } else { radius }
  let ang = i => 90deg - i * 360deg / n
  let gapd = calc.asin(calc.min(0.99, node / R)) + 7deg
  for i in range(n) {
    let a0 = ang(i) - gapd
    let a1 = ang(calc.rem(i + 1, n)) + gapd
    if a1 > a0 { a1 = a1 - 360deg }
    arc((R * calc.cos(a0), R * calc.sin(a0)), start: a0, stop: a1, radius: R,
      mark: (end: ">", fill: arrow), stroke: arrow + 3pt)
  }
  for (i, it) in items.enumerate() {
    let p = (R * calc.cos(ang(i)), R * calc.sin(ang(i)))
    circle(p, radius: node, fill: _col(it, i), stroke: white + 2pt)
    content(p, box(width: (2 * node - 0.5) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
})
