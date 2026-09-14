// Import cetz library for drawing 3D graphics
#import "@preview/cetz:0.4.2"

// Import mathematical functions needed for coordinate transformations
#import calc: ceil, cos, floor, max, sin, sqrt

// Create an arrow tip style for drawing vectors
// Parameters:
//   color: The color of the arrow tip (default: black)
// Returns: A dictionary with arrow styling properties
#let arrowtip(color: black) = (end: "stealth", fill: color, stroke: color)

// Negate all coordinates of a point (for drawing opposite axes)
// Parameters:
//   point: An array or collection representing coordinates
// Returns: The point with all coordinates negated
#let neg(point) = {
  point.map(c => -c)
}

// Normalize an angle to a specific period (e.g., 0-360° or 0-180°)
// This ensures angles wrap around correctly for spherical coordinates
// Parameters:
//   angle: The angle to normalize
//   period: The period to normalize to (must be positive)
// Returns: The normalized angle within [0, period]
#let angle-rem(angle, period) = {
  assert(period > 0deg, message: "Angle period must be positive.")

  let n = floor(angle.deg() / period.deg())
  let res = angle - n * period
  if res == 0deg and angle != 0deg {
    return period
  } else {
    return res
  }
}

// Convert spherical coordinates to Cartesian coordinates
// Uses physics convention: theta from z-axis, phi from x-axis in xy-plane
// Parameters:
//   r: Radius (distance from origin)
//   phi: Azimuthal angle (rotation around z-axis)
//   theta: Polar angle (angle from positive z-axis)
// Returns: A tuple (x, y, z) of Cartesian coordinates
#let cartesian(r, phi, theta) = {
  let x = r * sin(theta) * sin(phi)
  let y = r * cos(theta)
  let z = r * sin(theta) * cos(phi)
  (x, y, z)
}

// Stroke style for dashed projection lines
#let dashed-stroke = (dash: "dashed", paint: luma(180))
// Color for negative axis directions (e.g., -x, -y, -z)
#let neg-axis-color = luma(140)

// Number of ellipses per radius unit (for drawing the sphere surface)
#let ellipse-density = 16
// Color for ellipses that form the sphere wireframe
#let ellipse-color = luma(235)

// Draw the angular indicators (theta and phi) for the quantum state
// Parameters:
//   r: Radius of the Bloch sphere
//   phi: Azimuthal angle
//   theta: Polar angle
//   angle-labels: Whether to display angle labels (theta and phi)
#let draw-angles(r, phi, theta, angle-labels) = {
  import cetz.draw: *
  import cetz.angle

  // Determine clockwise or counter-clockwise direction for better label placement
  let dir = if phi <= 206.5deg and phi > 26.5deg { "cw" } else { "ccw" }
  let state-point = cartesian(r, phi, theta)

  // Invisible line to the state point (used as reference for angle measurement)
  line(
    name: "state-line",
    (0, 0, 0),
    state-point,
    stroke: none,
  )

  // Draw theta angle (polar angle from z-axis)
  if theta != 0deg {
    // Project the state point onto a 2D plane for angle drawing
    // Required by cetz 0.4.2 for proper angle visualization
    // Calculate the radial distance in the xz-plane
    let projected-x = sqrt(state-point.at(0) * state-point.at(0) + state-point.at(2) * state-point.at(2))

    angle.angle(
      name: "theta",
      (0, 0, 0),
      (0, 1, 0),
      (projected-x, state-point.at(1), 0),
      direction: dir,
      radius: 0.2 * r,
    )
  }

  if angle-labels and theta != 0deg {
    content(
      "theta",
      $#math.theta$,
      anchor: if theta != 180deg {
        "south-west"
      } else { "south-east" },
      padding: (
        x: if theta != 180deg {
          -0.02
        } else { 0.1 },
        y: 0.05,
      ),
    )
  }

  // Skip drawing phi angle if it's at special positions (along axes)
  if phi == 0deg or theta == 0deg or theta == 180deg {
    return
  }

  // Draw phi angle (azimuthal angle) in the xz-plane
  on-xz({
    arc(
      name: "phi",
      (0, 0),
      radius: 0.2 * r,
      start: 90deg,
      delta: -phi,
      anchor: "origin",
    )
  })

  if angle-labels {
    content("phi", $#math.phi.alt$, anchor: "north-west", padding: 0.02)
  }
}

