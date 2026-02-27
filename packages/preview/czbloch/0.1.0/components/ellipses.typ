#import "@preview/cetz:0.3.4"

// Number of ellipses per radius unit
#let ellipse-density = 16
#let ellipse-color = luma(235)

#let draw-ellipses(r, sphere-style) = {
  if sphere-style == none {
    return
  }

  import cetz.draw: *
  import calc: cos, sin

  let n = ellipse-density * r

  if sphere-style == "circle" {
    for i in range(n) {
      let alpha = i * (180deg / n)
      let h = r * cos(alpha)
      let v = r * sin(alpha)

      circle((0, 0), radius: (h, r), stroke: ellipse-color)
      circle((0, 0), radius: (r, v), stroke: ellipse-color)
    }

    circle((0, 0), radius: r, stroke: luma(100))

    return
  }

  assert(sphere-style == "sphere", message: "Sphere style must be 'circle' or 'sphere'.")

  on-yz({
    for i in range(n) {
      let alpha = i * (180deg / n)

      rotate(y: alpha)
      circle((0, 0), radius: r, stroke: ellipse-color)
    }
  })
}
