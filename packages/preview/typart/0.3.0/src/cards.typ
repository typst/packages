// Cards: coloured header over a tinted body (horizontal bullet list).
// Import with:  #import "cards.typ": cards
//
//   #cards((([Goals], [- Faster \ - Cheaper]), ([Risks], [- Scope], red)))
#import "common.typ": _card, _fluid, _items, _lens, _on, _tallest, _theme, _txt

#let cards(
  items,
  columns: auto,
  gap: 0.6em,
  inset: 0.7em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("cards", theme, style)
  let items = _items("cards", items, t.palette, fields: ("title", "body"))
  let (gap, inset, size) = _lens("cards", gap: gap, inset: inset, text-size: text-size).values()
  let k = if columns == auto { items.len() } else { columns }
  if not (type(k) == int and k > 0) { assert(false, message: "cards: `columns` must be auto or a positive integer, got " + repr(columns)) }
  let w = (_fluid("cards", width, area) - gap * (k - 1)) / k
  let tints = items.map(it => color.mix((it.fill, 25%), (t.surface, 75%)))
  let head = items.map(it => _txt(it.title, _on(t, it.fill), size))
  let body = items.zip(tints).map(((it, tint)) => _txt(it.body, _on(t, tint), size * t.small, weight: auto))
  // cards in one row share the tallest header and the tallest body
  stack(dir: ttb, spacing: gap, ..range(items.len()).chunks(k).map(row => {
    let head-h = _tallest(row.map(i => head.at(i)), w - 2 * inset) + 2 * inset
    let body-h = _tallest(row.map(i => body.at(i)), w - 2 * inset) + 2 * inset
    stack(dir: ltr, spacing: gap, ..row.map(i => stack(
      _card(t, width: w, height: head-h, fill: items.at(i).fill, inset: inset, radius: (top: t.corner-radius),
        align(center + horizon, head.at(i))),
      _card(t, width: w, height: body-h, fill: tints.at(i), inset: inset, radius: (bottom: t.corner-radius),
        align(left + top, body.at(i))))))
  }))
})
