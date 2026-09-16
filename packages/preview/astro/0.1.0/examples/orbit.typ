#import "@preview/cetz:0.5.0"
#import "@preview/astro:0.1.0": *
#import cetz.draw: *

#set page(width: auto, height: auto, fill: rgb("#050510"), margin: 20pt)

#cetz.canvas({
  let center-e = (0, 0)
  let center-m = (3.5, 3)
  let r = cetz.vector.dist(center-e, center-m)

  // create dashed orbit
  circle(center-e, radius: r, stroke: (dash: "dashed", paint: rgb("#fff")))
  
  // draw bodies
  earth(center: center-e)
  moon(center: center-m)
})
