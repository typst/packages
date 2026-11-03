/// Raw data-table primitive — takes explicit parameters only, no state access.
/// ui.typ resolves tokens and passes them here.
#let data-table(
  columns: auto,
  headers: (),
  rows: (),
  border-color: rgb("#e2e8f0"),
  bg-header: rgb("#f8fafc"),
  pad: 0.75em,
  header-size: 0.85em,
  alternating-rows: true,
) = {
  let bg-alt = border-color.lighten(50%)
  let stroke-width = 0.5pt
  let rad = 4pt
  block(
    radius: rad,
    clip: true,
    stroke: stroke-width + border-color,
    table(
      columns: columns,
      stroke: stroke-width + border-color,
      fill: (col, row) => {
        if row == 0 { bg-header } else if alternating-rows and calc.odd(row) {
          bg-alt
        } else { none }
      },
      inset: pad,
      ..headers.map(h => text(weight: "bold", size: header-size)[#h]),
      ..rows.flatten()
    ),
  )
}
