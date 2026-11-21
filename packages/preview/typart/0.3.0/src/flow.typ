// Flow: blocks joined by block arrows (basic process).  Import with:  #import "flow.typ": flow
//
//   #flow(([Input], [Process], ([Output], red)))
//   #flow(([Input], [Process], [Output]), dir: ttb)
#import "common.typ": _canvas, _card, _items, _lens, _on, _tallest, _theme, _txt

#let flow(
  items,
  dir: ltr,
  item-width: 6em,
  item-height: 3.4em,
  gap: 2em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("flow", theme, style)
  let items = _items("flow", items, t.palette)
  let (w, h, gap, size, em) = _lens("flow", item-width: item-width, item-height: item-height, gap: gap,
    text-size: text-size, em: 1em).values()
  let labels = items.map(it => _txt(it.label, _on(t, it.fill), size))
  let h = calc.max(h, _tallest(labels, w - 0.8 * em) + 1.2 * em)
  let across = dir == ltr
  // arrow length runs along the flow; its thickness runs across it
  let (len, thick) = (gap * 0.62, calc.min(gap * 0.75, (if across { h } else { w }) * 0.5))
  let shaft = thick * 0.45
  let head = len * 0.5
  let arrow = polygon(fill: t.accent,
    (0pt, (thick - shaft) / 2), (len - head, (thick - shaft) / 2), (len - head, 0pt), (len, thick / 2),
    (len - head, thick), (len - head, (thick + shaft) / 2), (0pt, (thick + shaft) / 2))
  let link = if across {
    box(width: gap, height: h, align(center + horizon, arrow))
  } else {
    box(width: w, height: gap, align(center + horizon, rotate(90deg, reflow: true, arrow)))
  }
  let n = items.len()
  let (along, cross) = (n * (if across { w } else { h }) + (n - 1) * gap, if across { h } else { w })
  _canvas("flow", t, width, area, if across { along } else { cross }, if across { cross } else { along },
    stack(dir: dir, ..items.zip(labels).enumerate().map(((i, (it, label))) => {
      let card = _card(t, width: w, height: h, fill: it.fill, radius: t.corner-radius, inset: (x: 0.4 * em),
        align(center + horizon, label))
      if i == 0 { card } else { (link, card) }
    }).flatten()))
})
