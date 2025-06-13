#import "@preview/unify:0.7.1": unit as _unit
#import "@preview/tablem:0.2.0": tablem, three-line-table as _three-line-table

#let unit(it) = _unit(it, per: "\/")

#let two-line-table = tablem.with(
  ignore-second-row: false,
  use-table-header: false,
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: none,
      align: center + horizon,
      table.hline(y: 0, stroke: .5pt),
      ..args,
      table.hline(stroke: .5pt),
    )
  },
)

#let three-line-table = _three-line-table.with(ignore-second-row: false)
