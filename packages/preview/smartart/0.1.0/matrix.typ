// 2×2 matrix with optional axis labels.  Import with:  #import "matrix.typ": matrix
//
//   #matrix(((TL), (TR), (BL), (BR)), x-axis: ("Low", "High"), y-axis: ("High", "Low"))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let matrix(
  cells,
  x-axis: none,
  y-axis: none,
  cw: 6,
  ch: 4,
  gutter: 0.3,
  text-fill: white,
  size: 18pt,
  axis-fill: rgb("#1f1f3a"),
  radius: 0.12,
) = canvas({
  import draw: *
  let hx = (cw + gutter) / 2
  let hy = (ch + gutter) / 2
  let centers = ((-hx, hy), (hx, hy), (-hx, -hy), (hx, -hy))
  for (i, it) in cells.enumerate() {
    let c = centers.at(i)
    rect((c.at(0) - cw / 2, c.at(1) - ch / 2), (c.at(0) + cw / 2, c.at(1) + ch / 2),
      fill: _col(it, i), stroke: none, radius: radius)
    content(c, box(width: (cw - 0.8) * 1cm,
      align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(it)])))
  }
  let ax(c) = text(fill: axis-fill, weight: "bold", size: size)[#c]
  if x-axis != none {
    let y = -hy - ch / 2 - 0.5
    content((-hx, y), ax(x-axis.at(0)))
    content((hx, y), ax(x-axis.at(1)))
  }
  if y-axis != none {
    let x = -hx - cw / 2 - 0.5
    content((x, hy), ax(y-axis.at(0)), angle: 90deg)
    content((x, -hy), ax(y-axis.at(1)), angle: 90deg)
  }
})
