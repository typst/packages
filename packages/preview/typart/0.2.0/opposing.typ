// Opposing: two block arrows facing each other.  Import with:  #import "opposing.typ": opposing
//
//   #opposing(([Pros], [Cons]))
//   #opposing(([Pros], ([Cons], rgb("#e64553"))))
#import "common.typ": _col, _label, _poly, _put, _tallest, _u

#let opposing(
  items,
  w: 6.5, h: 2.6, notch: 1.3, gap: 0.5,
  text-fill: white, size: 18pt,
) = context {
  let (w, notch, gap) = (_u(w), _u(notch), _u(gap))
  let (la, ra) = items.map(it => _label(it, text-fill, size))
  let h = calc.max(_u(h), _tallest((la, ra), w - notch) + 0.8cm)
  let rx = w + gap
  box(width: 2 * w + gap, height: h, {
    _poly((0pt, 0pt), (w - notch, 0pt), (w, h / 2), (w - notch, h), (0pt, h), fill: _col(items.at(0), 0))
    _put(w / 2 - notch / 2, h / 2, la, w: w - notch)
    _poly((rx + w, 0pt), (rx + notch, 0pt), (rx, h / 2), (rx + notch, h), (rx + w, h), fill: _col(items.at(1), 1))
    _put(rx + w / 2 + notch / 2, h / 2, ra, w: w - notch)
  })
}
