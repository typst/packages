#import "@preview/yuuko-report:0.1.0": *

#show: conf.with(
  title: [Yuuko Report],
  subtitle: [Portrait and landscape technical reports],
  authors: ("Author",),
  cover: false,
  toc: false,
)

= Visualization Dashboard

#chart-grid-3((
  chart-card(title: [Decay Curve], badge: [Stable])[
    #chart-placeholder(label: [Time Response], height: 4.3cm)
  ],
  chart-card(title: [Channel Heatmap])[
    #chart-placeholder(label: [Detector Map], height: 4.3cm)
  ],
  chart-card(title: [Error Distribution])[
    #chart-placeholder(label: [Histogram], height: 4.3cm)
  ],
))

#v(12pt)

#chart-featured(
  chart-card(title: [Main Result])[
    #chart-placeholder(label: [Featured Chart], height: 6cm)
  ],
  chart-card(title: [Detail A])[
    #chart-placeholder(label: [Detail], height: 2.2cm)
  ],
  chart-card(title: [Detail B])[
    #chart-placeholder(label: [Detail], height: 2.2cm)
  ],
)
