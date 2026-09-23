// Venn diagram (2 or 3 overlapping circles).  Import with:  #import "venn.typ": venn
//
//   #venn((([Behavior], rgb("#aab4f7")), [Signal], [Security]))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let venn(
  items,
  radius: 3.4,
  text-fill: rgb("#1f1f3a"),
  size: 20pt,
  transparency: 45%,
) = canvas({
  import draw: *
  let n = items.len()
  let r = radius
  let centers = if n <= 2 { ((-r * 0.6, 0), (r * 0.6, 0)).slice(0, n) }
    else { ((0, r * 0.62), (-r * 0.66, -r * 0.5), (r * 0.66, -r * 0.5)) }
  let labpos = if n <= 2 { ((-r, 0), (r, 0)).slice(0, n) }
    else { ((0, r * 1.35), (-r * 1.15, -r * 0.95), (r * 1.15, -r * 0.95)) }
  for (i, it) in items.enumerate() {
    let col = _col(it, i)
    circle(centers.at(i), radius: r, fill: col.transparentize(transparency), stroke: col + 2pt)
  }
  for (i, it) in items.enumerate() {
    content(labpos.at(i), text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])
  }
})