// Draw the Cartesian coordinate axes (x, y, z) with both positive and negative directions
// Parameters:
//   r: Base radius for scaling the axes
#let draw-axis(r) = {
  import cetz.draw: *

  // Helper function to draw an axis with both positive and negative directions
  let axis(name, to: none) = {
    line(name: name, (0, 0, 0), to, mark: arrowtip())
    line(
      name: "-" + name,
      (0, 0, 0),
      neg(to),
      mark: arrowtip(color: neg-axis-color),
      stroke: neg-axis-color,
    )
  }

  // Helper function to add labels to both ends of an axis
  // Parameters:
  //   axis: Name of the axis ("x", "y", or "z")
  //   c: The label content (mathematical symbol)
  //   anchors: Position anchors for positive and negative ends
  //   paddings: Padding values for label placement
  let label(axis, c, anchors, paddings) = {
    content(
      axis + ".end",
      anchor: anchors.first(),
      padding: paddings.first(),
      c,
    )

    content(
      "-" + axis + ".end",
      anchor: anchors.last(),
      padding: paddings.last(),
      text(fill: neg-axis-color, $-#c$),
    )
  }

  // Tweaking the axis lengths makes the diagram look better
  // Slightly shorter y and z axes for better visual proportions
  let c = 0.8 * r
  axis("x", to: (0, 0, 1)) // x-axis extends in the z direction (3D projection)
  axis("z", to: (0, c, 0)) // z-axis extends in the y direction (3D projection)
  axis("y", to: (c, 0, 0)) // y-axis extends in the x direction (3D projection)

  label("z", $z$, ("south", "north"), (0.03, 0))
  label("x", $x$, ("north-east", "south"), (0, 0.03))
  label("y", $y$, ("west", "east"), (0.03, 0.03))
}

// Draw dashed projection lines from the state vector to the axes
// This helps visualize the 3D position of the quantum state
// Parameters:
//   r: Radius of the Bloch sphere
//   phi: Azimuthal angle
//   theta: Polar angle
#let draw-dashed(r, phi, theta) = {
  import cetz.draw: *

  // Skip dashed lines for special angles (along axes or equator)
  if theta == 0deg or theta == 180deg or theta == 90deg {
    return
  }

  let (x, y, z) = cartesian(r, phi, theta)

  // Draw dashed line from origin to projection on the equator (xz-plane)
  on-xz({
    line(
      (0, 0),
      (angle: 90deg - phi, radius: r * sin(theta)),
      stroke: dashed-stroke,
    )
  })

  // Draw vertical dashed line from state point down to the equator
  line(
    (x, y, z),
    (x, 0, z),
    stroke: dashed-stroke,
  )
}

// Draw the Bloch sphere surface using ellipses
// Parameters:
//   r: Radius of the sphere
//   sphere-style: Style of sphere rendering ("circle", "sphere", or none)
#let draw-ellipses(r, sphere-style) = {
  if sphere-style == none {
    return
  }

  import cetz.draw: *

  // Calculate number of ellipses based on radius and density
  let n = max(1, ceil(ellipse-density * r))

  // Simple circle style: draw ellipses in two perpendicular planes
  if sphere-style == "circle" {
    for i in range(n) {
      let alpha = i * (180deg / n)
      let h = r * cos(alpha) // Horizontal radius
      let v = r * sin(alpha) // Vertical radius

      // Draw two perpendicular ellipses to create a mesh pattern
      circle((0, 0), radius: (h, r), stroke: ellipse-color)
      circle((0, 0), radius: (r, v), stroke: ellipse-color)
    }

    // Draw the main equatorial circle with a darker outline
    circle((0, 0), radius: r, stroke: luma(100))

    return
  }

  // Validate sphere style
  assert(
    sphere-style == "sphere",
    message: "Sphere style must be 'circle' or 'sphere'.",
  )

  // Full sphere style: draw rotated circles to create a 3D mesh
  on-yz({
    // Draw circles at different rotation angles to form a spherical mesh
    for i in range(n) {
      let alpha = i * (180deg / n)

      rotate(y: alpha)
      circle((0, 0), radius: r, stroke: ellipse-color)
    }
  })
}

