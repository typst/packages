// Converging or diverging arrows to/from a centre.  Import with:  #import "arrows.typ": arrows
//
//   #arrows(([Idea 1], [Idea 2], [Idea 3]), core: [Core])
//   #arrows(([Branch 1], [Branch 2]), diverge: true)
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let arrows(
  items,
  core: none,
  diverge: false,
  radius: 4.8,
  bw: 3.6, bh: 1.6,
  text-fill: white, size: 16pt,
  core-fill: rgb("#1f1f3a"), core-r: 1.4,
) = canvas({
  import draw: *
  let n = items.len()
  let ang = i => 90deg - i * 360deg / n
  for (i, it) in items.enumerate() {
    let a = ang(i)
    let col = _col(it, i)
    let nearbox = ((radius - 1.1) * calc.cos(a), (radius - 1.1) * calc.sin(a))
    let nearctr = ((core-r + 0.4) * calc.cos(a), (core-r + 0.4) * calc.sin(a))
    if diverge {
      line(nearctr, nearbox, mark: (end: ">", fill: col), stroke: col + 6pt)
    } else {
      line(nearbox, nearctr, mark: (end: ">", fill: col), stroke: col + 6pt)
    }
    let bx = (radius * calc.cos(a), radius * calc.sin(a))
    rect((bx.at(0) - bw / 2, bx.at(1) - bh / 2), (bx.at(0) + bw / 2, bx.at(1) + bh / 2),
      fill: col, stroke: none, radius: 0.15)
    content(bx, box(width: (bw - 0.4) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
  circle((0, 0), radius: core-r, fill: core-fill, stroke: white + 2pt)
  if core != none {
    content((0, 0), box(width: (2 * core-r - 0.3) * 1cm,
      align(center, text(fill: white, weight: "bold", size: size)[#core])))
  }
})
