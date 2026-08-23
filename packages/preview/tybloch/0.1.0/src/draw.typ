#import calc: round
#import "@preview/cetz:0.5.2"
#import "@preview/physica:0.9.8": ket
#import "utils.typ": (
  axis-rotation-interpolation, linspace, scalar-prod, spherical-linear-interpolation, spherical-to-cartesian,
)


// Draws the axes and dashed circles for the three planes
#let _draw-axes() = {
  import cetz.draw: circle, content, line, on-xy, on-xz, on-zy

  // XY plane
  on-xy({
    circle(
      (0, 0),
      radius: 2,
      stroke: (dash: "dashed", cap: "round", paint: gray.transparentize(50%)),
    )
  })

  // XZ plane
  on-xz(
    circle(
      (0, 0),
      radius: 2,
      stroke: (dash: "dashed", cap: "round", paint: gray.transparentize(50%)),
    ),
  )

  // YZ plane
  on-zy({
    circle(
      (0, 0),
      radius: 2,
      stroke: (dash: "dashed", cap: "round", paint: gray.transparentize(50%)),
    )
  })

  // X negative axis
  line((0, 0, 0), (-2.75, 0, 0), stroke: gray, mark: (end: ")>"), fill: gray, name: "-x")
  content("-x.end", (rel: (-1, .3, 0)), text(fill: gray)[$-x$])

  // X positive axis
  line((0, 0, 0), (2.75, 0, 0), mark: (end: ")>"), fill: black, name: "x")
  content("x.end", (rel: (.3, -.1, 0)), [$x$])

  // Y negative axis
  line((0, 0, 0), (0, -2.5, 0), mark: (end: ")>"), stroke: gray, fill: gray, name: "-y")
  content("-y.end", (rel: (.8, 0, .7)), text(fill: gray)[$-y$])

  // Y positive axis
  line((0, 0, 0), (0, 2.5, 0), mark: (end: ")>"), fill: black, name: "y")
  content("y.end", (rel: (0, .1, .2)), [$y$])

  // Z negative axis
  line((0, 0, 0), (0, 0, -2.5), mark: (end: ")>"), fill: gray, stroke: gray, name: "-z")
  content("-z.end", (rel: (.3, -.1, 0)), text(fill: gray)[$-z$])

  // Z positive axis
  line((0, 0, 0), (0, 0, 2.5), mark: (end: ")>"), fill: black, name: "z")
  content("z.end", (rel: (.5, .5, .4)), [$z$])

  // Poles
  circle((0, 0, 2), radius: 0.1, fill: gray, stroke: none)
  circle((0, 0, -2), radius: 0.1, fill: gray, stroke: none)
  content("z.end", (rel: (1.1, .4, 0)), [$ket(0)$])
  content("-z.end", (rel: (-1.5, -.1, 0)), $ket(1)$)
}


// Draws the state at given coordinates
#let _draw-state(x, y, z, color: red, show-projections: true) = {
  import cetz.draw: line

  // The state
  line((0, 0, 0), (x, y, z), stroke: color, mark: (end: ")>"), fill: color, name: "state")

  // Projections
  if show-projections {
    if round(z, digits: 2) != 0 {
      line(
        (0, 0, 0),
        (x, y, 0),
        stroke: (paint: color.transparentize(50%), dash: "dashed"),
        name: "xy-proj",
      )
    } else {
      // Transparent line so that the label exists
      line(
        (0, 0, 0),
        (x, y, 0),
        stroke: (paint: color.transparentize(100%)),
        name: "xy-proj",
      )
    }
    if round(z, digits: 4) != 2 {
      line(
        (x, y, z),
        (x, y, 0),
        stroke: (paint: color.transparentize(50%), dash: "dashed"),
      )
    }
  }
}


// Draws a series of state vectors to show evolution between an initial and a final state
#let _draw-state-evolution(
  /// -> array
  start-state,
  /// -> array
  final-state: none,
  /// -> array
  rotation-axis: none,
  /// -> angle
  rotation-angle: none,
  /// -> int
  number-of-shadows: none,
  /// -> color
  state-color: none,
) = {
  let states = if rotation-axis != none and rotation-angle != none {
    axis-rotation-interpolation(start-state, rotation-axis, rotation-angle, number-of-shadows)
  } else {
    spherical-linear-interpolation(start-state, final-state, number-of-shadows)
  }
  let opacity-range = linspace(70%, 0%, number-of-shadows)
  for i in range(number-of-shadows) {
    let state = scalar-prod(states.at(i), 2)
    _draw-state(..state, color: state-color.transparentize(opacity-range.at(i)), show-projections: false)
  }
}


// Main drawing function, handles the orthographic projection
#let _draw-bloch(
  r,
  theta,
  phi,
  state-color,
  show-projections,
  evolution: false,
  final-state: none,
  rotation-axis: none,
  rotation-angle: none,
  number-of-shadows: none,
) = cetz.canvas({
  import cetz.draw: circle, ortho

  let (x, y, z) = spherical-to-cartesian(r, theta, phi)
  ortho(
    x: -90deg + 20deg,
    y: 0deg,
    z: -90deg - 20deg,
    {
      _draw-axes()
      if evolution {
        _draw-state-evolution(
          (r, theta, phi),
          final-state: final-state,
          rotation-axis: rotation-axis,
          rotation-angle: rotation-angle,
          number-of-shadows: number-of-shadows,
          state-color: state-color,
        )
      } else {
        _draw-state(x, y, z, color: state-color, show-projections: show-projections)
      }
    },
  )
  // Main circle of the sphere
  circle((0, 0), radius: 2, stroke: (thickness: 1pt, paint: gray))

  // Small circle at center to hide line overlap
  circle((0, 0), radius: .04, fill: black, stroke: none)
})
