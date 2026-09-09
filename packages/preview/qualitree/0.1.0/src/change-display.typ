// Revision colors indicate edit operations, never relationship strength. Dark
// symbols and explicit +/−/~ marks keep the meaning available without color.
#import "text.typ": _as-content

#let change-fill(status, style) = if status == "unchanged" { none } else { style.at(status + "-fill") }
#let change-mark(status) = (unchanged: "", added: "+", removed: "−", changed: "~").at(status)
#let changed-label(label, status) = if status == "unchanged" { _as-content(label) } else {
  [#strong(change-mark(status)) #_as-content(label)]
}
#let row-status(data, index) = if data.changes == none { "unchanged" } else { data.changes.rows.at(index) }
#let column-status(data, index) = if data.changes == none { "unchanged" } else { data.changes.columns.at(index) }
#let cell-status(data, row, column) = if data.changes == none { "unchanged" } else {
  data.changes.cells.at(row).at(column)
}
#let fill-cell(x, y, width, height, status, style) = {
  let fill = change-fill(status, style)
  if fill != none { place(top + left, dx: x, dy: y, rect(width: width, height: height, fill: fill, stroke: none)) }
}
