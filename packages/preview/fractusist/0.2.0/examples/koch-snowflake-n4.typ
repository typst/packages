#import "@preview/fractusist:0.2.0": *

#set page(fill: none, width: auto, height: auto, margin: 10pt)

#koch-snowflake(
  4,
  step-size: 3,
  fill: gradient.radial((blue.lighten(50%), 0%), (white, 100%)),
  stroke: gray
)
