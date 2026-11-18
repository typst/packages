// Vertical numbered steps list.  Import with:  #import "steps.typ": steps
//
//   #steps(([Plan], [Execute], ([Review], red)))
#import "common.typ": _card, _fluid, _items, _lens, _on, _theme, _txt

#let steps(
  items,
  gap: 0.6em,
  inset: 0.8em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("steps", theme, style)
  let items = _items("steps", items, (t.panel,))
  let (gap, inset, size) = _lens("steps", gap: gap, inset: inset, text-size: text-size).values()
  let badge = 1.6 * size
  block(width: _fluid("steps", width, area), stack(dir: ttb, spacing: gap, ..items.enumerate().map(((i, it)) =>
    grid(columns: (auto, 1fr), column-gutter: gap, align: horizon,
      _card(t, width: badge, height: badge, fill: t.accent, radius: 50%,
        align(center + horizon, _txt([#(i + 1)], _on(t, t.accent), size))),
      _card(t, width: 100%, fill: it.fill, radius: t.corner-radius, inset: inset,
        _txt(it.label, _on(t, it.fill), size, weight: auto))))))
})
