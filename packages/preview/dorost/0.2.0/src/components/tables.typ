#import "../config.typ": default-colors

// Rows are caller-owned arrays with exactly `columns` cells each. Header mode
// styles/repeats the first row using native table semantics; an empty row collection is valid.
#let data-table(columns, rows, header: true, align: auto) = {
  if type(columns) != int or columns <= 0 {
    panic("dorost: data-table columns must be a positive integer")
  }
  if type(rows) != array { panic("dorost: data-table rows must be an array") }
  for row in rows {
    if type(row) != array or row.len() != columns {
      panic("dorost: every data-table row must contain exactly " + str(columns) + " cells")
    }
  }
  if type(header) != bool { panic("dorost: header must be a boolean") }
  if align != auto and align not in ("auto", "start", "center", "end") {
    panic("dorost: align must be \"auto\", \"start\", \"center\", or \"end\"")
  }
  context {
    let cell-align = if align == auto or align == "auto" { auto }
      else if align == "center" { center }
      else if (align == "start") == (text.dir == ltr) { left }
      else { right }
    let cells = ()
    for (index, row) in rows.enumerate() {
      if header and index == 0 {
        cells.push(table.header(..row.map(cell => strong(cell))))
      } else {
        cells += row
      }
    }
    table(
      columns: (1fr,) * columns, align: cell-align,
      stroke: 0.5pt + default-colors.rule, inset: 0.6em,
      ..cells,
    )
  }
}
