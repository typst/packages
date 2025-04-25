#import "@preview/fractusist:0.3.2": *

#set page(fill: none, width: auto, height: auto, margin: 0pt)

#lsystem(
  ..lsystem-use("Koch Snowflake"),
  order: 4,
  step-size: 2,
  start-angle: 0,
  padding: 10,
  fill: gradient.radial((blue.lighten(50%), 0%), (white, 100%)),
  stroke: gray
)
