// Conics
#import "../helpers.typ": *

= Conics

== Ellipse — `ctz-def-ellipse` / `ctz-draw-ellipse`

Define and draw ellipses:

- `ctz-def-ellipse(name, center, rx, ry, angle: 0deg)`
- `ctz-draw-ellipse(center, rx, ry, angle: 0deg, stroke: ..., fill: ...)`
- `ctz-draw(name, ...)` for named ellipses

== Parabola (Focus + Directrix) — `ctz-def-parabola` / `ctz-draw-parabola`

Define and draw parabolas from focus and directrix:

- `ctz-def-parabola(name, focus, directrix, extent: auto, steps: 120)`
- `ctz-draw-parabola(focus, directrix, extent: auto, steps: 120, stroke: ...)`

== Parabola (Focus + p + Angle) — `ctz-draw-parabola-focus`

Draw a parabola using the focus, parameter `p` (vertex-to-focus distance), and opening angle:

- `ctz-draw-parabola-focus(focus, p, angle: 0deg, extent: auto, steps: 120, stroke: ...)`

== Projectile Trajectory — `ctz-def-projectile` / `ctz-draw-projectile`

Define and draw a projectile (parabolic) trajectory:

- `ctz-def-projectile(name, origin, velocity, gravity: 9.81, t-max: auto, steps: 80, y-floor: none, vectors: false, vector-count: 5, vector-scale: 0.12)`
- `ctz-draw-projectile(origin, velocity, gravity: 9.81, t-max: auto, steps: 80, y-floor: none, vectors: false, vector-count: 5, vector-scale: 0.12)`

== Conic Tangents

Draw tangents for conics:

- `ctz-draw-ellipse-tangent(center, rx, ry, t, angle: 0deg, length: auto, stroke: ...)`
- `ctz-draw-parabola-tangent(focus, directrix, t, length: auto, stroke: ...)`
- `ctz-draw-parabola-tangents-from-point(focus, directrix, external, length: auto, stroke: ...)`

== Ellipse Helpers

Descriptive-geometry helpers for ellipse constructions:

- `ctz-ellipse-project-point(center, rx, ry, point, angle: 0deg)` — project a point onto the ellipse along the ray from center
- `ctz-ellipse-tangents-from-point(center, rx, ry, point, angle: 0deg, length: auto)` — tangent lines from an external point
- `ctz-ellipse-circle-intersections(center, rx, ry, circle-center, r, angle: 0deg, steps: 360)` — intersections with a circle (numeric)

