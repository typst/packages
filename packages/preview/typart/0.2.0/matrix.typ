// 2×2 matrix with optional axis labels.  Import with:  #import "matrix.typ": matrix
//
//   #matrix(((TL), (TR), (BL), (BR)), x-axis: ("Low", "High"), y-axis: ("High", "Low"))
#import "common.typ": _col, _label, _tallest, _txt, _u

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
) = context {
  let (cw, gutter) = (_u(cw), _u(gutter))
  let labels = cells.map(it => _label(it, text-fill, size))
  let ch = calc.max(_u(ch), _tallest(labels, cw - 0.8cm) + 0.8cm)
  let ax(c, w) = box(width: w, align(center, _txt(c, axis-fill, size)))
  let core = grid(columns: (cw, cw), gutter: gutter, ..cells.enumerate().map(((i, it)) => box(
    width: cw, height: ch, fill: _col(it, i), radius: _u(radius), inset: (x: 0.4cm),
    align(center + horizon, labels.at(i)))))
  grid(columns: 2, column-gutter: 0.25cm, row-gutter: 0.25cm,
    if y-axis != none {
      grid(row-gutter: gutter, ..y-axis.map(c => box(height: ch,
        align(horizon, rotate(-90deg, reflow: true, ax(c, ch))))))
    },
    core,
    [],
    if x-axis != none { grid(columns: (cw, cw), column-gutter: gutter, ..x-axis.map(c => ax(c, cw))) })
}
