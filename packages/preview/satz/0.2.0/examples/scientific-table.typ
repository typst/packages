#import "@preview/satz:0.2.0": report, scientific-table, scientific-tables
#show: report.with(config: (toc: (depth: 0), lot: (depth: 0)))
#show: scientific-tables

= Results

#figure(
  scientific-table(
    columns: 3,
    align: (left, right, right),
    header: ([Condition], [Mean], [SEM]),
    [Baseline], [0.12], [0.03],
    [Treatment], [0.38], [0.05],
    table.hline(stroke: 0.5pt),
    [Difference], [0.26], [0.06],
  ),
  kind: table,
  caption: [Results with a separate summary row.],
) <results>

@results uses horizontal rules to separate column headings and row groups.
