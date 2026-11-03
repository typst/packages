#import "@preview/drafting:0.2.2": *

#let todoColors = (
  VV: rgb("#f88605"),
)

#let margin-vv = margin-note.with(
  stroke: todoColors.VV,
  fill: todoColors.VV.lighten(90%),
)

#let inline-vv = inline-note.with(
  stroke: todoColors.VV,
  fill: todoColors.VV.lighten(90%),
)

