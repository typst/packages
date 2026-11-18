// Snake: bending process that wraps into rows.  Import with:  #import "snake.typ": snake
//
//   #snake(([Step 1], [Step 2], [Step 3], [Step 4], [Step 5], [Step 6]))
#import "common.typ": _arrow, _canvas, _items, _lens, _node, _on, _pair, _tallest, _theme, _txt

#let snake(
  items,
  columns: 4,
  item-width: 6em,
  item-height: 3.4em,
  gap: 2em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("snake", theme, style)
  let items = _items("snake", items, t.palette)
  let (w, h, size, em) = _lens("snake", item-width: item-width, item-height: item-height, text-size: text-size,
    em: 1em).values()
  let (gx, gy) = _pair("snake", "gap", gap)
  if not (type(columns) == int and columns > 0) { assert(false, message: "snake: `columns` must be a positive integer, got " + repr(columns)) }
  let labels = items.map(it => _txt(it.label, _on(t, it.fill), size))
  let h = calc.max(h, _tallest(labels, w - em) + 1.2 * em)
  let n = items.len()
  let rows = calc.quo(n - 1, columns) + 1
  let pos = i => {
    let row = calc.quo(i, columns)
    let inrow = calc.rem(i, columns)
    let col = if calc.even(row) { inrow } else { columns - 1 - inrow }
    (col * (w + gx) + w / 2, row * (h + gy) + h / 2)
  }
  _canvas("snake", t, width, area, calc.min(n, columns) * (w + gx) - gx, rows * (h + gy) - gy, {
    for i in range(n - 1) {
      let (ax, ay) = pos(i)
      let (bx, by) = pos(i + 1)
      if ay == by {
        let dir = if bx > ax { 1 } else { -1 }
        _arrow((ax + dir * w / 2, ay), (bx - dir * w / 2, by), paint: t.accent, thickness: t.thick)
      } else {
        _arrow((ax, ay + h / 2), (bx, by - h / 2), paint: t.accent, thickness: t.thick)
      }
    }
    for (i, it) in items.enumerate() {
      let (x, y) = pos(i)
      _node(shadow: t.shadow, x, y, w, h, labels.at(i), fill: it.fill, radius: t.corner-radius, inset: 0.5 * em)
    }
  })
})
