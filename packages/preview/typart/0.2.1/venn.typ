// Venn diagram (2 or 3 overlapping circles).  Import with:  #import "venn.typ": venn
//
//   #venn((([Behavior], rgb("#aab4f7")), [Signal], [Security]))
#import "common.typ": _col, _dot, _fit, _lab, _put, _txt, _u

#let venn(
  items,
  radius: 3.4,
  text-fill: rgb("#1f1f3a"),
  size: 20pt,
  transparency: 45%,
) = context {
  let r = _u(radius)
  let three = items.len() > 2
  // centres and label anchors in units of the radius, from the top-left corner
  let (centers, labels) = if three {
    (((1.66, 1), (1, 2.12), (2.32, 2.12)), ((1.66, 0.27), (0.51, 2.57), (2.81, 2.57)))
  } else {
    (((1, 1), (2.2, 1)), ((0.6, 1), (2.6, 1)))
  }
  let (w, h) = if three { (r * 1.3, r * 0.5) } else { (r * 1.05, r * 1.2) }
  let s = _fit(items.map(_lab), text-fill, size, w, h)
  box(width: r * (if three { 3.32 } else { 3.2 }), height: r * (if three { 3.12 } else { 2 }), {
    for (i, it) in items.enumerate() {
      let col = _col(it, i)
      let (x, y) = centers.at(i)
      _dot(x * r, y * r, r, fill: col.transparentize(transparency), stroke: col + 2pt)
    }
    for (i, it) in items.enumerate() {
      let (x, y) = labels.at(i)
      _put(x * r, y * r, _txt(_lab(it), text-fill, s), w: w)
    }
  })
}
