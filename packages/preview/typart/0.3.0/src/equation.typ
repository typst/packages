// Equation: A + B = C (last item is result).  Import with:  #import "equation.typ": equation
//
//   #equation(([Input 1], [Input 2], [Output]))
#import "common.typ": _canvas, _card, _items, _lens, _on, _tallest, _theme, _txt

#let equation(
  items,
  item-width: 6em,
  item-height: 3.6em,
  gap: 2.6em,
  operators: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("equation", theme, style)
  let items = _items("equation", items, t.palette, min: 2)
  let (w, h, gap, size, em) = _lens("equation", item-width: item-width, item-height: item-height, gap: gap,
    text-size: text-size, em: 1em).values()
  let n = items.len()
  let operators = if operators == auto { ([+],) * (n - 2) + ([=],) } else { operators }
  if not (type(operators) == array and operators.len() == n - 1) { assert(false, message: "equation: `operators` needs one entry between "
    + "each pair of items (" + str(n - 1) + "), got " + repr(operators)) }
  let labels = items.map(it => _txt(it.label, _on(t, it.fill), size))
  let h = calc.max(h, _tallest(labels, w - 0.7 * em) + 1.3 * em)
  _canvas("equation", t, width, area, n * w + (n - 1) * gap, h,
    stack(dir: ltr, ..items.zip(labels).enumerate().map(((i, (it, label))) => {
      let card = _card(t, width: w, height: h, fill: it.fill, radius: t.corner-radius, inset: (x: 0.35 * em),
        align(center + horizon, label))
      if i == 0 { return card }
      (box(width: gap, height: h, align(center + horizon,
        _txt(operators.at(i - 1), t.ink, size * t.large))), card)
    }).flatten()))
})
