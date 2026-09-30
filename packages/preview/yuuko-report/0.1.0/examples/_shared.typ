#import "../chart-grids.typ": *

#let demo-card(title, label, height: 4.5cm, badge: none) = chart-card(
  title: title,
  subtitle: [Replace this placeholder with image, plot, table, or diagram content.],
  badge: badge,
)[
  #chart-placeholder(label: label, height: height)
]

