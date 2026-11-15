// Cards: coloured header over a tinted body (horizontal bullet list).
// Import with:  #import "cards.typ": cards
//
//   #cards((([Goals], [- Faster \ - Cheaper]), ([Risks], [- Scope], rgb("#e64553"))))
#import "common.typ": _col, _tallest

#let cards(
  items,
  columns: auto,
  text-fill: white,
  body-fill: auto,
  body-text: rgb("#1f1f3a"),
  size: 18pt, body-size: 14pt,
  gutter: 10pt, radius: 8pt, inset: 12pt,
) = layout(area => {
  let k = if columns == auto { items.len() } else { columns }
  let w = (area.width - gutter * (k - 1)) / k
  let head = items.map(it => {
    set par(justify: false, leading: 0.5em)
    text(fill: text-fill, weight: "bold", size: size, it.at(0))
  })
  let body = items.map(it => {
    set par(justify: false, leading: 0.5em)
    text(fill: body-text, size: body-size, it.at(1))
  })
  // cards in one row share the tallest header and the tallest body
  let rows = range(items.len()).chunks(k)
  stack(dir: ttb, spacing: gutter, ..rows.map(row => {
    let head-h = _tallest(row.map(i => head.at(i)), w - 2 * inset) + 2 * inset
    let body-h = _tallest(row.map(i => body.at(i)), w - 2 * inset) + 2 * inset
    stack(dir: ltr, spacing: gutter, ..row.map(i => {
      let col = _col(items.at(i), i, at: 2)
      stack(
        box(width: w, height: head-h, fill: col, inset: inset, radius: (top: radius),
          align(center + horizon, head.at(i))),
        box(width: w, height: body-h, inset: inset, radius: (bottom: radius),
          fill: if body-fill == auto { col.lighten(75%) } else { body-fill },
          align(left + top, body.at(i))))
    }))
  }))
})
