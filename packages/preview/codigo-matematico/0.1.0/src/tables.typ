// Table helpers.


#let table-header-cell(it) = {
  set text(weight: "bold", style: "italic")
  show math.equation: math.bold
  it
}

#let tbl-standard-head = table-header-cell

#let std_table(..items) = {
  show table.cell.where(y: 0): table-header-cell
  align(center)[#table(..items)]
}
