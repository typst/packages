// layout: fields -> positioned segments, one field clipped to each row it
// touches. Pure, no cetz. `col-start`/`col-end` are 0-based columns within the
// row; `continued`/`continues` mark a field that arrived from / carries on to an
// adjacent row. `kind` and `fill` carry through for the renderer.

#let layout(fields, bits-per-row: 32) = {
  let segments = ()
  for f in fields {
    let row-start = int(f.start / bits-per-row)
    let row-end = int(f.end / bits-per-row)
    for r in range(row-start, row-end + 1) {
      let row-lo = r * bits-per-row
      let bit-start = calc.max(f.start, row-lo)
      let bit-end = calc.min(f.end, row-lo + bits-per-row - 1)
      segments.push((
        kind: f.kind,
        row: r,
        col-start: bit-start - row-lo,
        col-end: bit-end - row-lo,
        label: f.label,
        fill: f.at("fill", default: none),
        continued: r > row-start,
        continues: r < row-end,
      ))
    }
  }
  segments
}
