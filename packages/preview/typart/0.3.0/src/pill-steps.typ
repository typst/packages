// Pill-steps: central hub + connected rounded pill rows (freepik style).
// Import with:  #import "pill-steps.typ": pill-steps
//
//   item = (title, body) | (title, body, icon) | (title, body, icon, color)
//   icon is a Font Awesome glyph or ANY content already styled by you.
//
//   #pill-steps((
//     ([Research], [Gather requirements], "\u{f0eb}"),
//     ([Develop], [Build the solution], blue),
//   ))
#import "common.typ": _canvas, _card, _items, _lens, _on, _or, _theme, _txt
#import "helpers.typ": icon

#let pill-steps(
  items,
  title: [INFOGRAPHIC \ STEPS],
  hub-body: none,
  hub-radius: 6em,
  node-radius: 1.8em,
  item-width: 22em,
  item-height: 4em,   // the minimum: a pill grows with its wrapped text
  gap: 1em,
  hub-gap: 3em,
  hub-fill: auto,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("pill-steps", theme, style)
  let items = _items("pill-steps", items, t.palette, fields: ("title", "body"), optional: ("icon",))
  let (hub-r, node-r, pill-w, pill-h, gap, hub-gap, size, em) = _lens("pill-steps", hub-radius: hub-radius,
    node-radius: node-radius, item-width: item-width, item-height: item-height, gap: gap, hub-gap: hub-gap,
    text-size: text-size, em: 1em).values()
  let n = items.len()
  let pad-y = 0.5 * em
  let (pad-left, icon-slot) = (node-r + 1.2 * em, 2.3 * em)
  let pad-right(it) = if it.icon == none { 1.3 * em } else { icon-slot + 1.6 * em }
  let inners = items.map(it => stack(dir: ttb, spacing: 0.25 * em,
    _txt(it.title, _on(t, it.fill), size),
    _txt(it.body, _on(t, it.fill), size * t.small, weight: auto)))
  // Per-pill height follows the wrapped text (item-height as minimum) so multi-line
  // labels are not clipped.  Measure at the same content width the pill uses.
  let heights = items.zip(inners).map(((it, inner)) =>
    calc.max(pill-h, measure(inner, width: pill-w - pad-left - pad-right(it)).height + 2 * pad-y))
  let total-h = heights.sum() + (n - 1) * gap
  let height = calc.max(total-h, 2 * hub-r)
  let pill-x = 2 * hub-r + hub-gap
  // cumulative row tops from the variable heights
  let tops = ()
  let acc = (height - total-h) / 2
  for h in heights {
    tops.push(acc)
    acc += h + gap
  }
  let cy = i => tops.at(i) + heights.at(i) / 2
  let hub-cy = height / 2
  let hub-fill = _or(hub-fill, t.line)
  let hub-ink = _on(t, hub-fill)
  _canvas("pill-steps", t, width, area, pill-x + pill-w, height, {
    for i in range(n) {
      let (ax, ay) = (hub-r * 1.35, hub-cy + (cy(i) - hub-cy) * 0.35)
      let (bx, by) = (pill-x - node-r, cy(i))
      let mx = (ax + bx) / 2
      place(top + left, curve(stroke: t.muted + t.stroke,
        curve.move((ax, ay)), curve.cubic((mx, ay), (mx, by), (bx, by))))
    }
    for (i, it) in items.enumerate() {
      let ph = heights.at(i)
      place(top + left, dx: pill-x, dy: tops.at(i),
        _card(t, width: pill-w, height: ph, fill: it.fill, radius: calc.min(ph, pill-h) / 2,
          inset: (left: pad-left, right: pad-right(it), y: pad-y), align(horizon, inners.at(i))))
      if it.icon != none {
        let symbol = if type(it.icon) == str { icon(it.icon, size: size * t.large) } else { it.icon }
        place(top + left, dx: pill-x + pill-w - icon-slot - 0.8 * em, dy: cy(i) - icon-slot / 2,
          box(width: icon-slot, height: icon-slot, align(center + horizon, text(fill: _on(t, it.fill), symbol))))
      }
      place(top + left, dx: pill-x - node-r, dy: cy(i) - node-r,
        box(width: 2 * node-r, height: 2 * node-r, fill: t.surface, radius: node-r, stroke: it.fill + 1.5 * t.stroke,
          align(center + horizon, _txt([#(if i + 1 < 10 { "0" })#(i + 1)], t.ink, size * t.large))))
    }
    place(top + left, dy: hub-cy - hub-r,
      _card(t, width: 2 * hub-r, height: 2 * hub-r, fill: hub-fill, radius: hub-r, inset: hub-r * 0.35,
        align(center + horizon, stack(dir: ttb, spacing: 0.35 * em,
          _txt(title, hub-ink, size * t.large),
          if hub-body != none { box(width: 100%, _txt(hub-body, hub-ink, size * t.small, weight: auto)) }))))
  })
})
