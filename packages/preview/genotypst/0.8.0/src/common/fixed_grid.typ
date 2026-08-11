/// Renders a fixed-width grid using the current text font.
///
/// Cells can be passed as raw content or as dictionaries with `body` and
/// optional `fill` and `outset` values. When `cell-width` is none, it is
/// measured from the current font using the wider of "W" and "M".
///
/// - rows (array): 2D array of cell contents or dictionaries.
/// - cell-width (length, none): Fixed cell width (default: none).
/// - row-heights (array, none): Row heights (default: none).
/// - column-gutter (length): Column gap (default: 0pt).
/// - row-gutter (length): Row gap (default: 0pt).
/// - cell-outset (dictionary, none): Outset applied to each cell (default: none).
/// - cell-align (alignment): Cell content alignment (default: center + horizon).
/// -> content
#let _fixed-width-grid(
  rows,
  cell-width: none,
  row-heights: none,
  column-gutter: 0pt,
  row-gutter: 0pt,
  cell-outset: none,
  cell-align: center + horizon,
) = context {
  if rows.len() == 0 { return }

  let row-count = rows.len()
  let col-count = rows.first().len()
  if col-count == 0 { return }
  assert(
    rows.all(row => row.len() == col-count),
    message: "All rows must have the same number of cells.",
  )
  if row-heights != none {
    assert(
      row-heights.len() == row-count,
      message: "row-heights length must match the number of rows.",
    )
  }

  let width = if cell-width == none {
    calc.max(measure(text("W")).width, measure(text("M")).width)
  } else {
    cell-width
  }
  let columns = (width,) * col-count
  let cells = ()

  for (row-index, row) in rows.enumerate() {
    let row-height = if row-heights != none { row-heights.at(row-index) } else {
      none
    }
    for cell in row {
      let body = cell
      let fill = none
      let outset = cell-outset

      if type(cell) == dictionary {
        body = cell.at("body", default: [])
        fill = cell.at("fill", default: none)
        outset = cell.at("outset", default: outset)
      }

      let content = if body == none { [] } else { body }
      cells.push(box(
        width: width,
        ..(if row-height != none { (height: row-height) } else { () }),
        fill: fill,
        outset: if outset == none { (:) } else { outset },
        align(cell-align, content),
      ))
    }
  }

  grid(
    columns: columns,
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    ..(if row-heights != none { (rows: row-heights) } else { () }),
    ..cells,
  )
}
