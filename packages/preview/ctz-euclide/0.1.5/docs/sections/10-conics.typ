// Conics
#import "../helpers.typ": *

= Conics

This section covers ellipses, parabolas, and projectile trajectories. Like circles, every conic drawing method has a corresponding define function for storing named objects.

== Define vs Draw Pattern

For each conic type, you can either define it as a named object (for later use in intersections or transformations) or draw it directly:

```typst
// Approach 1: Define then draw (reusable)
ctz-def-ellipse("E", (0, 0), 3, 2, angle: 20deg)
ctz-draw("E", stroke: blue)

// Approach 2: Draw directly (one-off)
ctz-draw(ellipse: ((0, 0), 3, 2, 20deg), stroke: blue)
```

== Ellipse — `ctz-def-ellipse`

Define an ellipse by center, x-radius, y-radius, and optional rotation angle.

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-ellipse("E", (0, 0), 3, 2, angle: 20deg)
    ctz-draw("E", stroke: blue)

    // Get the foci
    ctz-def-ellipse-foci("F1", "F2", (0, 0), 3, 2, angle: 20deg)
    ctz-draw(points: ("F1", "F2"), labels: (F1: "below", F2: "below"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-ellipse("E", (0, 0), 3, 2, angle: 20deg)
    ctz-draw("E", stroke: blue)
    ctz-def-ellipse-foci("F1", "F2", (0, 0), 3, 2, angle: 20deg)
    ctz-draw(points: ("F1", "F2"), labels: (F1: "below", F2: "below"))
  },
)

Unnamed equivalent:
```typst
ctz-draw(ellipse: ((0, 0), 3, 2, 20deg), stroke: blue)
```

== Ellipse Foci — `ctz-def-ellipse-foci`

Define the two foci of an ellipse as named points:

```typst
ctz-def-ellipse-foci("F1", "F2", center, rx, ry, angle: 0deg)
```

== Parabola (Focus + Directrix) — `ctz-def-parabola`

Define a parabola using its focus and directrix line.

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(F: (0, 0), D1: (-2, -3), D2: (-2, 3))
    ctz-def-parabola("P", "F", ("D1", "D2"), extent: 4)
    ctz-draw("P", stroke: blue)

    // Draw directrix and focus
    ctz-draw(segment: ("D1", "D2"), stroke: gray)
    ctz-draw(points: ("F",), labels: (F: "right"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(F: (0, 0), D1: (-2, -3), D2: (-2, 3))
    ctz-def-parabola("P", "F", ("D1", "D2"), extent: 4)
    ctz-draw("P", stroke: blue)
    ctz-draw(segment: ("D1", "D2"), stroke: gray)
    ctz-draw(points: ("F",), labels: (F: "right"))
  },
)

Unnamed equivalent:
```typst
ctz-draw(parabola: ("F", ("D1", "D2"), 4), stroke: blue)
```

== Parabola (Focus + p + Angle) — `ctz-def-parabola-focus`

Define a parabola using the focus, parameter p (vertex-to-focus distance), and opening angle.

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-parabola-focus("P1", (0, 0), 1, angle: 0deg, extent: 3)
    ctz-def-parabola-focus("P2", (0, 0), 1, angle: 90deg, extent: 3)

    ctz-draw("P1", stroke: blue)
    ctz-draw("P2", stroke: red)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-parabola-focus("P1", (0, 0), 1, angle: 0deg, extent: 3)
    ctz-def-parabola-focus("P2", (0, 0), 1, angle: 90deg, extent: 3)
    ctz-draw("P1", stroke: blue)
    ctz-draw("P2", stroke: red)
  },
)

== Projectile Trajectory — `ctz-def-projectile`

Define a projectile (parabolic) trajectory from initial position and velocity.

