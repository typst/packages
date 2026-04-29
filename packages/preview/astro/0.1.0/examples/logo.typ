#import "@preview/cetz:0.5.0"
#import cetz.draw: *
#import "@preview/astro:0.1.0": *

#set page(width: auto, height: auto, fill: none, margin: 0pt)

#let sz = 160pt

#box(
  fill: rgb("#050510"),
  radius: 50%,
  clip: true,
  width: sz,
  height: sz,
  align(center + horizon,
    cetz.canvas(length: 28pt, {
      earth(center: (0, 0), radius: 2.0, phase: "waxing gibbous", name: "")
      moon(center: (1.5, -1.2), radius: 0.55, phase: "waxing gibbous", name: "")
    })
  )
)
