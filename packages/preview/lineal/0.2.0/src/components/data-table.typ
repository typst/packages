#import "../brand.typ": colour

/// A table with a repeating header, subtle row rules and zero-based row accents.
#let data-table(
  headers,
  rows,
  columns: auto,
  align: left,
  highlight: (),
  striped: true,
  accent: colour.primary,
  ink: colour.neutral-dark,
  header-fill: auto,
  header-ink: white,
  fill: white,
  stripe-fill: rgb("#f3f5f6"),
  highlight-fill: auto,
  rule: rgb("#dce1e4"),
  size: .85em,
  inset: (x: .7em, y: .6em),
) = {
  assert(type(headers) == array and headers.len() > 0, message: "data-table needs a non-empty headers array")
  assert(type(rows) == array, message: "data-table rows must be an array")
  assert(rows.all(row => type(row) == array and row.len() == headers.len()), message: "every data-table row must match the header count")
  let valid-cell(value) = value == none or type(value) in (content, str, int, float, bool)
  assert(headers.all(valid-cell) and rows.all(row => row.all(valid-cell)), message: "data-table cells must be content, strings, numbers, booleans or none")
  assert(type(highlight) == array and highlight.all(index => type(index) == int and index >= 0 and index < rows.len()), message: "data-table highlight indices must refer to existing zero-based rows")
  if columns != auto {
    assert(type(columns) == array and columns.len() == headers.len(), message: "data-table columns must match the header count")
  }
  let display(value) = {
    if value == none { return [] }
    if type(value) == bool { return repr(value) }
    if type(value) in (int, float) { return str(value) }
    value
  }
  let header-fill = if header-fill == auto { accent } else { header-fill }
  let highlight-fill = if highlight-fill == auto { accent.lighten(90%) } else { highlight-fill }
  set text(size: size, fill: ink)
  set par(spacing: .55em, leading: .4em)
  table(
    columns: if columns == auto { (1fr,) * headers.len() } else { columns },
    align: align, inset: inset,
    stroke: (x: none, y: .5pt + rule),
    fill: (_, y) => {
      if y == 0 { return header-fill }
      if (y - 1) in highlight { return highlight-fill }
      if striped and calc.rem(y, 2) == 0 { return stripe-fill }
      fill
    },
    table.header(..headers.map(value => text(weight: "semibold", fill: header-ink, display(value)))),
    ..rows.flatten().map(display),
  )
}
