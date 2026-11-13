// Panels: a grid of framed sub-figures, each with an optional caption inside and a
// number below: a), b), ... (or 1), 2), ...).  Import with:  #import "panels.typ": panels
//
//   #panels(([Icons], [Single-Factor]), ([More icons], [Multi-Factor]), columns: 2)
#import "common.typ": _tallest

#let panels(
  ..items,
  columns: 2,
  numbering: "a)",
  stroke: (paint: luma(120), thickness: 1pt, dash: "dashed"),
  fill: none,
  radius: 0pt,
  inset: 12pt,
  gutter: 18pt,
  caption-fill: luma(110),
  caption-size: 1.3em,
  label-size: 1.5em,
) = layout(area => {
  // an item is a body or a (body, caption) pair; the caption sits under the body
  let bodies = items.pos().map(it => if type(it) == array {
    stack(spacing: 0.8em, it.at(0), text(fill: caption-fill, size: caption-size, it.at(1)))
  } else { it })
  let w = (area.width - gutter * (columns - 1)) / columns
  // panels in one row share the tallest one's height
  grid(columns: (w,) * columns, column-gutter: gutter, row-gutter: gutter,
    ..range(bodies.len()).chunks(columns).map(row => {
      let h = _tallest(row.map(i => bodies.at(i)), w - 2 * inset) + 2 * inset
      row.map(i => stack(spacing: 8pt,
        box(width: w, height: h, inset: inset, stroke: stroke, fill: fill, radius: radius,
          align(center + horizon, bodies.at(i))),
        if numbering != none { align(center, text(size: label-size, std.numbering(numbering, i + 1))) }))
    }).flatten())
})
