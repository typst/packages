#import "../../template-landscape.typ": *
#import "../../chart-grids.typ": *

#show: conf.with(
  title: [Portrait Technical Report],
  subtitle: [The same package can also use standard A4 portrait pages],
  authors: ("Author",),
  orientation: "portrait",
  cover: true,
  toc: true,
)

= Overview

The chart helpers are independent of page orientation. On portrait pages, two-column layouts are generally easier to read.

#chart-grid-2((
  chart-card(title: [Decay Curve])[
    #chart-placeholder(label: [Curve], height: 5cm)
  ],
  chart-card(title: [Error Distribution])[
    #chart-placeholder(label: [Histogram], height: 5cm)
  ],
))

= Single Wide Chart

#chart-card(title: [All-channel Trend])[
  #chart-placeholder(label: [Wide Chart], height: 7cm)
]

= Notes

- Use `orientation: "portrait"` for text-heavy reports.
- Use `orientation: "landscape"` for dashboards, wide tables, and many charts.
- The same `chart-card` and `chart-grid-*` helpers work in both modes.

