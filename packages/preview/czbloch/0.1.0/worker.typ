#import "@preview/cetz:0.3.4"

#import "components/helpers.typ": angle-rem
#import "components/lib.typ": *

#let draw-bloch(
  r,
  show-axis,
  phi,
  theta,
  state-color,
  sphere-style,
  angle-labels,
  polar-labels,
) = {
  phi = angle-rem(phi, 360deg)
  theta = angle-rem(theta, 180deg)

  draw-ellipses(r, sphere-style)

  if show-axis {
    let axis-radius = 1.5 * r
    draw-axis(axis-radius)
  }

  draw-dashed(r, phi, theta)
  draw-state(r, phi, theta, state-color)
  draw-angles(r, phi, theta, angle-labels)

  if polar-labels {
    draw-polar-labels()
  }

  import cetz.draw: *
  // Small circle that covers the origin's line intersections
  on-xz({
    circle((0, 0), radius: r / 100, fill: black)
  })
}

#let bloch(
  length: 2cm,
  radius: 1,
  debug: false,
  padding: none,
  show-axis: true,
  phi: 0deg,
  theta: 0deg,
  state-color: rgb("#ae3fee"),
  sphere-style: "circle",
  angle-labels: true,
  polar-labels: true,
) = cetz.canvas(
  draw-bloch(
    radius,
    show-axis,
    phi,
    theta,
    state-color,
    sphere-style,
    angle-labels,
    polar-labels,
  ),
  length: length,
  debug: debug,
  padding: padding,
);
