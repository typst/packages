// Equation: A + B = C (last item is result).  Import with:  #import "equation.typ": equation
//
//   #equation(([Input 1], [Input 2], [Output]))
#import "common.typ": _col, _label, _tallest, _txt, _u

#let equation(
  items,
  w: 3.6, h: 2.4, gap: 1.6,
  text-fill: white, size: 18pt, op-size: 32pt,
  op-fill: rgb("#1f1f3a"), radius: 0.15,
) = context {
  let (w, gap) = (_u(w), _u(gap))
  let n = items.len()
  let labels = items.map(it => _label(it, text-fill, size))
  let h = calc.max(_u(h), _tallest(labels, w - 0.4cm) + 0.8cm)
  stack(dir: ltr, ..items.enumerate().map(((i, it)) => {
    let card = box(width: w, height: h, fill: _col(it, i), radius: _u(radius), inset: (x: 0.2cm),
      align(center + horizon, labels.at(i)))
    if i == 0 { return card }
    (box(width: gap, height: h, align(center + horizon,
      _txt(if i == n - 1 { "=" } else { "+" }, op-fill, op-size))), card)
  }).flatten())
}
