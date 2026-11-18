// Panels: a grid of framed sub-figures, each with an optional caption inside and a
// number below: a), b), ... (or 1), 2), ...).  Import with:  #import "panels.typ": panels
//
//   #panels((([Icons], [Single-Factor]), ([More icons], [Multi-Factor])), columns: 2)
#import "common.typ": _fluid, _items, _lens, _tallest, _theme

#let panels(
  items,
  columns: 2,
  numbering: "a)",
  gap: 1.1em,
  inset: 0.7em,
  fill: none,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("panels", theme, style)
  let (gap, inset, em) = _lens("panels", gap: gap, inset: inset, em: 1em).values()
  // an item is a body or a (body, caption) pair; the caption sits under the body
  let bodies = _items("panels", items, t.palette, fields: ("body",), optional: ("caption",)).map(it =>
    if it.caption == none { it.body } else {
      stack(spacing: 0.8 * em, it.body, text(fill: t.line, size: t.small * 1em, it.caption))
    })
  let w = (_fluid("panels", width, area) - gap * (columns - 1)) / columns
  // panels in one row share the tallest one's height
  grid(columns: (w,) * columns, column-gutter: gap, row-gutter: gap,
    ..range(bodies.len()).chunks(columns).map(row => {
      let h = _tallest(row.map(i => bodies.at(i)), w - 2 * inset) + 2 * inset
      row.map(i => stack(spacing: 0.5 * em,
        box(width: w, height: h, inset: inset, fill: fill, radius: t.corner-radius,
          stroke: (paint: t.line, thickness: t.stroke, dash: "dashed"), align(center + horizon, bodies.at(i))),
        if numbering != none { align(center, text(fill: t.ink, std.numbering(numbering, i + 1))) }))
    }).flatten())
})