// Draw labels for the quantum basis states at the poles
// |0⟩ at the north pole (top) and |1⟩ at the south pole (bottom)
// Parameters:
//   r: Radius of the Bloch sphere
#let draw-polar-labels(r) = {
  import cetz.draw: *
  let dot-radius = 0.03 * r
  let label-padding = 0.04 * r

  // Draw a small circle at the north pole (|0⟩ state)
  circle(
    name: "N",
    (0, r, 0),
    radius: dot-radius,
    stroke: black,
    fill: white,
  )

  // Draw a small circle at the south pole (|1⟩ state)
  circle(
    name: "S",
    (0, -r, 0),
    radius: dot-radius,
    stroke: black,
    fill: white,
  )

  // Label the north pole as |0⟩ (computational basis state 0)
  content(
    "N",
    anchor: "south-east",
    $lr(| 0 chevron.r)$,
    padding: label-padding,
  )

  // Label the south pole as |1⟩ (computational basis state 1)
  content(
    "S",
    anchor: "north-west",
    $lr(| 1 chevron.r)$,
    padding: label-padding,
  )
}

// Draw the quantum state vector as an arrow from the origin
// Parameters:
//   r: Radius of the Bloch sphere
//   phi: Azimuthal angle
//   theta: Polar angle
//   state-color: Color of the state vector arrow
#let draw-state(r, phi, theta, state-color) = {
  import cetz.draw: *

  // Special case: state along the z-axis (north or south pole)
  if theta == 0deg or theta == 180deg {
    // Draw state vector along z-axis (simplified 2D case)
    line(
      name: "state",
      (0, 0),
      (0, r * cos(theta)),
      stroke: state-color,
      mark: arrowtip(color: state-color),
    )

    return
  }

  // General case: draw state vector to arbitrary point on sphere
  line(
    name: "state",
    (0, 0),
    cartesian(r, phi, theta),
    stroke: state-color,
    mark: arrowtip(color: state-color),
  )
}

// Main function to draw the complete Bloch sphere with all components
// Parameters:
//   r: Radius of the sphere
//   show-axis: Whether to show coordinate axes
//   phi: Azimuthal angle of the quantum state
//   theta: Polar angle of the quantum state
//   state-color: Color for the state vector
//   sphere-style: Style of sphere rendering ("circle", "sphere", or none)
//   angle-labels: Whether to show angle labels
//   polar-labels: Whether to show |0⟩ and |1⟩ labels
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
  // Normalize angles to their standard ranges
  phi = angle-rem(phi, 360deg)
  theta = angle-rem(theta, 180deg)

  // Draw components in order (back to front for proper layering)
  draw-ellipses(r, sphere-style)

  if show-axis {
    let axis-radius = 1.5 * r
    draw-axis(axis-radius)
  }

  draw-dashed(r, phi, theta)
  draw-state(r, phi, theta, state-color)
  draw-angles(r, phi, theta, angle-labels)

  if polar-labels {
    draw-polar-labels(r)
  }

  import cetz.draw: *
  // Draw a small circle at the origin to clean up line intersections
  on-xz({
    circle((0, 0), radius: r / 100, fill: black)
  })
}

// Main user-facing function to create a Bloch sphere diagram
// The Bloch sphere is a geometrical representation of the pure state space
// of a two-level quantum system (qubit)
//
// Parameters:
//   length: Overall size/length of the diagram (default: 2cm)
//   radius: Radius of the Bloch sphere in arbitrary units (default: 1)
//   debug: Enable debug mode for the cetz canvas (default: false)
//   padding: Padding around the diagram (default: none)
//   show-axis: Whether to display x, y, z coordinate axes (default: true)
//   phi: Azimuthal angle (rotation around z-axis) in degrees (default: 0°)
//   theta: Polar angle (tilt from z-axis) in degrees (default: 0°)
//   state-color: Color of the quantum state vector (default: purple)
//   sphere-style: Rendering style - "circle" (simple), "sphere" (full 3D), or none (default: "circle")
//   angle-labels: Display theta and phi angle labels (default: true)
//   polar-labels: Display |0⟩ and |1⟩ at the poles (default: true)
//
// Returns: A cetz canvas with the rendered Bloch sphere
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
)

// Predefined common quantum states as (phi, theta) coordinate pairs
// These correspond to standard basis states and superposition states

// |0⟩ state: computational basis state 0 (north pole)
#let zero = (phi: 0deg, theta: 0deg)

// |1⟩ state: computational basis state 1 (south pole)
#let one = (phi: 0deg, theta: 180deg)

// |+⟩ state: equal superposition (1/√2)(|0⟩ + |1⟩) on the equator
#let plus = (phi: 0deg, theta: 90deg)

// |-⟩ state: equal superposition (1/√2)(|0⟩ - |1⟩) on the equator, opposite side
#let minus = (phi: 180deg, theta: 90deg)
