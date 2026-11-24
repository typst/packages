#import "@preview/elembic:1.1.1" as e

// `auto` is the existing number column, not a second numbering system.
#let columns(spec, enabled) = {
  let result = ()
  for column in (if spec == auto { (auto,) } else { spec }) {
    if column == auto {
      if enabled { result.push(auto) }
    } else { result.push(e.fields(column)) }
  }
  result
}

#let value(column, row) = {
  let values = column.values
  let value = if type(values) == function { values(row) } else if row.kind == "code" {
    values.at(row.source-line - 1, default: none)
  } else { none }
  assert(
    value == none or type(value) in (content, str, int, float),
    message: "codly: gutter values must be content, strings, numbers, or none",
  )
  value
}

#let cells(columns, row, number, constructor, parent) = {
  columns.map(column => {
    if column == auto { return constructor(number, parent) }
    let value = value(column, row)
    let fields = (:)
    for name in ("align", "inset", "stroke") {
      if column.at(name) != auto { fields.insert(name, column.at(name)) }
    }
    grid.cell(..fields, if value != none { text(..column.text)[#value] })
  })
}

// Resolve callbacks before layout, as with body fills. Header/footer cells
// own their paints; callouts span the gutters rather than creating gutter cells.
#let fills(columns, rows, body, number-fill, source: ()) = columns.map(column => rows.map(row => {
  if row.kind not in ("code", "skip") { return body.at(row.index, default: none) }
  let fill = if column == auto { number-fill } else { column.fill }
  if fill == auto { return body.at(row.index, default: none) }
  if type(fill) == array {
    assert(fill.len() > 0, message: "codly: gutter fill palettes must not be empty")
    return fill.at(calc.rem(row.index, fill.len()))
  }
  if type(fill) == function {
    return fill(
      row
        + (
          text: if row.source-line == none { none } else {
            source.at(row.source-line - 1, default: none)
          },
        ),
    )
  }
  fill
}))
