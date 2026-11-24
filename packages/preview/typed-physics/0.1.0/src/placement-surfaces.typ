// Placement of surfaces and their local frames.

#import "vector.typ"
#import "expression.typ"
#import "placement-anchors.typ" as anchors
#import "placement-quantities.typ" as quantities

#let resolve-attachment-point = anchors.resolve-attachment-point
#let angle-symbol = quantities.angle-symbol

#let _placed-surface(
  surface-name,
  surface-kind,
  start-position,
  surface-tangent-direction,
  outward-normal-direction,
  surface-length,
  surface-inclination,
  friction-coefficients,
  surface-style,
  additional-fields,
) = (
    name: surface-name,
    kind: surface-kind,
    start: start-position,
    end: vector.point-along(
      start-position,
      surface-tangent-direction,
      surface-length,
    ),
    midpoint: vector.point-along(
      start-position,
      surface-tangent-direction,
      surface-length / 2,
    ),
    direction: surface-tangent-direction,
    outward-normal: outward-normal-direction,
    length: surface-length,
    inclination: surface-inclination,
    friction: friction-coefficients,
    style: surface-style,
  ) + additional-fields

// Where a surface begins: at the origin, or at the anchor of a surface declared
// before it.
#let _surface-start-position(
  surface-declaration,
  placed-surfaces,
  default-start-position,
) = {
  if surface-declaration.from == none { return default-start-position }
  resolve-attachment-point(
    surface-declaration.from,
    placed-surfaces,
    (:),
    (:),
    surface-declaration.kind + " \"" + surface-declaration.name + "\"",
  )
}

