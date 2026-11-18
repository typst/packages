// Stairs: ascending step-up process.  Import with:  #import "stairs.typ": stairs
//
//   #stairs(([Plan], [Develop], ([Launch], red)))
#import "common.typ": _arrow, _canvas, _items, _lens, _node, _on, _pair, _tallest, _theme, _txt

#let stairs(
  items,
  item-width: 5.6em,
  item-height: 2.8em,
  step: (6em, 3.2em),
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("stairs", theme, style)
  let items = _items("stairs", items, t.palette)
  let (w, h, size, em) = _lens("stairs", item-width: item-width, item-height: item-height, text-size: text-size,
    em: 1em).values()
  let (dx, dy) = _pair("stairs", "step", step)
  let labels = items.map(it => _txt(it.label, _on(t, it.fill), size))
  let h = calc.max(h, _tallest(labels, w - 0.8 * em) + 1.2 * em)
  // steps never overlap and the elbow arrows always have room
  let dx = calc.max(dx, w / 2 + em)
  let dy = calc.max(dy, h + 0.35 * em)
  let n = items.len()
  let c = i => (i * dx + w / 2, (n - 1 - i) * dy + h / 2)
  _canvas("stairs", t, width, area, (n - 1) * dx + w, (n - 1) * dy + h, {
    for i in range(n - 1) {
      let (ax, ay) = c(i)
      let (bx, by) = c(i + 1)
      // elbow from the top of a step to the side of the next one
      _arrow((ax, ay - h / 2), (ax, by), (bx - w / 2, by), paint: t.accent, thickness: t.thick)
    }
    for (i, it) in items.enumerate() {
      let (x, y) = c(i)
      _node(shadow: t.shadow, x, y, w, h, labels.at(i), fill: it.fill, radius: t.corner-radius, inset: 0.4 * em)
    }
  })
})
