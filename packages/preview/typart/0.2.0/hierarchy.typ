// Hierarchy diagram: one root over a single row of children.
// Import with:  #import "hierarchy.typ": hierarchy
//
//   #hierarchy([CEO], (([Eng], rgb("#a7dd9b")), [Sales], [HR]))
#import "common.typ": _col, _lab, _node, _tallest, _txt, _u

#let hierarchy(
  root,
  children,
  root-fill: rgb("#aab4f7"),
  box-fill: auto,
  text-fill: rgb("#1f1f3a"),
  accent: rgb("#73c25a"),
  box-w: 5.2,
  box-h: 1.7,
  gap-x: 1.0,
  level-gap: 3.2,
  size: 18pt,
) = context {
  let (box-w, gap-x, level-gap) = (_u(box-w), _u(gap-x), _u(level-gap))
  let n = children.len()
  let labels = (root, ..children.map(_lab)).map(l => _txt(l, text-fill, size, weight: auto))
  let box-h = calc.max(_u(box-h), _tallest(labels, box-w - 0.4cm) + 0.8cm)
  let level-gap = calc.max(level-gap, box-h + 0.8cm)
  let row = n * box-w + (n - 1) * gap-x
  let span = calc.max(box-w, row)
  let cx = i => (span - row) / 2 + box-w / 2 + i * (box-w + gap-x)
  let cy = box-h / 2 + level-gap
  let mid = box-h / 2 + level-gap / 2
  let node(x, y, lab, fill) = _node(x, y, box-w, box-h, lab, fill: fill, radius: 0.18cm)
  box(width: span, height: if n > 0 { level-gap + box-h } else { box-h }, {
    for i in range(n) {
      place(top + left, curve(stroke: (paint: accent, thickness: 3pt, join: "round"),
        curve.move((span / 2, box-h)), curve.line((span / 2, mid)), curve.line((cx(i), mid)),
        curve.line((cx(i), cy - box-h / 2))))
    }
    node(span / 2, box-h / 2, labels.at(0), root-fill)
    for (i, it) in children.enumerate() {
      let fill = if type(it) == array and it.len() > 1 or box-fill == auto { _col(it, i) } else { box-fill }
      node(cx(i), cy, labels.at(i + 1), fill)
    }
  })
}
