// Horizontal list: equal blocks side by side, filling the width.
// Import with:  #import "hlist.typ": hlist
//
//   #hlist(([Plan], [Execute], ([Review], red)))
#import "common.typ": _card, _fluid, _items, _lens, _on, _tallest, _theme, _txt

#let hlist(
  items,
  item-height: 4em,
  gap: 0.6em,
  inset: 0.7em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("hlist", theme, style)
  let items = _items("hlist", items, t.palette)
  let (h, gap, inset, size) = _lens("hlist", item-height: item-height, gap: gap, inset: inset,
    text-size: text-size).values()
  let n = items.len()
  let w = (_fluid("hlist", width, area) - gap * (n - 1)) / n
  let labels = items.map(it => _txt(it.label, _on(t, it.fill), size))
  // every block takes the tallest label's height (item-height is the minimum)
  let h = calc.max(h, _tallest(labels, w - 2 * inset) + 2 * inset)
  stack(dir: ltr, spacing: gap, ..items.zip(labels).map(((it, label)) =>
    _card(t, width: w, height: h, fill: it.fill, radius: t.corner-radius, inset: inset, align(center + horizon, label))))
})
