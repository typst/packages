// =====================================================
// SPACE CANVAS - 3D coordinate system
// =====================================================

#import "@preview/cetz:0.4.2"
#import "draw.typ": draw-geo

/// Create a 3D space canvas
/// Renders 3D geometry objects with perspective projection.
///
/// Parameters:
/// - theme: Theme dictionary for styling
/// - x-domain: X-axis range (default: (0, 5))
/// - y-domain: Y-axis range (default: (0, 5))
/// - z-domain: Z-axis range (default: (0, 4))
/// - view: Camera rotation as (x:, y:, z:) dictionary
/// - step: Grid line spacing (default: 1)
/// - x-label, y-label, z-label: Axis labels
/// - show-axes: Whether to show axes (default: true)
/// - show-grid: Whether to show XY grid (default: true)
/// - show-ticks: Whether to show tick marks (default: false)
/// - ..objects: Geometry objects to render
#let space-canvas(
  theme: (:),
  x-domain: (0, 5),
  y-domain: (0, 5),
  z-domain: (0, 4),
  view: (x: -90deg, y: -120deg, z: 0deg),
  step: 1,
  x-label: $x$,
  y-label: $y$,
  z-label: $z$,
  show-axes: true,
  show-grid: true,
  show-ticks: false,
  ..objects,
) = {
  let axis-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let grid-col = theme.at("plot", default: (:)).at("grid", default: gray)

  let axis-style = (paint: axis-col, thickness: 1pt)
  let grid-style = (paint: grid-col, thickness: 0.5pt)
  let tick-style = (paint: axis-col, thickness: 1pt)

  cetz.canvas({
    import cetz.draw: *

    // Apply 3D rotation
    rotate(x: view.at("x", default: 0deg), y: view.at("y", default: 0deg), z: view.at("z", default: 0deg))

    let (x-min, x-max) = x-domain
    let (y-min, y-max) = y-domain
    let (z-min, z-max) = z-domain

    // Draw grid
    if show-grid {
      for i in range(int(x-min / step), int(x-max / step) + 1) {
        let x = i * step
        line((x, y-min, 0), (x, y-max, 0), stroke: grid-style)
      }
      for i in range(int(y-min / step), int(y-max / step) + 1) {
        let y = i * step
        line((x-min, y, 0), (x-max, y, 0), stroke: grid-style)
      }
    }

    // Draw axes
    if show-axes {
      // Z-Axis (vertical)
      line((0, 0, 0), (0, 0, z-max + 1), stroke: axis-style, mark: (end: "stealth", fill: axis-col), name: "z-axis")
      content((0, 0, z-max + 1.2), text(fill: axis-col, z-label))

      // X-Axis
      line((0, 0, 0), (x-max + 1, 0, 0), stroke: axis-style, mark: (end: "stealth", fill: axis-col), name: "x-axis")
      content((x-max + 1.2, 0, 0), text(fill: axis-col, x-label))

      // Y-Axis
      line((0, 0, 0), (0, y-max + 1, 0), stroke: axis-style, mark: (end: "stealth", fill: axis-col), name: "y-axis")
      content((0, y-max + 1.2, 0), text(fill: axis-col, y-label))

      // Tick marks
      if show-ticks {
        let tick-len = 0.2
        for i in range(int(x-min / step), int(x-max / step) + 1) {
          if i != 0 {
            let x = i * step
            line((x, 0, -tick-len), (x, 0, tick-len), stroke: tick-style)
          }
        }
        for i in range(int(y-min / step), int(y-max / step) + 1) {
          if i != 0 {
            let y = i * step
            line((0, y, -tick-len), (0, y, tick-len), stroke: tick-style)
          }
        }
        for i in range(int(z-min / step), int(z-max / step) + 1) {
          if i != 0 {
            let z = i * step
            line((-tick-len, 0, z), (tick-len, 0, z), stroke: tick-style)
          }
        }
      }
    }

    // Draw user objects
    let bounds = (x: x-domain, y: y-domain, z: z-domain)
    for obj in objects.pos() {
      if type(obj) == dictionary and obj.at("type", default: none) != none {
        draw-geo(obj, theme, bounds: bounds)
      } else if type(obj) == array {
        // Handle arrays of objects (e.g., from vec-add, vec-components)
        for sub-obj in obj {
          if type(sub-obj) == dictionary and sub-obj.at("type", default: none) != none {
            draw-geo(sub-obj, theme, bounds: bounds)
          }
        }
      } else {
        obj
      }
    }
  })
}

/// Draw a 3D vector (arrow) in space
#let draw-vec-3d(
  theme: (:),
  start: (0, 0, 0),
  end,
  label: none,
  color: auto,
) = {
  import cetz.draw: *

  let stroke-col = if color == auto {
    theme.at("plot", default: (:)).at("stroke", default: black)
  } else {
    color
  }

  line(
    start,
    end,
    stroke: (paint: stroke-col, thickness: 1.5pt),
    mark: (end: "stealth", fill: stroke-col),
  )

  if label != none {
    let bg-col = theme.at("page-fill", default: white)
    let mid = (
      (start.at(0) + end.at(0)) / 2,
      (start.at(1) + end.at(1)) / 2,
      (start.at(2) + end.at(2)) / 2,
    )

    // Use screen-space pill background for 3D
    content(
      mid,
      box(
        inset: (x: 4pt, y: 2pt),
        radius: 3pt,
        fill: bg-col,
        stroke: (paint: stroke-col, thickness: 0.5pt),
        text(fill: stroke-col, weight: "bold", label),
      ),
      anchor: "center",
    )
  }
}

/// Draw a 3D point with label
/// Uses a billboard-style marker that maintains consistent screen size
#let draw-point-3d(
  coords,
  theme: (:),
  label: none,
  color: auto,
  size: 5pt,
) = {
  import cetz.draw: *

  let fill-col = if color == auto {
    theme.at("plot", default: (:)).at("highlight", default: black)
  } else {
    color
  }

  // Extract coordinates
  let (px, py, pz) = if type(coords) == array {
    coords
  } else if type(coords) == dictionary {
    (coords.x, coords.y, coords.z)
  } else {
    (0, 0, 0)
  }

  // Use a filled square that renders at consistent screen size
  // Content in CeTZ is rendered in screen space, avoiding perspective distortion
  content(
    (px, py, pz),
    box(
      width: size,
      height: size,
      radius: size / 2, // Makes it circular
      fill: fill-col,
    ),
    anchor: "center",
  )

  if label != none {
    content(
      (px, py, pz),
      text(fill: theme.at("plot", default: (:)).at("stroke", default: black), label),
      anchor: "south-west",
      padding: 0.15,
    )
  }
}
