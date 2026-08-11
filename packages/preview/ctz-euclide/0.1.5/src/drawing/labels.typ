// ctz-euclide/src/drawing/labels.typ
// Label positioning and drawing functions

#import "@preview/cetz:0.4.2" as cetz
#import "../util.typ"
#import "../draw.typ"

// =============================================================================
// MATH LABEL HELPER
// =============================================================================

/// Convert a point name string to math content (see drawing.typ for docs).
#let _math-label(name) = {
  eval(name.clusters().join(" "), mode: "math")
}

// =============================================================================
// LABEL POSITIONING HELPERS
// =============================================================================

/// The 8 standard label positions with their angular directions (in degrees)
/// Angle 0 = right, 90 = above, 180 = left, 270 = below
#let _label-positions = (
  (name: "right", angle: 0),
  (name: "above right", angle: 45),
  (name: "above", angle: 90),
  (name: "above left", angle: 135),
  (name: "left", angle: 180),
  (name: "below left", angle: 225),
  (name: "below", angle: 270),
  (name: "below right", angle: 315),
)

/// Normalize angle to [0, 360)
#let _normalize-angle(a) = {
  let result = calc.rem(a, 360)
  if result < 0 { result + 360 } else { result }
}

/// Compute angular distance between two angles (in degrees), result in [0, 180]
#let _angular-distance(a1, a2) = {
  let diff = calc.abs(_normalize-angle(a1) - _normalize-angle(a2))
  if diff > 180 { 360 - diff } else { diff }
}

/// Compute the optimal label position given a list of "avoid" directions (angles in degrees)
/// Returns one of the 8 standard position names
#let compute-auto-label-position(avoid-angles) = {
  if avoid-angles.len() == 0 {
    return "above right"  // Default when nothing to avoid
  }

  // For each candidate position, compute the minimum distance to any avoid angle
  let best-pos = "above right"
  let best-score = -1

  for pos in _label-positions {
    let min-dist = 180  // Start with max possible
    for avoid in avoid-angles {
      let dist = _angular-distance(pos.angle, avoid)
      if dist < min-dist {
        min-dist = dist
      }
    }
    // Higher min-dist is better (farther from all avoid angles)
    if min-dist > best-score {
      best-score = min-dist
      best-pos = pos.name
    }
  }

  best-pos
}

/// Compute the angle (in degrees) from point p1 to point p2
#let _direction-angle(p1, p2) = {
  let dx = p2.at(0) - p1.at(0)
  let dy = p2.at(1) - p1.at(1)
  let angle-rad = calc.atan2(dy, dx)
  // Convert to degrees, atan2 returns angle type in Typst
  if type(angle-rad) == angle {
    angle-rad / 1deg
  } else {
    angle-rad * 180 / calc.pi
  }
}

// =============================================================================
// BASIC LABEL FUNCTIONS
// =============================================================================

/// Label a point with automatic positioning
/// pos can be: "above", "below", "left", "right", "above left", etc.
#let label-point(cetz-draw, coord, label, pos: "above", dist: 0.2) = {
  let anchor = draw.ctz-pos-to-anchor(pos)
  cetz-draw.content(coord, label, anchor: anchor, padding: dist)
}

/// Label multiple points with their names
#let label-points(cetz-draw, pt-func, ..args, pos: "above", dist: 0.15) = {
  let names = args.pos()
  let positions = args.named()

  for name in names {
    let p = positions.at(name, default: pos)
    label-point(cetz-draw, pt-func(name), [$#_math-label(name)$], pos: p, dist: dist)
  }
}