#example(
  [```typst
  #ctz-canvas(length: 0.5cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-projectile("proj", (0, 0), (4, 6),
      gravity: 9.81, y-floor: 0, vectors: true, vector-count: 5)
    ctz-draw("proj", stroke: blue)

    // Draw ground
    ctz-draw(segment: ((-1, 0), (6, 0)), stroke: gray)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-projectile("proj", (0, 0), (4, 6),
      gravity: 9.81, y-floor: 0, vectors: true, vector-count: 5)
    ctz-draw("proj", stroke: blue)
    ctz-draw(segment: ((-1, 0), (6, 0)), stroke: gray)
  },
  length: 0.5cm,
)

Unnamed equivalent:
```typst
ctz-draw(projectile: (origin: (0, 0), velocity: (4, 6), y-floor: 0, vectors: true), stroke: blue)
```

Parameters:
- `origin`: Starting position
- `velocity`: Initial velocity vector (vx, vy)
- `gravity`: Gravitational acceleration (default 9.81)
- `y-floor`: Optional ground level (trajectory stops here)
- `vectors`: Show velocity vectors along path
- `vector-count`, `vector-scale`: Vector display options

#pagebreak()

== Conic Tangent Lines

Define tangent lines to conics as named line objects for use in intersections.

=== Ellipse Tangent at Parameter — `ctz-def-ellipse-tangent`

Define the tangent line at parameter t (angle) on an ellipse:

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-ellipse("E", (0, 0), 3, 2)
    ctz-def-ellipse-tangent("T1", (0, 0), 3, 2, 45deg)
    ctz-def-ellipse-tangent("T2", (0, 0), 3, 2, 135deg)

    ctz-draw("E", stroke: blue)
    ctz-draw("T1", stroke: red)
    ctz-draw("T2", stroke: red)
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-ellipse("E", (0, 0), 3, 2)
    ctz-def-ellipse-tangent("T1", (0, 0), 3, 2, 45deg)
    ctz-def-ellipse-tangent("T2", (0, 0), 3, 2, 135deg)
    ctz-draw("E", stroke: blue)
    ctz-draw("T1", stroke: red)
    ctz-draw("T2", stroke: red)
  },
)

=== Ellipse Tangents from External Point — `ctz-def-ellipse-tangents-from`

Define both tangent lines from an external point to an ellipse:

#example(
  [```typst
  #ctz-canvas(length: 0.7cm, {
    import cetz.draw: *
    ctz-init()

    ctz-def-points(P: (4, 2))
    ctz-def-ellipse("E", (0, 0), 2.5, 1.5)
    ctz-def-ellipse-tangents-from("T1", "T2", (0, 0), 2.5, 1.5, "P")

    ctz-draw("E", stroke: blue)
    ctz-draw("T1", stroke: red)
    ctz-draw("T2", stroke: red)
    ctz-draw(points: ("P",), labels: (P: "above right"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(P: (4, 2))
    ctz-def-ellipse("E", (0, 0), 2.5, 1.5)
    ctz-def-ellipse-tangents-from("T1", "T2", (0, 0), 2.5, 1.5, "P")
    ctz-draw("E", stroke: blue)
    ctz-draw("T1", stroke: red)
    ctz-draw("T2", stroke: red)
    ctz-draw(points: ("P",), labels: (P: "above right"))
  },
)

=== Parabola Tangent at Parameter — `ctz-def-parabola-tangent`

Define the tangent line at parameter t on a parabola:

```typst
ctz-def-parabola-tangent("T", focus, directrix, t, length: auto)
```

=== Parabola Tangents from External Point — `ctz-def-parabola-tangents-from`

Define both tangent lines from an external point to a parabola:

#example(
  [```typst
  #ctz-canvas(length: 0.6cm, {
    import cetz.draw: *
    ctz-init()

    // Note: P must be outside the parabola (on directrix side)
    ctz-def-points(F: (0, 0), D1: (-2, -3), D2: (-2, 3), P: (-3, 1))
    ctz-def-parabola("para", "F", ("D1", "D2"), extent: 4)
    ctz-def-parabola-tangents-from("T1", "T2", "F", ("D1", "D2"), "P")

    ctz-draw("para", stroke: blue)
    ctz-draw("T1", stroke: red)
    ctz-draw("T2", stroke: red)
    ctz-draw(points: ("F", "P"), labels: (F: "right", P: "left"))
  })
  ```],
  {
    import cetz.draw: *
    ctz-init()
    ctz-def-points(F: (0, 0), D1: (-2, -3), D2: (-2, 3), P: (-3, 1))
    ctz-def-parabola("para", "F", ("D1", "D2"), extent: 4)
    ctz-def-parabola-tangents-from("T1", "T2", "F", ("D1", "D2"), "P")
    ctz-draw("para", stroke: blue)
    ctz-draw("T1", stroke: red)
    ctz-draw("T2", stroke: red)
    ctz-draw(points: ("F", "P"), labels: (F: "right", P: "left"))
  },
  length: 0.6cm,
)

#pagebreak()

== Summary: Conic Functions

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  stroke: 0.5pt + luma(80%),
  inset: 6pt,
  [*Define Function*], [*Draw Shorthand*], [*Description*],
  [`ctz-def-ellipse(name, center, rx, ry, angle)`], [`ellipse: (center, rx, ry, angle)`], [Ellipse],
  [`ctz-def-ellipse-foci(n1, n2, center, rx, ry, angle)`], [—], [Ellipse foci (points)],
  [`ctz-def-ellipse-tangent(name, center, rx, ry, t, ...)`], [—], [Tangent line at parameter],
  [`ctz-def-ellipse-tangents-from(n1, n2, center, rx, ry, pt, ...)`], [—], [Tangents from point (lines)],
  [`ctz-def-parabola(name, focus, directrix, ...)`], [`parabola: (focus, directrix, extent)`], [Parabola (focus+directrix)],
  [`ctz-def-parabola-focus(name, focus, p, angle, ...)`], [—], [Parabola (focus+p+angle)],
  [`ctz-def-parabola-tangent(name, focus, directrix, t, ...)`], [—], [Tangent line at parameter],
  [`ctz-def-parabola-tangents-from(n1, n2, focus, dir, pt, ...)`], [—], [Tangents from point (lines)],
  [`ctz-def-projectile(name, origin, velocity, ...)`], [`projectile: (...)`], [Projectile trajectory],
)

All defined conics can be:
- Drawn with `ctz-draw("name", stroke: ..., fill: ...)`
- The tangent lines are stored as regular lines and can be used in line-line intersections

== Ellipse Helpers (Query Functions)

These functions return values directly rather than storing named objects:

- `ctz-ellipse-project-point(center, rx, ry, point, angle: 0deg)` — project a point onto the ellipse
- `ctz-ellipse-tangents-from-point(center, rx, ry, point, angle: 0deg, length: auto)` — get tangent line data
- `ctz-ellipse-circle-intersections(center, rx, ry, circle-center, r, angle: 0deg, steps: 360)` — intersections with a circle

