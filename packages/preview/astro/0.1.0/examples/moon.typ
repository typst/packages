#import "@preview/cetz:0.5.0"
#import cetz.draw: *
#import "@preview/astro:0.1.0": *

#set page(width: auto, height: auto, fill: rgb("#050510"), margin: 20pt)

#cetz.canvas({
  let x = 0
  let r = dr.at("moon")
  for phase in (
    "new",
    "first crescent",
    "first half",
    "waxing gibbous",
    "full",
    "waning gibbous",
    "last half",
    "last crescent",
  ) {
    moon(center: (x, 0), phase: phase, name: phase)
    x = x + 2 * r + 1
  }
})
