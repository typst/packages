#let threeline-table(
  columns: 2,
  ..args,
  header: (),
  data: (),
) = {
  table(
    columns: columns,
    stroke: none,
    inset: 8pt,
    align: center + horizon,
    ..args,
    table.hline(stroke: 1pt),
    table.header(..header),
    table.hline(stroke: 0.6pt),
    ..data,
    table.hline(stroke: 1pt),
  )
}
