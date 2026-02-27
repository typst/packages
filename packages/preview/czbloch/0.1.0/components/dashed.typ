#import "@preview/cetz:0.3.4"

#import "helpers.typ": cartesian

#let dashed-stroke = (dash: "dashed", paint: luma(180))

#let draw-dashed(r, phi, theta) = {
  import cetz.draw: *
  import calc: sin

  if theta == 0deg or theta == 180deg or theta == 90deg {
    return
  }

  let (x, y, z) = cartesian(r, phi, theta)

  on-xz({
    line((0, 0), (angle: 90deg - phi, radius: r * sin(theta)), stroke: dashed-stroke)
  })

  line(
    (x, y, z),
    (x, 0, z),
    stroke: dashed-stroke,
  )
}
