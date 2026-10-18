// Credit to Bluss
// https://forum.typst.app/t/how-can-i-robustly-make-unknown-tables-span-the-full-page-width/4598/3
#import "../lib.typ": *

#let widerow(n, ..args, body: []) = table.cell(colspan: n, inset: 0pt, stroke: none, ..args, block(width: 100%, body))

#let widetable(..args) = {
  let columns = args.at("columns", default: 1)
  let columns = if type(columns) == array { columns.len() } else { columns }
  block(
    radius: 5pt,
    std.table(
      stroke: none,
      fill: (_, row) => if row == 0 { colors.table.header } else if calc.odd(row) { colors.table.row-alt } else { none },
      ..args,
      widerow(columns),
    )
  )
}