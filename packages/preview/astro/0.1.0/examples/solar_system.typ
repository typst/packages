#import "@preview/cetz:0.5.0"
#import "@preview/suiji:0.5.1": *
#import "@preview/astro:0.1.0": *
#import cetz.draw: *

#set page(width: auto, height: auto, fill: rgb("#050510"), margin: 20pt)

#cetz.canvas({
  let center = (0, 0)
  let gap = 3
  let x = 0

  let rng = gen-rng-f(4)
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
    let (rng2, theta) = uniform-f(rng, low: 0.0, high: 2 * calc.pi)
    rng = rng2
    let a = center.at(0) + x * calc.cos(theta)
    let b = center.at(1) + x * calc.sin(theta)
    
    circle((0, 0), radius: x, stroke: (paint: rgb("#fff")))
    fn(center: (a, b), name: "")
    
    // update radius
    x = x + dr.at(body) + gap
  }
})
