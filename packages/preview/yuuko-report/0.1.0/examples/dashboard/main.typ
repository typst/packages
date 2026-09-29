#import "../../template-landscape.typ": *
#import "../../chart-grids.typ": *

#show: conf.with(
  title: [Calibration Dashboard],
  subtitle: [Complete landscape visualization example],
  authors: ("Yuuko",),
  cover: true,
  toc: true,
)

= Summary

#chart-grid-4((
  chart-card(title: [Average Afterglow])[
    #align(center)[#text(size: 23pt, weight: "bold", fill: theme-color-dark)[1.82%]]
  ],
  chart-card(title: [Passing Channels])[
    #align(center)[#text(size: 23pt, weight: "bold", fill: rgb("#276749"))[124 / 128]]
  ],
  chart-card(title: [Maximum Deviation])[
    #align(center)[#text(size: 23pt, weight: "bold", fill: rgb("#975a16"))[4.26%]]
  ],
  chart-card(title: [Items to Review])[
    #align(center)[#text(size: 23pt, weight: "bold", fill: rgb("#c53030"))[4]]
  ],
))

= Results

#chart-grid-3((
  chart-card(title: [Decay Curve])[
    #chart-placeholder(label: [Time Response], height: 5cm)
  ],
  chart-card(title: [Channel Heatmap])[
    #chart-placeholder(label: [Detector Map], height: 5cm)
  ],
  chart-card(title: [Error Distribution])[
    #chart-placeholder(label: [Histogram], height: 5cm)
  ],
))

= Detailed Analysis

#chart-featured(
  chart-card(title: [Main Result], badge: [Key Result])[
    #chart-placeholder(label: [Featured Chart], height: 8cm)
  ],
  chart-card(title: [Detail A])[
    #chart-placeholder(label: [Detail A], height: 2.8cm)
  ],
  chart-card(title: [Detail B])[
    #chart-placeholder(label: [Detail B], height: 2.8cm)
  ],
)
