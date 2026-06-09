== Cetz drawing
#import "@preview/cetz:0.3.2"

#let cetz-style = {
  import cetz.draw: *
  set-style(
    stroke: 0.8pt,
    mark: (transform-shape: false, fill: black),
  )
}


=== Point
#let point(c) = {
  import cetz.draw: *
  circle(c, radius: 0.05, fill: black)
}


#let point-name((x, y), nom: " ", dc: (-0.3, -0.3)) = {
  import cetz.draw: *
  let (dx, dy) = dc

  circle((x, y), radius: 0.05, fill: black)
  content((x + dx, y + dy), nom)
}


=== Quadratic
#let quadratic(a, b, c) = {
  let Delta = b * b - 4 * a * c

  return (
    (-b - calc.sqrt(Delta)) / (2 * a),
    (-b + calc.sqrt(Delta)) / (2 * a),
  )
}


=== Base
#let base((x_0, y_0), name1: " ", name2: " ", angle: 0deg) = {
  import cetz.draw: *


  line((x_0, y_0), (x_0 + calc.cos(angle), y_0 + calc.sin(angle)))
  line((x, y), (x + calc.sin(angle)), y + calc.cos(angle))
  content(((x + calc.cos(angle)), y + calc.sin(angle) + 0.3), [name1])
  content(((x + calc.sin(angle)), y + calc.cos(angle) + 0.3), [name2])
}
// A revoir


=== Spring
#let spring(x0, y0, xf, yf, rep, amp) = {
  import calc: *
  import cetz.draw: *
  let dist = amp
  if x0 == xf {
    line((x0, y0), (x0 + amp, y0 - (y0 - yf) / (4 * rep)))
    for n in range(2 * rep - 1) {
      line(
        (pow(-1, n) * dist, y0 - (2 * n + 1) * (y0 - yf) / (4 * rep)),
        (pow(-1, n + 1) * dist, y0 - (2 * n + 3) * (y0 - yf) / (4 * rep)),
      )
    }
    line((xf - dist, yf + (y0 - yf) / (4 * rep)), (xf, yf))
  } else if y0 == yf {
    line((x0, y0), (x0 - (x0 - xf) / (4 * rep), y0 + amp))

    for n in range(2 * rep - 1) {
      line(
        (x0 - (2 * n + 1) * (x0 - xf) / (4 * rep), y0 + dist * calc.pow(-1, n)),
        (x0 - (2 * n + 3) * (x0 - xf) / (4 * rep), y0 + dist * calc.pow(-1, n + 1)),
      )
    }
    line((xf + (x0 - xf) / (4 * rep), yf - dist), (xf, yf))
  }
}
