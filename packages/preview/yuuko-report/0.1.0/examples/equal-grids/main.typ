#import "../../template-landscape.typ": *
#import "../_shared.typ": *

#show: conf.with(
  title: [Equal-width Chart Grids],
  cover: false,
  toc: true,
)

= Two Columns

#chart-grid-2((
  demo-card([Before Calibration], [Before]),
  demo-card([After Calibration], [After]),
))

= Three Columns

#chart-grid-3((
  demo-card([Decay Curve], [Curve], height: 4cm),
  demo-card([Channel Heatmap], [Heatmap], height: 4cm),
  demo-card([Error Histogram], [Histogram], height: 4cm),
))

= Four Columns

#chart-grid-4((
  demo-card([Exposure 1], [Chart 1], height: 3cm),
  demo-card([Exposure 2], [Chart 2], height: 3cm),
  demo-card([Exposure 3], [Chart 3], height: 3cm),
  demo-card([Exposure 4], [Chart 4], height: 3cm),
))