#let resolve-surface-geometry(
  surface-declaration,
  horizontal-span,
  ramp-count,
  placed-surfaces,
) = {
  let surface-kind = surface-declaration.kind
  let surface-name = surface-declaration.name
  let start-position(default-start-position) = _surface-start-position(
    surface-declaration,
    placed-surfaces,
    default-start-position,
  )

  // A flat support keeps an exact zero for its inclination, so the incline
  // equations collapse to the horizontal ones on their own instead of through
  // a second set of formulas.
  if surface-kind == "ground" {
    return _placed-surface(
      surface-name,
      surface-kind,
      start-position((0, 0)),
      (1, 0),
      (0, 1),
      surface-declaration.length,
      0deg,
      surface-declaration.friction,
      surface-declaration.style,
      (inclination-quantity: expression.number(0)),
    )
  }

  if surface-kind == "ceiling" {
    return _placed-surface(
      surface-name,
      surface-kind,
      start-position((0, surface-declaration.height)),
      (1, 0),
      (0, -1),
      surface-declaration.length,
      0deg,
      surface-declaration.friction,
      surface-declaration.style,
      (
        inclination-quantity: expression.number(0),
        height: surface-declaration.height,
      ),
    )
  }

  if surface-kind == "ramp" {
    let surface-inclination = surface-declaration.angle
    let climbs-to-the-right = surface-declaration.facing == "right"
    // The tangent direction always points uphill, so the sign conventions of
    // the incline frame hold whichever way the slope runs.
    let surface-tangent-direction = if climbs-to-the-right {
      vector.direction-from-angle(surface-inclination)
    } else {
      vector.direction-from-angle(180deg - surface-inclination)
    }
    let outward-normal-direction = if climbs-to-the-right {
      vector.left-normal(surface-tangent-direction)
    } else {
      vector.right-normal(surface-tangent-direction)
    }
    let placed-ramp = _placed-surface(
      surface-name,
      surface-kind,
      start-position((0, 0)),
      surface-tangent-direction,
      outward-normal-direction,
      surface-declaration.length,
      surface-inclination,
      surface-declaration.friction,
      surface-declaration.style,
      (
        facing: surface-declaration.facing,
        inclination-quantity: expression.declared-angle(
          surface-inclination,
          angle-symbol(
            surface-name,
            ramp-count,
            surface-declaration.symbol,
          ),
        ),
      ),
    )
    return placed-ramp + (
      foot: placed-ramp.start,
      apex: placed-ramp.end,
      base-corner: (placed-ramp.end.at(0), placed-ramp.start.at(1)),
    )
  }

  if surface-kind == "arc" {
    let start-angle = surface-declaration.start-angle
    let sweep-angle = (
      surface-declaration.end-angle - surface-declaration.start-angle
    )
    let start-radial-direction = vector.direction-from-angle(start-angle)
    let start-point = start-position((0, 0))
    let arc-center = vector.point-along(
      start-point,
      vector.reversed(start-radial-direction),
      surface-declaration.radius,
    )
    let midpoint-angle = start-angle + sweep-angle / 2
    let end-radial-direction = vector.direction-from-angle(
      surface-declaration.end-angle,
    )
    let midpoint-radial-direction = vector.direction-from-angle(midpoint-angle)
    let starts-counterclockwise = sweep-angle > 0deg
    let start-tangent-direction = if starts-counterclockwise {
      vector.left-normal(start-radial-direction)
    } else {
      vector.right-normal(start-radial-direction)
    }
    let start-outward-normal = if surface-declaration.side == "outside" {
      start-radial-direction
    } else {
      vector.reversed(start-radial-direction)
    }
    return (
      name: surface-name,
      kind: surface-kind,
      start: start-point,
      end: vector.point-along(
        arc-center,
        end-radial-direction,
        surface-declaration.radius,
      ),
      midpoint: vector.point-along(
        arc-center,
        midpoint-radial-direction,
        surface-declaration.radius,
      ),
      center: arc-center,
      direction: start-tangent-direction,
      outward-normal: start-outward-normal,
      length: surface-declaration.radius * calc.abs(sweep-angle.rad()),
      inclination: vector.angle-of(start-tangent-direction),
      inclination-quantity: expression.declared-angle(
        vector.angle-of(start-tangent-direction),
        $theta$,
      ),
      radius: surface-declaration.radius,
      start-angle: start-angle,
      end-angle: surface-declaration.end-angle,
      sweep-angle: sweep-angle,
      side: surface-declaration.side,
      friction: surface-declaration.friction,
      style: surface-declaration.style,
    )
  }

  let wall-foot-position = start-position(
    if surface-declaration.side == "left" {
      (horizontal-span.at(0), 0)
    } else {
      (horizontal-span.at(1), 0)
    },
  )
  let wall-outward-normal-direction = if surface-declaration.side == "left" {
    (1, 0)
  } else {
    (-1, 0)
  }
  _placed-surface(
    surface-name,
    surface-kind,
    wall-foot-position,
    (0, 1),
    wall-outward-normal-direction,
    surface-declaration.height,
    90deg,
    surface-declaration.friction,
    surface-declaration.style,
    (
      inclination-quantity: expression.declared-angle(90deg, $theta$),
      side: surface-declaration.side,
      foot: wall-foot-position,
    ),
  )
}

// How far the placed surfaces reach left and right, which is where a wall that
// was not given a `from:` stands.
#let horizontal-surface-span(placed-surfaces, surface-names) = {
  let horizontal-extents = (0,)
  for surface-name in surface-names {
    let surface = placed-surfaces.at(surface-name)
    if surface.kind == "arc" {
      horizontal-extents.push(surface.center.at(0) - surface.radius)
      horizontal-extents.push(surface.center.at(0) + surface.radius)
    } else {
      horizontal-extents.push(surface.start.at(0))
      horizontal-extents.push(surface.end.at(0))
    }
  }
  (calc.min(..horizontal-extents), calc.max(..horizontal-extents))
}

// ── Bodies ───────────────────────────────────────────────────────────────────

// A block's own `mu:` describes the contact it makes, and the surface's `mu:`
// describes everything that touches it. The nearer declaration wins.
