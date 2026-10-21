// Chevron: sequential right-pointing arrows.  Import with:  #import "chevron.typ": chevron
//
//   #chevron(([Phase 1], [Phase 2], ([Phase 3], rgb("#e64553"))))
#import "common.typ": _col, _label, _poly, _put, _tallest, _u

#let chevron(
  items,
  w: 5,
  h: 2.4,
  notch: 0.9,
  text-fill: white,
  size: 18pt,
) = context {
  let (w, notch) = (_u(w), _u(notch))
  let step = w - notch
  let labels = items.map(it => _label(it, text-fill, size))
  let h = calc.max(_u(h), _tallest(labels, step - notch) + 0.8cm)
  box(width: items.len() * step + notch, height: h, {
    for (i, it) in items.enumerate() {
      let x = i * step
      _poly((x, 0pt), (x + step, 0pt), (x + w, h / 2), (x + step, h), (x, h), (x + notch, h / 2),
        fill: _col(it, i), stroke: white + 1.5pt)
    }
    // labels after all shapes, inside the straight part between the notch and the point
    for i in range(items.len()) { _put(i * step + w / 2, h / 2, labels.at(i), w: step - notch) }
  })
}
