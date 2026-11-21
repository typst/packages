// Reusable "card" table: rounded cells with gaps, a coloured header and alternating
// row tints, centred text.  Import with:  #import "table.typ": card-table, card-row
//
//   #card-table(
//     ("Study", "Behavior used", "Approach", "Environment", "Dataset", "Indicators"),
//     (
//       ([Guo et al. (2023)], [Arm movements...], [Propose two...], [Mobile devices], [Homemade], [CDF, ...]),
//       card-row(([Gurunathan (2024)], [PPG], [Exhaustive...], [Not specified], [PUT Vein], [FRR, ...]), fill: red),
//     ),
//   )
//
// Every cell in a row gets the same height (= tallest cell), so the cards line
// up. `weights` sets relative column widths (default: all equal).
#import "common.typ": _card, _fluid, _lens, _on, _theme, _txt

#let card-row(cells, fill: none, text-fill: none) = (
  _card-row: true,
  cells: cells,
  fill: fill,
  text-fill: text-fill,
)

#let card-table(
  headers,
  rows,
  weights: none,
  header-fill: auto,
  row-fills: auto,
  gap: 0.5em,
  inset: 0.7em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("card-table", theme, style)
  let (gap, inset, size) = _lens("card-table", gap: gap, inset: inset, text-size: text-size).values()
  if not (type(headers) == array and headers.len() > 0) { assert(false, message: "card-table: needs at least 1 header, got "
    + repr(headers)) }
  let n = headers.len()
  let weights = if weights == none { (1,) * n } else { weights }
  if not (weights.len() == n) { assert(false, message: "card-table: `weights` needs one number per column (" + str(n) + "), got "
    + repr(weights)) }
  let avail = _fluid("card-table", width, area) - gap * (n - 1)
  let colw = weights.map(x => avail * x / weights.sum())
  let header-fill = if header-fill == auto { t.palette.first() } else { header-fill }
  let row-fills = if row-fills == auto { (color.mix((t.panel, 50%), (t.surface, 50%)), t.panel) } else { row-fills }

  let row-block(cells, fill, ink, weight) = {
    let cells = cells.map(c => _txt(c, ink, size, weight: weight))
    let row-h = calc.max(..cells.enumerate().map(((i, c)) => measure(c, width: colw.at(i) - 2 * inset).height)) + 2 * inset
    stack(dir: ltr, spacing: gap, ..cells.enumerate().map(((i, c)) =>
      _card(t, width: colw.at(i), height: row-h, fill: fill, radius: t.corner-radius, inset: inset,
        align(center + horizon, c))))
  }
  stack(dir: ttb, spacing: gap, row-block(headers, header-fill, _on(t, header-fill), "bold"),
    ..rows.enumerate().map(((i, r)) => {
      // a row is an array of cells or a card-row with its own colours
      let own = type(r) == dictionary and r.at("_card-row", default: false)
      let cells = if own { r.cells } else { r }
      if not (type(cells) == array and cells.len() == n) { assert(false, message: "card-table: row " + str(i + 1) + " must have "
        + str(n) + " cells, got " + repr(cells)) }
      let fill = if own and r.fill != none { r.fill } else { row-fills.at(calc.rem(i, row-fills.len())) }
      row-block(cells, fill, if own and r.text-fill != none { r.text-fill } else { _on(t, fill) }, auto)
    }))
})
