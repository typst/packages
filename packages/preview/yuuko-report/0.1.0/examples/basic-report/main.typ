#import "../../template-landscape.typ": *
#import "../../chart-grids.typ": *

#show: conf.with(
  title: [Yuuko Report],
  subtitle: [Basic landscape report example],
  authors: ("Author",),
  cover: true,
  toc: true,
)

= Overview

This is the smallest complete example. It combines the landscape report template with a three-column chart layout.

#chart-grid-3((
  chart-card(title: [Chart A])[
    #chart-placeholder(label: [Chart A], height: 4.5cm)
  ],
  chart-card(title: [Chart B])[
    #chart-placeholder(label: [Chart B], height: 4.5cm)
  ],
  chart-card(title: [Chart C])[
    #chart-placeholder(label: [Chart C], height: 4.5cm)
  ],
))

= Wide Table

#table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  table.header([*Channel*], [*Before*], [*After*], [*Limit*], [*Status*]),
  [CH-001], [2.41%], [1.82%], [3.00%], [Pass],
  [CH-064], [4.62%], [4.26%], [3.00%], [Review],
  [CH-128], [2.94%], [2.11%], [3.00%], [Pass],
)

