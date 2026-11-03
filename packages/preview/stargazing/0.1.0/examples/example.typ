#import "../lib.typ": regression-table

#let data = json("results.json")

#regression-table(
  data.models,
  labels: data.labels,
  stats: ("N", "R2", "Fixed effects"),
)
