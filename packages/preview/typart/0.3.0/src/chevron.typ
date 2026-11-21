// Chevron: sequential right-pointing arrows.  Import with:  #import "chevron.typ": chevron
//
//   #chevron(([Phase 1], [Phase 2], ([Phase 3], red)))
#import "common.typ": _canvas, _items, _lens, _on, _poly, _put, _tallest, _theme, _txt

#let chevron(
  items,
  item-width: 8em,
  item-height: 3.6em,
  notch: 1.5em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("chevron", theme, style)
  let items = _items("chevron", items, t.palette)
  let (w, h, notch, size, em) = _lens("chevron", item-width: item-width, item-height: item-height, notch: notch,
    text-size: text-size, em: 1em).values()
  let step = w - notch
  let labels = items.map(it => _txt(it.label, _on(t, it.fill), size))
  let h = calc.max(h, _tallest(labels, step - notch) + 1.2 * em)
  _canvas("chevron", t, width, area, items.len() * step + notch, h, {
    for (i, it) in items.enumerate() {
      let x = i * step
      _poly((x, 0pt), (x + step, 0pt), (x + w, h / 2), (x + step, h), (x, h), (x + notch, h / 2),
        fill: it.fill, stroke: t.surface + 0.1 * em)
    }
    // labels after all shapes, inside the straight part between the notch and the point
    for (i, label) in labels.enumerate() { _put(i * step + w / 2, h / 2, label, w: step - notch) }
  })
})
