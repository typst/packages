// KPI stat cards: big value + caption in a row, filling the width.
// Import with:  #import "kpi.typ": kpi
//
//   #kpi((("< 1%", [Target EER]), ([99%], [Accuracy], green)))
#import "common.typ": _card, _fluid, _items, _lens, _on, _tallest, _theme, _txt

#let kpi(
  items,
  item-height: 5em,
  gap: 0.7em,
  inset: 0.8em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("kpi", theme, style)
  let items = _items("kpi", items, t.palette, fields: ("value", "label"))
  let (h, gap, inset, size, em) = _lens("kpi", item-height: item-height, gap: gap, inset: inset,
    text-size: text-size, em: 1em).values()
  let n = items.len()
  let w = (_fluid("kpi", width, area) - gap * (n - 1)) / n
  let cards = items.map(it => stack(dir: ttb, spacing: 0.5 * em,
    _txt(it.value, _on(t, it.fill), size * t.large),
    _txt(it.label, _on(t, it.fill), size * t.small, weight: "regular")))
  // every card takes the tallest content's height (item-height is the minimum)
  let h = calc.max(h, _tallest(cards, w - 2 * inset) + 2 * inset)
  stack(dir: ltr, spacing: gap, ..items.zip(cards).map(((it, card)) =>
    _card(t, width: w, height: h, fill: it.fill, radius: t.corner-radius, inset: inset, align(center + horizon, card))))
})
