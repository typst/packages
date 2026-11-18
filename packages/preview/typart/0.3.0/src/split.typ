// Split: one bar divided in proportion to its parts (train / validation / test, the
// phases of a protocol).  Import with:  #import "split.typ": split
//
//   #split((([Train], 70), ([Validation], 15), ([Test], 15)))
#import "common.typ": _card, _fit, _fluid, _items, _lens, _on, _put, _theme, _txt

#let split(
  items,
  unit: "%",
  item-height: 3em,
  gap: 0.25em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("split", theme, style)
  let items = _items("split", items, t.palette, fields: ("label", "value"), numbers: ("value",))
  for (i, it) in items.enumerate() {
    if not (type(it.value) in (int, float) and it.value > 0) { assert(false, message: "split: the value of item " + str(i + 1)
      + " must be a positive number, got " + repr(it.value)) }
  }
  let (h, gap, size, em) = _lens("split", item-height: item-height, gap: gap, text-size: text-size, em: 1em).values()
  let total = _fluid("split", width, area)
  let share = (total - gap * (items.len() - 1)) / items.map(it => it.value).sum()
  let widths = items.map(it => it.value * share)
  let caption(it, s) = stack(spacing: 0.35 * em, _txt(it.label, _on(t, it.fill), s),
    _txt([#it.value#unit], _on(t, it.fill), s * t.small, weight: auto))
  // one text size for every part, small enough for the narrowest
  let s = _fit(items.map(it => it.label), t.ink, size, widths.map(w => calc.max(0pt, w - 0.6 * em)),
    (h - 0.8 * em) / (1 + 1.3 * t.small / 100%))
  let x = 0pt
  box(width: total, height: h, for (it, w) in items.zip(widths) {
    place(top + left, dx: x, _card(t, width: w, height: h, fill: it.fill, radius: t.corner-radius,
      align(center + horizon, caption(it, s))))
    x += w + gap
  })
})
