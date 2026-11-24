// Flow: blocks joined by block arrows (basic process).  Import with:  #import "flow.typ": flow
//
//   #flow(([Input], [Process], ([Output], rgb("#e64553"))))
//   #flow(([Input], [Process], [Output]), dir: ttb)
#import "common.typ": _col, _label, _tallest, _u

#let flow(
  items,
  dir: ltr,
  w: 4, h: 2.4, gap: 1.4,
  accent: luma(190),
  text-fill: white, size: 18pt, radius: 0.15,
) = context {
  let (w, gap) = (_u(w), _u(gap))
  let labels = items.map(it => _label(it, text-fill, size))
  let h = calc.max(_u(h), _tallest(labels, w - 0.5cm) + 0.8cm)
  let across = dir == ltr
  // arrow length runs along the flow; its thickness runs across it
  let (len, thick) = (gap * 0.62, calc.min(gap * 0.75, (if across { h } else { w }) * 0.5))
  let shaft = thick * 0.45
  let head = len * 0.5
  let arrow = polygon(fill: accent,
    (0pt, (thick - shaft) / 2), (len - head, (thick - shaft) / 2), (len - head, 0pt), (len, thick / 2),
    (len - head, thick), (len - head, (thick + shaft) / 2), (0pt, (thick + shaft) / 2))
  let link = if across {
    box(width: gap, height: h, align(center + horizon, arrow))
  } else {
    box(width: w, height: gap, align(center + horizon, rotate(90deg, reflow: true, arrow)))
  }
  stack(dir: dir, ..items.enumerate().map(((i, it)) => {
    let card = box(width: w, height: h, fill: _col(it, i), radius: _u(radius), inset: (x: 0.25cm),
      align(center + horizon, labels.at(i)))
    if i == 0 { card } else { (link, card) }
  }).flatten())
}
