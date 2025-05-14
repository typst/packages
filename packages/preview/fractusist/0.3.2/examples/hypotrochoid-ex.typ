#import "@preview/fractusist:0.3.2": *

#set page(fill: none, width: auto, height: auto, margin: 0pt)

#hypotrochoid(
  19, 16, 2,
  size: 250,
  padding: 10,
  stroke: none,
  fill: gradient.radial((blue.lighten(80%), 0%), (blue.lighten(40%), 100%)),
  fill-rule: "even-odd"
)
