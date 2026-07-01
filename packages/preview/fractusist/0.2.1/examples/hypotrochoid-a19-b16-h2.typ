#import "@preview/fractusist:0.2.1": *

#set page(fill: none, width: auto, height: auto, margin: 10pt)

#hypotrochoid(
  19, 16, 2,
  size: 300,
  stroke: none,
  fill: gradient.radial((blue.lighten(80%), 0%), (blue.lighten(40%), 100%)),
  fill-rule: "even-odd"
)
