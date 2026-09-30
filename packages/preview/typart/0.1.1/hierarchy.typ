// Hierarchy diagram: one root over a single row of children.
// Import with:  #import "hierarchy.typ": hierarchy
//
//   #hierarchy([CEO], (([Eng], rgb("#a7dd9b")), [Sales], [HR]))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let hierarchy(
  root,
  children,
  root-fill: rgb("#aab4f7"),
  box-fill: rgb("#ebedf5"),
  text-fill: rgb("#1f1f3a"),
  accent: rgb("#73c25a"),
  box-w: 5.2,
  box-h: 1.7,
  gap-x: 1.0,
  level-gap: 3.2,
  size: 18pt,
) = canvas({
  import draw: *
  let n = children.len()
  let span = n * box-w + (n - 1) * gap-x
  let cx = i => -span / 2 + box-w / 2 + i * (box-w + gap-x)
  let cy = -level-gap
  let node(p, lab, fill) = {
    rect((p.at(0) - box-w / 2, p.at(1) - box-h / 2),
         (p.at(0) + box-w / 2, p.at(1) + box-h / 2), fill: fill, stroke: none, radius: 0.18)
    content(p, box(width: (box-w - 0.4) * 1cm,
      align(center, text(size: size, fill: text-fill)[#lab])))
  }
  let midy = -level-gap / 2
  for i in range(n) {
    line((0, -box-h / 2), (0, midy), (cx(i), midy), (cx(i), cy + box-h / 2),
      stroke: (paint: accent, thickness: 3pt, join: "round"))
  }
  node((0, 0), root, root-fill)
  for (i, it) in children.enumerate() { node((cx(i), cy), _lab(it), _col(it, i)) }
})