== Conics — Visual Example

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()

    // Ellipse with labeled points
    let C = (0, 0)
    let rx = 3
    let ry = 2
    let ang = 20deg
    let (F1, F2) = ellipse-foci-raw(C, rx, ry, angle: ang)
    let P0 = ellipse-angpoint-raw(C, rx, ry, angle: ang, theta: 0deg)
    let P90 = ellipse-angpoint-raw(C, rx, ry, angle: ang, theta: 90deg)

    // Register points for labeling
    ctz-def-points(C: C, F1: F1, F2: F2, P0: P0, P90: P90)

    ctz-draw(ellipse: (C, rx, ry, ang), stroke: black)
    ctz-draw(points: ("C", "F1", "F2", "P0", "P90"), labels: (
      C: (pos: "above left", offset: (-0.1, 0.1)),
      F1: (pos: "below right", offset: (0.1, -0.1)),
      F2: (pos: "below right", offset: (0.1, -0.1)),
      P0: (pos: "right", offset: (0.1, 0)),
      P90: (pos: "above left", offset: (-0.1, 0.1))
    ))

    // Parabola (focus + directrix)
    let F = (-6, -2)
    let D1 = (-8, -4)
    let D2 = (-8, 1)
    ctz-def-points(F: F)
    ctz-draw(parabola: (F, (D1, D2), 4), stroke: blue)
    ctz-draw(points: ("F",), labels: (F: (pos: "right", offset: (0.1, 0.1))))
  })
  ```],
  {
    import cetz.draw: *
    import "@preview/ctz-euclide:0.1.0": *
    ctz-init()
    let C = (0, 0)
    let rx = 3
    let ry = 2
    let ang = 20deg
    let (F1, F2) = ellipse-foci-raw(C, rx, ry, angle: ang)
    let P0 = ellipse-angpoint-raw(C, rx, ry, angle: ang, theta: 0deg)
    let P90 = ellipse-angpoint-raw(C, rx, ry, angle: ang, theta: 90deg)
    ctz-def-points(C: C, F1: F1, F2: F2, P0: P0, P90: P90)

    ctz-draw(ellipse: (C, rx, ry, ang), stroke: black)
    ctz-draw(points: ("C", "F1", "F2", "P0", "P90"), labels: (
      C: (pos: "above left", offset: (-0.1, 0.1)),
      F1: (pos: "below right", offset: (0.1, -0.1)),
      F2: (pos: "below right", offset: (0.1, -0.1)),
      P0: (pos: "right", offset: (0.1, 0)),
      P90: (pos: "above left", offset: (-0.1, 0.1))
    ))

    let F = (-6, -2)
    let D1 = (-8, -4)
    let D2 = (-8, 1)
    ctz-def-points(F: F)
    ctz-draw(parabola: (F, (D1, D2), 4), stroke: blue)
    ctz-draw(points: ("F",), labels: (F: (pos: "right", offset: (0.1, 0.1))))
  },
  length: 0.6cm,
)

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()

    // Parabola from focus + directrix
    ctz-draw(parabola: ((-3, 0), ((-4, -2), (-4, 2)), 3), stroke: black)
    ctz-draw(points: ((-3, 0),), labels: (P: "above"))

    // Parabola from focus + p + angle
    ctz-draw-parabola-focus((2, 0), 0.6, angle: 30deg, extent: 3, stroke: blue)

    // Projectile with vectors
    ctz-draw(projectile: (origin: (0, -3), velocity: (3, 5), y-floor: -3, vectors: true, vector-count: 5), stroke: red)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-draw(parabola: ((-3, 0), ((-4, -2), (-4, 2)), 3), stroke: black)
    ctz-draw-parabola-focus((2, 0), 0.6, angle: 30deg, extent: 3, stroke: blue)
    ctz-draw(projectile: (origin: (0, -3), velocity: (3, 5), y-floor: -3, vectors: true, vector-count: 5), stroke: red)
  },
  length: 0.6cm,
)

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()

    // Ellipse tangent
    ctz-draw(ellipse: ((0, 0), 3, 2, 15deg), stroke: black)
    ctz-draw-ellipse-tangent((0, 0), 3, 2, 45deg, angle: 15deg, stroke: red)

    // Parabola tangents from external point
    let F = (-4, 0)
    let D1 = (-6, -3)
    let D2 = (-6, 3)
    let P = (-1, 1)
    ctz-draw(parabola: (F, (D1, D2), 4), stroke: blue)
    ctz-draw-parabola-tangents-from-point(F, (D1, D2), P, stroke: red)
    ctz-draw(points: (P,), labels: (P: "above"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-draw(ellipse: ((0, 0), 3, 2, 15deg), stroke: black)
    ctz-draw-ellipse-tangent((0, 0), 3, 2, 45deg, angle: 15deg, stroke: red)
    let F = (-4, 0)
    let D1 = (-6, -3)
    let D2 = (-6, 3)
    let P = (-1, 1)
    ctz-draw(parabola: (F, (D1, D2), 4), stroke: blue)
    ctz-draw-parabola-tangents-from-point(F, (D1, D2), P, stroke: red)
    ctz-draw(points: (P,))
  },
  length: 0.6cm,
)

== Circle Through Point — `ctz-draw-circle-through`

Draw a circle with given center passing through a point:

```typst
ctz-draw(circle-through: ("O", "A"), stroke: blue)
```

== Semicircle — `ctz-draw-semicircle`

Draw a semicircle on a diameter:

```typst
ctz-draw(semicircle: ("A", "B"), stroke: blue)
```

#pagebreak()
