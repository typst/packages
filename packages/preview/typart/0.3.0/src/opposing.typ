// Opposing: two block arrows facing each other.  Import with:  #import "opposing.typ": opposing
//
//   #opposing(([Pros], [Cons]))
//   #opposing(([Pros], ([Cons], red)))
#import "common.typ": _canvas, _items, _lens, _on, _poly, _put, _tallest, _theme, _txt

#let opposing(
  items,
  item-width: 10em,
  item-height: 4em,
  notch: 2em,
  gap: 0.8em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("opposing", theme, style)
  let (lhs, rhs) = _items("opposing", items, t.palette, min: 2, max: 2)
  let (w, h, notch, gap, size, em) = _lens("opposing", item-width: item-width, item-height: item-height, notch: notch,
    gap: gap, text-size: text-size, em: 1em).values()
  let (la, ra) = (lhs, rhs).map(it => _txt(it.label, _on(t, it.fill), size))
  let h = calc.max(h, _tallest((la, ra), w - notch) + 1.3 * em)
  let rx = w + gap
  _canvas("opposing", t, width, area, 2 * w + gap, h, {
    _poly(shadow: t.shadow, (0pt, 0pt), (w - notch, 0pt), (w, h / 2), (w - notch, h), (0pt, h), fill: lhs.fill)
    _put(w / 2 - notch / 2, h / 2, la, w: w - notch)
    _poly(shadow: t.shadow, (rx + w, 0pt), (rx + notch, 0pt), (rx, h / 2), (rx + notch, h), (rx + w, h), fill: rhs.fill)
    _put(rx + w / 2 + notch / 2, h / 2, ra, w: w - notch)
  })
})
