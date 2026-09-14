#import "@preview/cetz:0.5.0"
#import cetz.draw: *
#import "@preview/astro:0.1.0": *

#set page(width: auto, height: auto, fill: rgb("#050510"))

#cetz.canvas({
  let gap = 3
  let x = 0
  for (body, fn) in (
    ("sun", sun),
    ("mercury", mercury),
    ("venus", venus),
    ("earth", earth),
    ("mars", mars),
    ("jupiter", jupiter),
    ("saturn", saturn),
    ("uranus", uranus),
    ("neptune", neptune),
    ("pluto", pluto),
  ) {
    let r-body = dr.at(body)
    fn(center: (x, 0))
    x = x + r-body + gap
  }
})
