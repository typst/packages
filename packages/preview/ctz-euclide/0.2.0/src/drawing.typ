// ctz-euclide/src/drawing.typ
// High-level drawing functions that work directly with cetz.draw
// Re-exports from submodules plus main orchestration code

#import "@preview/cetz:0.5.2" as cetz
#import "util.typ"
#import "draw.typ"
#import "conic.typ"

// Import and re-export from submodules (single source of truth — the
// functions in these files must not be redefined here)
#import "drawing/state.typ": *
#import "drawing/clipping.typ": *
#import "drawing/primitives.typ": *
#import "drawing/labels.typ": *
#import "drawing/polygons.typ": *
#import "drawing/grids.typ": *
#import "drawing/annotations.typ": *


// =============================================================================
// MAIN LEVÉE (HAND-DRAWN STYLE) DRAWING FUNCTIONS
// =============================================================================

/// Draw a sketchy line (main-levée style)
/// Uses multiple segments with slight perturbations for hand-drawn effect
#let draw-sketchy-line(cetz-draw, p1, p2, roughness: draw.default-main-levee-roughness, seed: draw.default-main-levee-seed, ..style) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, p1)
    let (_, c2) = cetz.coordinate.resolve(ctx, p2)
    let points = draw.sketchy-line-points(c1, c2, roughness: roughness, seed: seed)
    cetz-draw.line(..points, ..style)
  })
}

/// Draw a sketchy circle (main-levée style)
#let draw-sketchy-circle(cetz-draw, center, radius, roughness: draw.default-main-levee-roughness, seed: draw.default-main-levee-seed, steps: 48, ..style) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, center)
    let points = draw.sketchy-circle-points(c, radius, roughness: roughness, seed: seed, steps: steps)
    cetz-draw.line(..points, ..style)
  })
}

/// Draw a sketchy arc (main-levée style)
#let draw-sketchy-arc(cetz-draw, center, radius, start-angle, end-angle, roughness: draw.default-main-levee-roughness, seed: draw.default-main-levee-seed, steps: 24, ..style) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, center)
    // Convert angles to radians if needed
    let start-rad = if type(start-angle) == angle { start-angle / 1rad } else { start-angle * calc.pi / 180 }
    let end-rad = if type(end-angle) == angle { end-angle / 1rad } else { end-angle * calc.pi / 180 }
    let points = draw.sketchy-arc-points(c, radius, start-rad, end-rad, roughness: roughness, seed: seed, steps: steps)
    cetz-draw.line(..points, ..style)
  })
}

/// Draw a sketchy polygon (main-levée style)
#let draw-sketchy-polygon(cetz-draw, vertices, roughness: draw.default-main-levee-roughness, seed: draw.default-main-levee-seed, close: true, ..style) = {
  cetz-draw.get-ctx(ctx => {
    // Resolve all vertices
    let resolved = ()
    for v in vertices {
      let (_, c) = cetz.coordinate.resolve(ctx, v)
      resolved.push(c)
    }

    // Generate sketchy edges
    let all-points = ()
    for i in range(resolved.len()) {
      let next-i = calc.rem(i + 1, resolved.len())
      if i == resolved.len() - 1 and not close { break }
      let edge-points = draw.sketchy-line-points(
        resolved.at(i),
        resolved.at(next-i),
        roughness: roughness,
        seed: seed + i * 100,
        base-index: i * 20
      )
      // Add points (skip first point except for first edge to avoid duplicates)
      if i == 0 {
        all-points += edge-points
      } else {
        all-points += edge-points.slice(1)
      }
    }
    cetz-draw.line(..all-points, ..style)
  })
}

/// Draw a sketchy ellipse (main-levée style)
#let draw-sketchy-ellipse(cetz-draw, center, rx, ry, angle: 0deg, roughness: draw.default-main-levee-roughness, seed: draw.default-main-levee-seed, steps: 48, ..style) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, center)
    let points = draw.sketchy-ellipse-points(c, rx, ry, angle: angle, roughness: roughness, seed: seed, steps: steps)
    cetz-draw.line(..points, ..style)
  })
}

/// Draw a sketchy rectangle (main-levée style)
#let draw-sketchy-rect(cetz-draw, corner1, corner2, roughness: draw.default-main-levee-roughness, seed: draw.default-main-levee-seed, ..style) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, corner1)
    let (_, c2) = cetz.coordinate.resolve(ctx, corner2)
    let vertices = (
      c1,
      (c2.at(0), c1.at(1)),
      c2,
      (c1.at(0), c2.at(1)),
    )
    // Use polygon drawing
    let all-points = ()
    for i in range(4) {
      let next-i = calc.rem(i + 1, 4)
      let edge-points = draw.sketchy-line-points(
        vertices.at(i),
        vertices.at(next-i),
        roughness: roughness,
        seed: seed + i * 100,
        base-index: i * 20
      )
      if i == 0 {
        all-points += edge-points
      } else {
        all-points += edge-points.slice(1)
      }
    }
    cetz-draw.line(..all-points, close: true, ..style)
  })
}

/// Check if main-levée is enabled and get current settings
#let get-main-levee-settings(ctx) = {
  let enabled = ctx.shared-state.at("ctz-main-levee", default: draw.default-main-levee)
  let roughness = ctx.shared-state.at("ctz-main-levee-roughness", default: draw.default-main-levee-roughness)
  let seed = ctx.shared-state.at("ctz-main-levee-seed", default: draw.default-main-levee-seed)
  (enabled: enabled, roughness: roughness, seed: seed)
}

/// Set main-levée mode in context
#let set-main-levee(cetz-draw, enabled: true, roughness: auto, seed: auto) = {
  cetz-draw.set-ctx(ctx => {
    ctx.shared-state.insert("ctz-main-levee", enabled)
    if roughness != auto {
      ctx.shared-state.insert("ctz-main-levee-roughness", roughness)
    }
    if seed != auto {
      ctx.shared-state.insert("ctz-main-levee-seed", seed)
    }
    ctx
  })
}

// =============================================================================


/// Draw an extended line (beyond the two points)
#let draw-line-extended(cetz-draw, p1, p2, extend-before: 0.5, extend-after: 0.5, ..style) = {
  draw-with-state(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, p1)
    let (_, c2) = cetz.coordinate.resolve(ctx, p2)

    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)

    let start = (c1.at(0) - extend-before * dx, c1.at(1) - extend-before * dy)
    let end = (c2.at(0) + extend-after * dx, c2.at(1) + extend-after * dy)

    ctx = _record-segment(ctx, start, end)
    (ctx, cetz-draw.line(start, end, ..style))
  })
}

/// Global style configuration key
#let _global-style-key = "ctz-global-style"

/// Default global style
#let default-global-style = (
  point: (
    shape: draw.default-point-shape,
    size: draw.default-point-size,
    stroke: draw.default-point-color + draw.default-point-stroke-width,
  ),
  angle: (
    radius: 0.6,
    stroke: draw.default-line-color,
    fill: none,
    label-radius: auto,
  ),
  label: (
    padding: 0.15,
    single-padding: 0.25,
    explicit-padding: 0.45,
    // Collision avoidance: true/false, or a dict overriding any of the
    // defaults in _resolve-avoid-cfg (ring-step:, rings:, shrink:, margin:,
    // weights:). Example: ctz-style(label: (avoid: (shrink: ())))
    avoid: true,
  ),
)

/// Set global style for elements
/// Example: (ctz.set-style)(point: (shape: "dot", size: 0.1))
#let set-style(cetz-draw, ..style) = {
  cetz-draw.set-ctx(ctx => {
    let current = ctx.shared-state.at(_global-style-key, default: default-global-style)
    // Merge styles
    for (key, value) in style.named() {
      if key in current and type(value) == dictionary {
        for (k, v) in value {
          current.at(key).insert(k, v)
        }
      } else {
        current.insert(key, value)
      }
    }
    ctx.shared-state.insert(_global-style-key, current)
    ctx
  })
}

/// Get current global style
#let get-style(ctx) = {
  ctx.shared-state.at(_global-style-key, default: default-global-style)
}

/// Resolve the label-avoidance configuration from the global style.
/// Distances given as Typst lengths are converted to canvas units (so the
/// visual spacing is canvas-scale independent); plain numbers are canvas units.
#let _resolve-avoid-cfg(style, ctx) = {
  let cfg = (
    enabled: true,
    ring-step: 4pt,     // extra distance per retry ring
    rings: 5,           // number of distance rings tried per anchor
    shrink: (0.85, 0.7),// font scales tried when NOTHING fits at full size
    assoc-factor: 1.15, // label must be this factor closer to its own point
    margin: 1.5pt,      // clearance around points and circle strokes
    weights: (label: 4, point: 2, segment: 1, circle: 1),
  )
  let raw = style.at("label", default: (:)).at("avoid", default: true)
  if raw == false {
    cfg.enabled = false
  } else if type(raw) == dictionary {
    for (k, v) in raw { cfg.insert(k, v) }
  }
  let to-units(v) = if type(v) == length { v / ctx.length } else { float(v) }
  cfg.ring-step = to-units(cfg.ring-step)
  cfg.margin = to-units(cfg.margin)
  cfg.rings = calc.max(1, cfg.rings)
  if cfg.shrink == false or cfg.shrink == none { cfg.shrink = () }
  cfg
}

/// Mark an angle with arc and label, with smart label positioning
/// - vertex: the vertex of the angle (where the arc is drawn)
/// - a, b: the two rays endpoints
/// - label: the label content (e.g., $alpha$ or $30°$)
/// - radius: arc radius (default: global angle style, 0.6)
/// - label-radius: distance from vertex to label center along bisector (default: radius + 0.3)
/// - label-offset: (along, perp) offset relative to bisector direction (default: (0, 0))
/// - direction: "ccw" (counter-clockwise), "cw" (clockwise) or auto
/// - angle-type: "interior" (default) — the smaller angle between the rays;
///   "reflex"/"explementary" — the 360° complement, drawn on the other side;
///   "supplementary"/"exterior" — the angle between the extension of ray
///   vertex→a and ray vertex→b (the exterior angle of a polygon at a vertex).
///   (A complementary angle needs an explicit perpendicular ray, e.g. via
///   ctz-def-perp, since it is not spanned by the two given rays.)
/// - stroke: arc stroke style (default: global angle style)
/// - fill: arc fill color (default: global angle style)
#let mark-angle(
  cetz-draw,
  cetz-angle,
  vertex,
  a,
  b,
  label: none,
  radius: auto,
  label-radius: auto,
  label-offset: (0, 0),
  direction: auto,
  angle-type: "interior",
  stroke: auto,
  fill: auto,
  name: none,
) = {
  assert(
    angle-type in ("interior", "reflex", "explementary", "supplementary", "exterior"),
    message: "angle-type must be \"interior\", \"reflex\"/\"explementary\" or \"supplementary\"/\"exterior\", got " + repr(angle-type),
  )
  let reflex = angle-type in ("reflex", "explementary")

  draw-with-state(ctx => {
    // Resolve style defaults from the global angle style (ctz-style(angle: ...))
    let astyle = get-style(ctx).at("angle", default: (:))
    let radius = if radius == auto { astyle.at("radius", default: 0.6) } else { radius }
    let stroke = if stroke == auto { astyle.at("stroke", default: black) } else { stroke }
    let fill = if fill == auto { astyle.at("fill", default: none) } else { fill }
    let label-radius = if label-radius == auto { astyle.at("label-radius", default: auto) } else { label-radius }

    let (_, v) = cetz.coordinate.resolve(ctx, vertex)
    let (_, pa) = cetz.coordinate.resolve(ctx, a)
    let (_, pb) = cetz.coordinate.resolve(ctx, b)

    // Supplementary/exterior angle: mirror the first ray through the vertex
    if angle-type in ("supplementary", "exterior") {
      pa = (2 * v.at(0) - pa.at(0), 2 * v.at(1) - pa.at(1), pa.at(2, default: 0))
    }

    // Determine direction if set to auto
    let final-direction = direction
    if direction == auto {
      // Vectors from vertex to the two points
      let va = (pa.at(0) - v.at(0), pa.at(1) - v.at(1))
      let vb = (pb.at(0) - v.at(0), pb.at(1) - v.at(1))

      // Cross product: if positive, the ccw angle from a to b is < 180°.
      // Interior angles take the smaller side, reflex angles the larger one.
      let cross = va.at(0) * vb.at(1) - va.at(1) * vb.at(0)
      final-direction = if (cross >= 0) != reflex { "ccw" } else { "cw" }
    }

    // Draw the angle arc using cetz.angle on the background layer
    let elements = ()
    elements += cetz.draw.on-layer(-1, {
      cetz-angle.angle(
        v, pa, pb,
        radius: radius,
        direction: final-direction,
        stroke: stroke,
        fill: fill,
        name: name,
        label: none,  // We handle label ourselves
      )
    })

    // If there's a label, position it along the angle bisector
    if label != none {
      // The bisector direction points toward the interior (smaller) angle;
      // for reflex angles the label goes on the opposite side.
      let bisector = draw.angle-bisector-direction(pa, v, pb)
      if reflex {
        bisector = (-bisector.at(0), -bisector.at(1))
      }

      // Perpendicular to bisector (rotated 90° counterclockwise)
      let perp = (-bisector.at(1), bisector.at(0))

      // Place label along bisector direction from vertex
      let lr = if label-radius == auto { radius + 0.3 } else { label-radius }

      // Apply offsets relative to bisector coordinate system
      // label-offset.at(0) = along bisector, label-offset.at(1) = perpendicular
      let along-offset = label-offset.at(0)
      let perp-offset = label-offset.at(1)

      let label-x = v.at(0) + (lr + along-offset) * bisector.at(0) + perp-offset * perp.at(0)
      let label-y = v.at(1) + (lr + along-offset) * bisector.at(1) + perp-offset * perp.at(1)

      let m = measure(label)
      let (w, h) = (m.width / ctx.length, m.height / ctx.length)

      // Collision avoidance: the angle label's natural direction is fixed
      // (the bisector), so instead of switching anchors it is pushed outward
      // along the bisector in small steps until its rect is clear of drawn
      // geometry, point markers and other labels. Bounded (8 steps); honors
      // the same global avoid toggle as point labels. The user's explicit
      // label-radius / label-offset are respected as the starting point.
      let avoid-cfg = _resolve-avoid-cfg(get-style(ctx), ctx)
      if avoid-cfg.enabled and w > 0 and h > 0 {
        let obstacles = (
          segments: ctx.shared-state.at(_drawn-lines-key, default: ()),
          circles: ctx.shared-state.at(_drawn-circles-key, default: ()),
          points: ctx.shared-state.at(_drawn-points-key, default: ()),
          labels: ctx.shared-state.at(_placed-labels-key, default: ()),
        )
        let step = calc.max(avoid-cfg.ring-step, 0.05)
        let tries = 0
        while tries < 8 {
          let rect = (label-x - w / 2, label-y - h / 2, label-x + w / 2, label-y + h / 2)
          if score-label-rect(rect, obstacles, avoid-cfg.weights, margin: avoid-cfg.margin) == 0 {
            break
          }
          label-x += step * bisector.at(0)
          label-y += step * bisector.at(1)
          tries += 1
        }
      }

      // Register the label rect so point labels can avoid it
      if w > 0 and h > 0 {
        ctx = _record-label-rect(ctx, (label-x - w / 2, label-y - h / 2, label-x + w / 2, label-y + h / 2))
      }

      elements += cetz-draw.content((label-x, label-y), label)
    }
    (ctx, elements)
  })
}

/// Draw points using global style
/// Usage: draw-points-styled(cetz-draw, pt, "A", "B", "C", "O")
#let draw-points-styled(cetz-draw, pt-func, ..names) = {
  let overrides = names.named()
  draw-with-state(ctx => {
    let style = get-style(ctx)
    let ps = style.point
    // Per-call overrides: shape:, size:, stroke:, fill:, or color: (both)
    for (k, v) in overrides {
      if k == "color" {
        ps.insert("stroke", v + draw.default-point-stroke-width)
        ps.insert("fill", v)
      } else {
        ps.insert(k, v)
      }
    }

    let drawn-points = ctx.shared-state.at(_drawn-points-key, default: ())
    let elements = ()
    for name in names.pos() {
      let coord = pt-func(name)
      let (_, c) = cetz.coordinate.resolve(ctx, coord)
      let x = c.at(0)
      let y = c.at(1)
      let sz = ps.size

      // Register the marker for label avoidance
      drawn-points.push((x, y, sz))

      if ps.shape == "cross" {
        elements += cetz-draw.line((x - sz, y - sz), (x + sz, y + sz), stroke: ps.stroke)
        elements += cetz-draw.line((x - sz, y + sz), (x + sz, y - sz), stroke: ps.stroke)
      } else if ps.shape == "dot" {
        elements += cetz-draw.circle((x, y), radius: sz, fill: ps.at("fill", default: black), stroke: none)
      } else if ps.shape == "circle" {
        elements += cetz-draw.circle((x, y), radius: sz, fill: ps.at("fill", default: none), stroke: ps.at("stroke", default: black))
      } else if ps.shape == "plus" {
        elements += cetz-draw.line((x - sz, y), (x + sz, y), stroke: ps.stroke)
        elements += cetz-draw.line((x, y - sz), (x, y + sz), stroke: ps.stroke)
      } else if ps.shape == "square" {
        elements += cetz-draw.rect((x - sz, y - sz), (x + sz, y + sz), fill: ps.at("fill", default: black), stroke: none)
      }
    }
    ctx.shared-state.insert(_drawn-points-key, drawn-points)
    (ctx, elements)
  })
}

/// Label multiple points with automatic positioning based on global style
/// Usage: label-points-styled(cetz-draw, pt, "A", "B", "C", A: "above", B: "below left")
/// Position can be:
/// - a string: "above", "below", "left", "right", "above left", etc.
/// - "auto": automatically find best position avoiding connected lines and nearby points
/// - a dictionary: (pos: "above", offset: (0.1, 0)) or (pos: "auto", avoid: ("B", "C"))
#let label-points-styled(cetz-draw, pt-func, ..args) = {
  let names = args.pos()
  let positions = args.named()

  draw-with-state(ctx => {
    let style = get-style(ctx)
    let avoid-cfg = _resolve-avoid-cfg(style, ctx)
    // When the placement engine is active, unspecified labels are fully
    // automatic: the initial anchor is chosen from the local geometry and
    // the engine refines it. With the engine off, keep the legacy "above".
    let default-pos = if avoid-cfg.enabled { "auto" } else { "above" }
    let point-size = style.at("point", default: (:)).at("size", default: 0.07)
    // Names already labeled with identical content: drawing them again is
    // almost always an accidental duplicate (e.g. ctz-draw(path:) already
    // labels its points and a later ctz-draw-labels repeats them) — skip.
    let drawn-ids = ctx.shared-state.at("ctz-drawn-label-ids", default: ())

    // Get all named lines from context for "auto" positioning
    let lines = ctx.shared-state.at("ctz-lines", default: (:))
    // Drawn geometry registries (obstacles for collision avoidance)
    let drawn-lines = ctx.shared-state.at(_drawn-lines-key, default: ())
    let drawn-circles = ctx.shared-state.at(_drawn-circles-key, default: ())
    let drawn-points = ctx.shared-state.at(_drawn-points-key, default: ())
    let placed = ctx.shared-state.at(_placed-labels-key, default: ())
    // Get all named points from context
    let points-store = ctx.shared-state.at("ctz-points", default: (:))

    // Pre-resolve all point coordinates for "auto" positioning
    let resolved-points = (:)
    for name in names {
      let coord = pt-func(name)
      let (_, c) = cetz.coordinate.resolve(ctx, coord)
      resolved-points.insert(name, c)
    }

    let elements = ()
    let specs = ()
    for name in names {
      let spec = positions.at(name, default: default-pos)
      let (pos, offset, avoid-extra, label-content, avoid-flag) = if type(spec) == str {
        (spec, (0, 0), (), none, auto)
      } else if type(spec) == dictionary {
        // avoid: bool toggles the collision engine for this label;
        // avoid: (names...) keeps its meaning of extra points to avoid
        let av = spec.at("avoid", default: auto)
        let (extra, flag) = if type(av) == array { (av, auto) }
          else if type(av) == bool { ((), av) }
          else { ((), auto) }
        (
          spec.at("pos", default: default-pos),
          spec.at("offset", default: (0, 0)),
          extra,
          spec.at("label", default: spec.at("text", default: none)),
          flag,
        )
      } else {
        (default-pos, (0, 0), (), none, auto)
      }

      let c = resolved-points.at(name)

      let is-auto = pos == "auto"
      // Handle "auto" positioning
      if is-auto {
        let avoid-angles = ()

        // Get all figures from context
        let circles = ctx.shared-state.at("ctz-circles", default: (:))
        let conics = ctx.shared-state.at("ctz-conics", default: (:))

        // 1. Find directions to other points being labeled
        // For very close points, create wider avoidance zones
        for other-name in names {
          if other-name != name {
            let other-c = resolved-points.at(other-name)
            let dist = util.dist(c, other-c)
            if dist > 0.001 {
              let angle = _direction-angle(c, other-c)
              avoid-angles.push(angle)
              // For very close points, also avoid nearby angles to prevent overlap
              if dist < 1.5 {
                avoid-angles.push(_normalize-angle(angle - 30))
                avoid-angles.push(_normalize-angle(angle + 30))
              }
              if dist < 0.8 {
                // Even stronger avoidance for very close points
                avoid-angles.push(_normalize-angle(angle - 60))
                avoid-angles.push(_normalize-angle(angle + 60))
              }
            }
          }
        }

        // 2. Find directions along lines and drawn segments
        // (endpoint OR lying on the line)
        for line-pts in lines.values() + drawn-lines {
          let (p1, p2) = line-pts
          let d1 = util.dist(c, p1)
          let d2 = util.dist(c, p2)
          let line-len = util.dist(p1, p2)

          if d1 < 0.1 {
            // Point is at p1, line goes toward p2
            let angle = _direction-angle(c, p2)
            avoid-angles.push(angle)
          } else if d2 < 0.1 {
            // Point is at p2, line goes toward p1
            let angle = _direction-angle(c, p1)
            avoid-angles.push(angle)
          } else if line-len > 0.001 {
            // Check if point lies ON the line (not at endpoints)
            // Use point-to-line distance
            let dx = p2.at(0) - p1.at(0)
            let dy = p2.at(1) - p1.at(1)
            // Project point onto line
            let t = ((c.at(0) - p1.at(0)) * dx + (c.at(1) - p1.at(1)) * dy) / (line-len * line-len)
            // Distance from point to line (perpendicular)
            let proj-x = p1.at(0) + t * dx
            let proj-y = p1.at(1) + t * dy
            let dist-to-line = util.dist(c, (proj-x, proj-y))

            // If point is close to the line, avoid both directions along it
            if dist-to-line < 0.3 {
              let line-angle = _direction-angle(p1, p2)
              avoid-angles.push(line-angle)
              avoid-angles.push(_normalize-angle(line-angle + 180))
            }
          }
        }

        // 3. Find directions toward circle centers (for points on/near circles)
        for (circle-name, circ) in circles {
          let center = circ.center
          let radius = circ.radius
          let dist-to-center = util.dist(c, center)
          // If point is on or near the circle, avoid direction toward center
          if calc.abs(dist-to-center - radius) < 0.5 {
            let angle = _direction-angle(c, center)
            avoid-angles.push(angle)
          }
        }

        // 4. Find tangent directions for points on/near parabolas
        for (conic-name, conic-data) in conics {
          if conic-data.at("type", default: "") == "parabola" {
            let pts = conic-data.at("points", default: ())
            if pts.len() >= 2 {
              // Find closest point on parabola and its tangent
              let min-dist = 999999
              let closest-idx = 0
              for (i, pt) in pts.enumerate() {
                let d = util.dist(c, pt)
                if d < min-dist {
                  min-dist = d
                  closest-idx = i
                }
              }
              // If point is near the parabola
              if min-dist < 0.5 {
                // Compute tangent direction from neighboring points
                let prev-idx = calc.max(0, closest-idx - 1)
                let next-idx = calc.min(pts.len() - 1, closest-idx + 1)
                if prev-idx != next-idx {
                  let tangent-angle = _direction-angle(pts.at(prev-idx), pts.at(next-idx))
                  // Avoid both tangent directions
                  avoid-angles.push(tangent-angle)
                  avoid-angles.push(_normalize-angle(tangent-angle + 180))
                }
              }
            }
          }
        }

        // 5. Add extra avoid points if specified
        for avoid-name in avoid-extra {
          if avoid-name in points-store {
            let avoid-pt = points-store.at(avoid-name)
            let (_, avoid-c) = cetz.coordinate.resolve(ctx, avoid-pt)
            let dist = util.dist(c, avoid-c)
            if dist > 0.001 {
              let angle = _direction-angle(c, avoid-c)
              avoid-angles.push(angle)
            }
          }
        }

        // Compute optimal position
        pos = compute-auto-label-position(avoid-angles)
      }

      // Convert position + offset into a coordinate and a cetz anchor.
      let base-coord = (c.at(0) + offset.at(0), c.at(1) + offset.at(1))

      let final-label = if label-content == none {
        [$#_math-label(name)$]
      } else if type(label-content) == str {
        // Default to math mode for string labels unless explicitly opted out.
        let math = if type(spec) == dictionary {
          spec.at("math", default: true)
        } else {
          true
        }
        if math { [$#_math-label(label-content)$] } else { label-content }
      } else {
        label-content
      }

      // Skip exact duplicates (same point, same content): drawing them again
      // is almost always accidental (e.g. path auto-labels + ctz-draw-labels)
      let label-id = name + "|" + repr(final-label)
      if label-id in drawn-ids { continue }
      drawn-ids.push(label-id)

      let engine-on = if avoid-flag == auto { avoid-cfg.enabled } else { avoid-flag }
      let known-pos = pos in ("above", "below", "left", "right",
        "above left", "above right", "below left", "below right")

      // Sibling / extra point obstacles for this label (own point excluded)
      let obs-points = ()
      for other-name in names {
        if other-name != name {
          let oc = resolved-points.at(other-name)
          obs-points.push((oc.at(0), oc.at(1), point-size))
        }
      }
      for avoid-name in avoid-extra {
        if avoid-name in points-store {
          let (_, ac) = cetz.coordinate.resolve(ctx, points-store.at(avoid-name))
          obs-points.push((ac.at(0), ac.at(1), point-size))
        }
      }

      specs.push((
        name: name,
        pos: pos,
        base-coord: base-coord,
        own: c,
        final-label: final-label,
        engine-on: engine-on,
        known-pos: known-pos,
        obs-points: obs-points,
      ))
    }

    // ----------------------------------------------------------------------
    // Placement at a UNIFORM group scale: if any label of the figure must
    // shrink to fit, all labels of the figure use the same (smallest needed)
    // scale — mixed label sizes look accidental. The scale is sticky for
    // later label calls in the same canvas via shared-state.
    // ----------------------------------------------------------------------
    // pad: the 5pt content padding is the visual gap between the point and
    // the label; the collision rect includes it (converted to canvas units).
    let pad = 5pt / ctx.length
    let cfg = (
      pad: pad,
      // texts of neighboring labels may come as close as 2pt
      label-pad: 1pt / ctx.length,
      ring-step: avoid-cfg.ring-step,
      rings: avoid-cfg.rings,
      weights: avoid-cfg.weights,
      margin: avoid-cfg.margin,
      assoc-factor: avoid-cfg.at("assoc-factor", default: 1.15),
    )

    let measure-at(label, s) = {
      let m = if s == 1.0 { measure(label) } else { measure(text(size: 1em * s, label)) }
      (m.width / ctx.length, m.height / ctx.length)
    }

    // Allowed scales, largest first, capped by the canvas' sticky group scale
    let group-scale = ctx.shared-state.at("ctz-label-scale", default: 1.0)
    let all-scales = (1.0,) + avoid-cfg.shrink.map(float)
    let scales = all-scales.filter(s => s <= group-scale + 1e-9)
    if scales.len() == 0 { scales = (all-scales.last(),) }

    // One placement pass over all labels at the given allowed scales.
    // Returns the results and the scales actually used.
    let run-pass(scales) = {
      let placed2 = placed
      let results = ()
      for sp in specs {
        let top = scales.first()
        let (w, h) = measure-at(sp.final-label, top)
        if sp.engine-on and sp.known-pos and w > 0 and h > 0 {
          let sizes = ()
          for s in scales {
            let (ws, hs) = measure-at(sp.final-label, s)
            sizes.push((scale: s, w: ws, h: hs))
          }
          let obstacles = (
            segments: drawn-lines,
            circles: drawn-circles,
            points: drawn-points.filter(p => util.dist((p.at(0), p.at(1)), sp.own) > 1e-6) + sp.obs-points,
            labels: placed2,
          )
          let placement = find-label-placement(sp.pos, sp.base-coord, sizes, obstacles, cfg)
          placed2.push(placement.rect)
          results.push((
            name: sp.name, final-label: sp.final-label,
            pos: placement.pos, coord: placement.coord, scale: placement.scale,
          ))
        } else {
          // Engine off (or unknown pos / empty label): exact requested spot
          // at the group scale; register the tight rect if it has a size.
          if sp.known-pos and w > 0 and h > 0 {
            placed2.push(anchor-candidate-rect(sp.pos, sp.base-coord, w, h, 1pt / ctx.length))
          }
          results.push((
            name: sp.name, final-label: sp.final-label,
            pos: sp.pos, coord: sp.base-coord, scale: top,
          ))
        }
      }
      (results, placed2)
    }

    let (results, placed2) = run-pass(scales)
    // Uniform-scale fixpoint: cap the allowed scales at the smallest used
    // scale and re-place until every label uses the same scale. Bounded by
    // the (short) shrink list, so this terminates in <= its length passes.
    let guard = 0
    while results.len() > 0 and guard < 4 {
      let used = results.map(r => r.scale)
      let min-used = calc.min(..used)
      if used.all(s => s == min-used) { break }
      scales = scales.filter(s => s <= min-used + 1e-9)
      (results, placed2) = run-pass(scales)
      guard += 1
    }
    placed = placed2

    // Remember the group scale for later label calls in this canvas
    let final-scale = calc.min(..results.map(r => r.scale), 1.0)
    ctx.shared-state.insert("ctz-label-scale", calc.min(group-scale, final-scale))

    for r in results {
      let anchor = draw.ctz-pos-to-anchor(r.pos)
      let body = if r.scale == 1.0 { r.final-label } else { text(size: 1em * r.scale, r.final-label) }
      // 5pt is an absolute length → gap between label and point is canvas-scale independent.
      elements += cetz-draw.content(r.coord, body, anchor: anchor, padding: 5pt)
    }

    ctx.shared-state.insert("ctz-drawn-label-ids", drawn-ids)
    ctx.shared-state.insert(_placed-labels-key, placed)
    (ctx, elements)
  })
}

// =============================================================================
// DRAWING COMMANDS
// =============================================================================


/// Draw a segment with optional arrows and dimension label
/// Usage: draw-segment(cetz-draw, pt, "A", "B", arrows: "->", dim: $5$, stroke: black)
#let draw-segment(cetz-draw, pt-func, p1-name, p2-name, arrows: none, dim: none, dim-pos: "above", dim-dist: 0.3, stroke: black, mark: none) = {
  draw-with-state(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    let clip = get-clip-region(ctx)
    if clip != none {
      let result = clip-line-to-rect(c1.at(0), c1.at(1), c2.at(0), c2.at(1), clip.xmin, clip.ymin, clip.xmax, clip.ymax)
      if result == none { return (ctx, none) }
      let ((x0, y0), (x1, y1)) = result
      c1 = (x0, y0)
      c2 = (x1, y1)
    }

    // Track drawn segment for label avoidance
    ctx = _record-segment(ctx, c1, c2)

    // Determine mark style - prefer explicit mark parameter over arrows
    let mark-start = none
    let mark-end = none

    if mark != none {
      // Use explicit mark parameter if provided
      if type(mark) == dictionary {
        mark-start = mark.at("start", default: none)
        mark-end = mark.at("end", default: none)
      }
    } else if arrows != none {
      // Fall back to arrows parameter
      if arrows == "->" { mark-end = ">" }
      else if arrows == "<-" { mark-start = ">" }
      else if arrows == "<->" { mark-start = ">"; mark-end = ">" }
      else if arrows == "|-|" { mark-start = "|"; mark-end = "|" }
      else if arrows == "|->" { mark-start = "|"; mark-end = ">" }
      else if arrows == "<-|" { mark-start = ">"; mark-end = "|" }
    }

    // Draw the segment
    let elements = ()
    if mark-start != none or mark-end != none {
      elements += cetz-draw.line(c1, c2, stroke: stroke, mark: (start: mark-start, end: mark-end))
    } else {
      elements += cetz-draw.line(c1, c2, stroke: stroke)
    }

    // Add dimension label if requested
    if dim != none {
      let mx = (c1.at(0) + c2.at(0)) / 2
      let my = (c1.at(1) + c2.at(1)) / 2
      let dx = c2.at(0) - c1.at(0)
      let dy = c2.at(1) - c1.at(1)
      let len = calc.sqrt(dx*dx + dy*dy)

      if len > 0.001 {
        // Perpendicular direction for label offset
        let px = -dy / len * dim-dist
        let py = dx / len * dim-dist

        let label-pos = if dim-pos == "below" {
          (mx - px, my - py)
        } else {
          (mx + px, my + py)
        }

        // Register the dim label rect so point labels can avoid it
        let m = measure(dim)
        let (w, h) = (m.width / ctx.length, m.height / ctx.length)
        if w > 0 and h > 0 {
          ctx = _record-label-rect(ctx, (
            label-pos.at(0) - w / 2, label-pos.at(1) - h / 2,
            label-pos.at(0) + w / 2, label-pos.at(1) + h / 2,
          ))
        }

        elements += cetz-draw.content(label-pos, dim)
      }
    }
    (ctx, elements)
  })
}

/// Draw a measurement line offset from a segment, with fences and label
/// Similar to TikZ/tkz-euclide dim option
///
/// Features:
/// - Line parallel to segment at specified offset
/// - Perpendicular connector/fence lines from segment endpoints to dimension line
/// - Arrows pointing outward at both ends
/// - Label centered along the line with line breaking around it (sloped text)
///
/// Usage: draw-measure-segment(cetz-draw, pt, "A", "B", label: $5$, offset: 0.3)
///
/// Parameters:
/// - stroke: Color and thickness (e.g., black + 0.6pt)
/// - fence-stroke: Stroke for fence lines (default: auto = same as stroke)
/// - fence-dash: Dash style for fence lines (default: "dotted")
/// - arrows: Arrow style ("<->", "->", "<-", or none)
/// - arrow-size: Size of arrow heads
/// - label-gap: Extra padding around label (gap auto-adjusts to text width)
/// - label-size: Font size for label text
#let draw-measure-segment(
  cetz-draw,
  pt-func,
  p1-name,
  p2-name,
  label: none,
  offset: 0.3,
  side: "left",
  stroke: black + 0.6pt,
  fence-stroke: auto,
  fence-dash: "dotted",
  arrows: "<->",
  open-arrows: true,
  arrow-size: 0.12,
  label-pos: 0.5,
  label-gap: 0.15,
  label-angle: auto,
  label-size: 0.85em,
) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)
    let len = calc.sqrt(dx*dx + dy*dy)
    if len < 0.001 { return }

    // Unit direction and perpendicular
    let ux = dx / len
    let uy = dy / len
    let px = -uy
    let py = ux
    if side == "right" {
      px = -px
      py = -py
    } else if side == "above" {
      if py < 0 or (py == 0 and px > 0) {
        px = -px
        py = -py
      }
    } else if side == "below" {
      if py > 0 or (py == 0 and px < 0) {
        px = -px
        py = -py
      }
    }

    // Offset points for the measurement line
    let ox = px * offset
    let oy = py * offset
    let m1 = (c1.at(0) + ox, c1.at(1) + oy)
    let m2 = (c2.at(0) + ox, c2.at(1) + oy)

    // Fence stroke defaults to same as main stroke if auto
    let actual-fence-stroke = if fence-stroke == auto { stroke } else { fence-stroke }

    // Fence lines from segment endpoints to measurement line
    cetz-draw.line(c1, m1, stroke: actual-fence-stroke, dash: fence-dash)
    cetz-draw.line(c2, m2, stroke: actual-fence-stroke, dash: fence-dash)

    // Main stroke for measurement line
    let main-stroke = stroke

    // Calculate gap size based on label width (if present)
    let gap = 0
    if label != none {
      // Measure the label text to get its width
      let label-content = text(size: label-size)[#label]
      let label-size-measured = measure(label-content)
      // Gap = text width + padding on both sides
      // Convert from pt to canvas units (assuming 1cm = 28.35pt default)
      let text-width-cm = label-size-measured.width / 28.35pt
      gap = text-width-cm + label-gap  // label-gap becomes padding
    }

    let hx = (m2.at(0) - m1.at(0)) * label-pos
    let hy = (m2.at(1) - m1.at(1)) * label-pos
    let gdx = ux * gap / 2
    let gdy = uy * gap / 2
    let g1 = (m1.at(0) + hx - gdx, m1.at(1) + hy - gdy)
    let g2 = (m1.at(0) + hx + gdx, m1.at(1) + hy + gdy)

    // Draw measurement line in two parts with gap for label
    let mark-style = if open-arrows { (symbol: ">", size: arrow-size, fill: none) } else { (symbol: ">", size: arrow-size) }

    // Part 1: from m1 to gap-start with arrow pointing inward
    if arrows == "<->" or arrows == "<-" {
      cetz-draw.line(m1, g1, stroke: main-stroke,
        mark: (start: mark-style))
    } else {
      cetz-draw.line(m1, g1, stroke: main-stroke)
    }

    // Part 2: from m2 to gap-end with arrow pointing inward
    if arrows == "<->" or arrows == "->" {
      cetz-draw.line(m2, g2, stroke: main-stroke,
        mark: (start: mark-style))
    } else {
      cetz-draw.line(g2, m2, stroke: main-stroke)
    }

    // Draw label along the measurement line
    if label != none {
      // Calculate angle from segment direction
      let angle = label-angle
      if angle == auto {
        // NOTE: Typst's calc.atan2 uses (x, y) argument order, not (y, x)!
        angle = calc.atan2(dx, dy)
      }
      // Keep text readable (not upside down)
      if angle > 90deg { angle = angle - 180deg }
      else if angle < -90deg { angle = angle + 180deg }

      // Position label at midpoint of measurement line (between g1 and g2)
      // The label sits ON the line itself, not offset
      let mid-x = m1.at(0) + (m2.at(0) - m1.at(0)) * label-pos
      let mid-y = m1.at(1) + (m2.at(1) - m1.at(1)) * label-pos

      cetz-draw.content((mid-x, mid-y), text(size: label-size)[#label], angle: angle, anchor: "center")
    }
  })
}

/// Draw an arc between two points around a center
/// Usage: draw-arc(cetz-draw, pt, "O", "A", "B", stroke: black, arrows: "->")
#let draw-arc-through(cetz-draw, pt-func, center-name, start-name, end-name, stroke: black, arrows: none, delta: 0) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, pt-func(center-name))
    let (_, s) = cetz.coordinate.resolve(ctx, pt-func(start-name))
    let (_, e) = cetz.coordinate.resolve(ctx, pt-func(end-name))

    let radius = util.dist(c, s)
    let start-angle = util.angle-of(s.at(0) - c.at(0), s.at(1) - c.at(1))
    let end-angle = util.angle-of(e.at(0) - c.at(0), e.at(1) - c.at(1))

    // Apply delta extension
    let start-deg = if type(start-angle) == angle { start-angle } else { start-angle * 1deg }
    let end-deg = if type(end-angle) == angle { end-angle } else { end-angle * 1deg }
    start-deg = start-deg - delta * 1deg
    end-deg = end-deg + delta * 1deg

    // Determine marks
    let mark-start = none
    let mark-end = none
    if arrows != none {
      if arrows == "->" { mark-end = (symbol: ">") }
      else if arrows == "<-" { mark-start = (symbol: ">") }
      else if arrows == "<->" { mark-start = (symbol: ">"); mark-end = (symbol: ">") }
    }

    cetz-draw.arc(
      c,
      start: start-deg,
      stop: end-deg,
      radius: radius,
      anchor: "origin",
      stroke: stroke,
      mark: if mark-start != none or mark-end != none { (start: mark-start, end: mark-end) } else { none }
    )
  })
}

/// Draw an arc with explicit radius and angles
/// Usage: draw-arc-r(cetz-draw, "O", radius, start-angle, end-angle, stroke: black)
#let draw-arc-r(cetz-draw, center, radius, start-angle, end-angle, stroke: black, arrows: none) = {
  let mark-start = none
  let mark-end = none
  if arrows != none {
    if arrows == "->" { mark-end = (symbol: ">") }
    else if arrows == "<-" { mark-start = (symbol: ">") }
    else if arrows == "<->" { mark-start = (symbol: ">"); mark-end = (symbol: ">") }
  }

  cetz-draw.arc(
    center,
    start: start-angle,
    stop: end-angle,
    radius: radius,
    anchor: "origin",
    stroke: stroke,
    mark: if mark-start != none or mark-end != none { (start: mark-start, end: mark-end) } else { none }
  )
}


/// Draw an ellipse (axis-aligned or rotated)
/// Usage: draw-ellipse(cetz-draw, (0, 0), 3, 2, angle: 30deg)
#let draw-ellipse(cetz-draw, center, rx, ry, angle: 0deg, steps: 120, stroke: black, fill: none) = {
  let rot = util.to-angle(angle)
  if rot == 0deg {
    cetz-draw.circle(center, radius: (rx, ry), stroke: stroke, fill: fill)
  } else {
    let pts = conic.ellipse-points-raw(center, rx, ry, angle: rot, steps: steps)
    cetz-draw.line(..pts, stroke: stroke, fill: fill)
  }
}

/// Draw a parabola defined by focus and directrix
/// Usage: draw-parabola(cetz-draw, focus, dir-a, dir-b, extent: 4, stroke: black)
#let draw-parabola-focus-directrix(
  cetz-draw,
  focus,
  directrix-a,
  directrix-b,
  extent: auto,
  steps: 120,
  stroke: black,
) = {
  let pts = conic.parabola-points-focus-directrix-raw(focus, directrix-a, directrix-b, extent: extent, steps: steps)
  if pts.len() > 1 {
    cetz-draw.line(..pts, stroke: stroke)
  }
}

/// Draw a parabola from focus, p, angle
#let draw-parabola-focus(
  cetz-draw,
  focus,
  p,
  angle: 0deg,
  extent: auto,
  steps: 120,
  stroke: black,
) = {
  let pts = conic.parabola-points-from-focus-raw(focus, p, angle: angle, extent: extent, steps: steps)
  if pts.len() > 1 {
    cetz-draw.line(..pts, stroke: stroke)
  }
}

/// Draw a tangent line on an ellipse at parameter t
#let draw-ellipse-tangent(
  cetz-draw,
  center,
  rx,
  ry,
  t,
  angle: 0deg,
  length: auto,
  stroke: black,
) = {
  let (p1, p2, _pt) = conic.ellipse-tangent-raw(center, rx, ry, angle: angle, t: t, length: length)
  cetz-draw.line(p1, p2, stroke: stroke)
}

/// Draw a tangent line on a parabola at parameter t
#let draw-parabola-tangent(
  cetz-draw,
  focus,
  directrix-a,
  directrix-b,
  t,
  length: auto,
  stroke: black,
) = {
  let res = conic.parabola-tangent-raw(focus, directrix-a, directrix-b, t, length: length)
  if res != none {
    let (p1, p2, _pt) = res
    cetz-draw.line(p1, p2, stroke: stroke)
  }
}

/// Draw tangents from an external point to a parabola
#let draw-parabola-tangents-from-point(
  cetz-draw,
  focus,
  directrix-a,
  directrix-b,
  external,
  length: auto,
  stroke: black,
) = {
  let res = conic.parabola-tangents-from-point-raw(focus, directrix-a, directrix-b, external, length: length)
  for item in res {
    let (p1, p2, _pt) = item
    cetz-draw.line(p1, p2, stroke: stroke)
  }
}

/// Draw a projectile trajectory with optional velocity vectors
/// Usage: draw-projectile(cetz-draw, origin, velocity, gravity: 9.81, vectors: true)
#let draw-projectile(
  cetz-draw,
  origin,
  velocity,
  gravity: 9.81,
  t-max: auto,
  steps: 80,
  y-floor: none,
  stroke: black,
  vectors: false,
  vector-count: 5,
  vector-scale: 0.12,
  vector-stroke: gray + 0.8pt,
) = {
  let (pts, t-end) = conic.projectile-points-raw(origin, velocity, gravity, t-max, steps: steps, y-floor: y-floor)
  if pts.len() > 1 {
    cetz-draw.line(..pts, stroke: stroke)
  }

  if vectors and vector-count > 1 {
    for i in range(0, vector-count) {
      let t = t-end * i / (vector-count - 1)
      let p = conic.projectile-position-raw(origin, velocity, gravity, t)
      let v = conic.projectile-velocity-raw(velocity, gravity, t)
      let q = (p.at(0) + v.at(0) * vector-scale, p.at(1) + v.at(1) * vector-scale, p.at(2, default: 0))
      cetz-draw.line(p, q, stroke: vector-stroke, mark: (end: ">"))
    }
  }
}


/// Draw an extended line beyond two points
/// Usage: draw-line-extended(cetz-draw, pt, "A", "B", add: (0.5, 0.5), stroke: black)
#let draw-line-add(cetz-draw, pt-func, p1-name, p2-name, add: (0.2, 0.2), stroke: black) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)

    let (add-before, add-after) = if type(add) == array { add } else { (add, add) }

    let start = (c1.at(0) - add-before * dx, c1.at(1) - add-before * dy)
    let end = (c2.at(0) + add-after * dx, c2.at(1) + add-after * dy)

    let clip = get-clip-region(ctx)
    if clip == none {
      cetz-draw.line(start, end, stroke: stroke)
    } else {
      let result = clip-line-to-rect(start.at(0), start.at(1), end.at(0), end.at(1), clip.xmin, clip.ymin, clip.xmax, clip.ymax)
      if result != none {
        let ((x0, y0), (x1, y1)) = result
        cetz-draw.line((x0, y0), (x1, y1), stroke: stroke)
      }
    }
  })
}

// =============================================================================
// MARKING COMMANDS
// =============================================================================

/// Mark a segment with tick marks (|, ||, |||)
/// Usage: mark-segment(cetz-draw, pt, "A", "B", mark: 1, size: 0.15)
#let mark-segment(cetz-draw, pt-func, p1-name, p2-name, mark: 1, size: 0.15, pos: 0.5, color: draw.default-mark-color, slant: 20deg, thickness: draw.default-mark-stroke-width) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)
    let len = calc.sqrt(dx*dx + dy*dy)

    if len < 0.001 { return }

    // Mid point (or at position)
    let mx = c1.at(0) + pos * dx
    let my = c1.at(1) + pos * dy

    // Perpendicular direction (unit), normalized to be direction-invariant
    let ux = -dy / len
    let uy = dx / len
    if ux < 0 or (ux == 0 and uy < 0) {
      ux = -ux
      uy = -uy
    }

    // Slight slant for tick marks; double ticks slant the other way
    let s = if type(slant) == angle { slant } else { slant * 1deg }
    if mark >= 2 { s = -s }
    let rx = ux * calc.cos(s) - uy * calc.sin(s)
    let ry = ux * calc.sin(s) + uy * calc.cos(s)

    let px = rx * size
    let py = ry * size

    // Spacing between ticks
    let spacing = size * 1.1

    for i in range(mark) {
      let offset = (i - (mark - 1) / 2) * spacing
      let cx = mx + offset * dx / len
      let cy = my + offset * dy / len
      cetz-draw.line((cx - px, cy - py), (cx + px, cy + py), stroke: color + thickness)
    }
  })
}

/// Mark a right angle with a small square
/// Usage: mark-right-angle(cetz-draw, pt, "A", "B", "C", size: 0.25, color: black, fill: none)
#let mark-right-angle(cetz-draw, pt-func, a-name, vertex-name, c-name, size: 0.25, color: black, fill: none, german: false) = {
  cetz-draw.get-ctx(ctx => {
    let (_, pa) = cetz.coordinate.resolve(ctx, pt-func(a-name))
    let (_, pv) = cetz.coordinate.resolve(ctx, pt-func(vertex-name))
    let (_, pc) = cetz.coordinate.resolve(ctx, pt-func(c-name))

    // Unit vectors from vertex to A and C
    let va-x = pa.at(0) - pv.at(0)
    let va-y = pa.at(1) - pv.at(1)
    let vc-x = pc.at(0) - pv.at(0)
    let vc-y = pc.at(1) - pv.at(1)

    let va-len = calc.sqrt(va-x * va-x + va-y * va-y)
    let vc-len = calc.sqrt(vc-x * vc-x + vc-y * vc-y)

    if va-len < 1e-9 or vc-len < 1e-9 { return }

    va-x = va-x / va-len * size
    va-y = va-y / va-len * size
    vc-x = vc-x / vc-len * size
    vc-y = vc-y / vc-len * size

    cetz.draw.on-layer(-1, {
      if german {
        // German style: small arc
        let start-angle = util.angle-of(va-x, va-y)
        let end-angle = util.angle-of(vc-x, vc-y)
        let start-deg = if type(start-angle) == angle { start-angle } else { start-angle * 1deg }
        let end-deg = if type(end-angle) == angle { end-angle } else { end-angle * 1deg }
        cetz-draw.arc(pv, start: start-deg, stop: end-deg, radius: size, anchor: "origin", stroke: color + 1pt)
      } else {
        // Standard square marker
        let p1 = (pv.at(0) + va-x, pv.at(1) + va-y)
        let p2 = (pv.at(0) + va-x + vc-x, pv.at(1) + va-y + vc-y)
        let p3 = (pv.at(0) + vc-x, pv.at(1) + vc-y)

        cetz-draw.line(p1, p2, p3, stroke: color + 1pt)
        if fill != none {
          cetz-draw.line(pv, p1, p2, p3, close: true, fill: fill, stroke: none)
        }
      }
    })
  })
}

/// Fill an angle (without drawing the arc border)
/// Usage: fill-angle(cetz-draw, cetz-angle, pt, "B", "A", "C", color: blue.lighten(80%), radius: 0.6)
#let fill-angle(cetz-draw, cetz-angle-mod, pt-func, vertex-name, a-name, c-name, color: gray.lighten(70%), radius: 0.6, opacity: 1) = {
  let actual-color = if opacity < 1 {
    color.transparentize((1 - opacity) * 100%)
  } else {
    color
  }

  cetz.draw.on-layer(-1, {
    cetz-angle-mod.angle(
      pt-func(vertex-name), pt-func(a-name), pt-func(c-name),
      radius: radius,
      fill: actual-color,
      stroke: none,
    )
  })
}

/// Label a segment with text
/// Usage: label-segment(cetz-draw, pt, "A", "B", label: $5$, pos: 0.5, above: true, sloped: false)
#let label-segment(cetz-draw, pt-func, p1-name, p2-name, label: none, pos: 0.5, above: true, sloped: false, dist: 0.2) = {
  if label == none { return }

  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)
    let len = calc.sqrt(dx*dx + dy*dy)

    if len < 0.001 { return }

    // Position along segment
    let mx = c1.at(0) + pos * dx
    let my = c1.at(1) + pos * dy

    // Perpendicular offset
    let px = -dy / len * dist
    let py = dx / len * dist

    let label-pos = if above {
      (mx + px, my + py)
    } else {
      (mx - px, my - py)
    }

    if sloped {
      // Calculate rotation angle
      let angle = util.angle-of(dx, dy)
      let angle-deg = if type(angle) == angle { angle } else { angle * 1deg }
      // Adjust for readability (keep text right-side up)
      if angle-deg > 90deg { angle-deg = angle-deg - 180deg }
      else if angle-deg < -90deg { angle-deg = angle-deg + 180deg }
      cetz-draw.content(label-pos, label, angle: angle-deg)
    } else {
      cetz-draw.content(label-pos, label)
    }
  })
}

/// Label an angle with text at specified radius
/// Usage: label-angle(cetz-draw, pt, "B", "A", "C", label: $alpha$, pos: 0.8)
#let label-angle-at(cetz-draw, pt-func, vertex-name, a-name, c-name, label: none, pos: auto) = {
  if label == none { return }

  cetz-draw.get-ctx(ctx => {
    let (_, v) = cetz.coordinate.resolve(ctx, pt-func(vertex-name))
    let (_, pa) = cetz.coordinate.resolve(ctx, pt-func(a-name))
    let (_, pc) = cetz.coordinate.resolve(ctx, pt-func(c-name))

    let radius = if pos == auto { 0.5 } else { pos }

    // Calculate bisector direction
    let bisector = draw.angle-bisector-direction(pa, v, pc)

    let label-x = v.at(0) + radius * bisector.at(0)
    let label-y = v.at(1) + radius * bisector.at(1)

    cetz-draw.content((label-x, label-y), label)
  })
}

// =============================================================================
// GRID AND AXES
// =============================================================================

/// Inclusive list of values from vmin to vmax in exact multiples of step.
/// Avoids float accumulation (`while v <= vmax { v += step }` can skip the
/// last value, e.g. with step 0.1).
#let _step-values(vmin, vmax, step) = {
  let n = int(calc.floor((vmax - vmin) / step + 1e-9))
  range(n + 1).map(i => vmin + i * step)
}

/// Draw a grid
/// Usage: draw-grid(cetz-draw, xmin: -5, xmax: 5, ymin: -5, ymax: 5, step: 1)
#let draw-grid(
  cetz-draw,
  xmin: -5,
  xmax: 5,
  ymin: -5,
  ymax: 5,
  xstep: 1,
  ystep: 1,
  stroke: gray + 0.5pt,
  sub: false,
  sub-xstep: 0.5,
  sub-ystep: 0.5,
  sub-stroke: luma(200) + 0.25pt,
) = {
  // Draw sub-grid first if requested
  if sub {
    // Vertical sub-lines
    for x in _step-values(xmin, xmax, sub-xstep) {
      cetz-draw.line((x, ymin), (x, ymax), stroke: sub-stroke)
    }
    // Horizontal sub-lines
    for y in _step-values(ymin, ymax, sub-ystep) {
      cetz-draw.line((xmin, y), (xmax, y), stroke: sub-stroke)
    }
  }

  // Draw main grid lines
  // Vertical lines
  for x in _step-values(xmin, xmax, xstep) {
    cetz-draw.line((x, ymin), (x, ymax), stroke: stroke)
  }
  // Horizontal lines
  for y in _step-values(ymin, ymax, ystep) {
    cetz-draw.line((xmin, y), (xmax, y), stroke: stroke)
  }
}

/// Draw X and Y axes with optional tick marks and labels
/// Usage: draw-axes(cetz-draw, xmin: -5, xmax: 5, ymin: -5, ymax: 5)
#let draw-axes(
  cetz-draw,
  xmin: -5,
  xmax: 5,
  ymin: -5,
  ymax: 5,
  xstep: 1,
  ystep: 1,
  stroke: black + 1pt,
  ticks: true,
  tick-size: 0.1,
  labels: true,
  x-label: $x$,
  y-label: $y$,
  origin-label: $O$,
  arrow: true,
) = {
  let arrow-mark = if arrow { ">" } else { none }

  // Track axes for label avoidance
  cetz-draw.set-ctx(ctx => {
    let drawn = ctx.shared-state.at(_drawn-lines-key, default: ())
    drawn.push(((xmin, 0), (xmax, 0)))
    drawn.push(((0, ymin), (0, ymax)))
    ctx.shared-state.insert(_drawn-lines-key, drawn)
    ctx
  })

  // X axis
  cetz-draw.line((xmin, 0), (xmax, 0), stroke: stroke, mark: (end: arrow-mark))

  // Y axis
  cetz-draw.line((0, ymin), (0, ymax), stroke: stroke, mark: (end: arrow-mark))

  // X axis ticks
  if ticks {
    for x in _step-values(xmin, xmax, xstep) {
      if calc.abs(x) > 0.001 {  // Skip origin
        cetz-draw.line((x, -tick-size), (x, tick-size), stroke: stroke)
      }
    }

    // Y axis ticks
    for y in _step-values(ymin, ymax, ystep) {
      if calc.abs(y) > 0.001 {  // Skip origin
        cetz-draw.line((-tick-size, y), (tick-size, y), stroke: stroke)
      }
    }
  }

  // Labels
  if labels {
    // X axis tick labels
    for x in _step-values(xmin, xmax, xstep) {
      if calc.abs(x) > 0.001 {  // Skip origin
        let label-text = if calc.rem(x, 1) == 0 { str(int(x)) } else { str(x) }
        cetz-draw.content((x, -0.3), text(size: 8pt)[#label-text])
      }
    }

    // Y axis tick labels
    for y in _step-values(ymin, ymax, ystep) {
      if calc.abs(y) > 0.001 {  // Skip origin
        let label-text = if calc.rem(y, 1) == 0 { str(int(y)) } else { str(y) }
        cetz-draw.content((-0.3, y), text(size: 8pt)[#label-text])
      }
    }

    // Axis labels
    cetz-draw.content((xmax + 0.3, 0), x-label)
    cetz-draw.content((0, ymax + 0.3), y-label)

    // Origin label
    if origin-label != none {
      cetz-draw.content((-0.3, -0.3), origin-label)
    }
  }
}

/// Draw only X axis
#let draw-axis-x(
  cetz-draw,
  xmin: -5,
  xmax: 5,
  xstep: 1,
  stroke: black + 1pt,
  ticks: true,
  tick-size: 0.1,
  labels: true,
  label: $x$,
  arrow: true,
) = {
  let arrow-mark = if arrow { ">" } else { none }

  // X axis
  cetz-draw.line((xmin, 0), (xmax, 0), stroke: stroke, mark: (end: arrow-mark))

  // X axis ticks
  if ticks {
    for x in _step-values(xmin, xmax, xstep) {
      if calc.abs(x) > 0.001 {
        cetz-draw.line((x, -tick-size), (x, tick-size), stroke: stroke)
      }
    }
  }

  // Labels
  if labels {
    for x in _step-values(xmin, xmax, xstep) {
      if calc.abs(x) > 0.001 {
        let label-text = if calc.rem(x, 1) == 0 { str(int(x)) } else { str(x) }
        cetz-draw.content((x, -0.3), text(size: 8pt)[#label-text])
      }
    }
    cetz-draw.content((xmax + 0.3, 0), label)
  }
}

/// Draw only Y axis
#let draw-axis-y(
  cetz-draw,
  ymin: -5,
  ymax: 5,
  ystep: 1,
  stroke: black + 1pt,
  ticks: true,
  tick-size: 0.1,
  labels: true,
  label: $y$,
  arrow: true,
) = {
  let arrow-mark = if arrow { ">" } else { none }

  // Y axis
  cetz-draw.line((0, ymin), (0, ymax), stroke: stroke, mark: (end: arrow-mark))

  // Y axis ticks
  if ticks {
    for y in _step-values(ymin, ymax, ystep) {
      if calc.abs(y) > 0.001 {
        cetz-draw.line((-tick-size, y), (tick-size, y), stroke: stroke)
      }
    }
  }

  // Labels
  if labels {
    for y in _step-values(ymin, ymax, ystep) {
      if calc.abs(y) > 0.001 {
        let label-text = if calc.rem(y, 1) == 0 { str(int(y)) } else { str(y) }
        cetz-draw.content((-0.3, y), text(size: 8pt)[#label-text])
      }
    }
    cetz-draw.content((0, ymax + 0.3), label)
  }
}

/// Draw a horizontal line at y=value
#let draw-hline(cetz-draw, y, xmin: -10, xmax: 10, stroke: black) = {
  cetz-draw.line((xmin, y), (xmax, y), stroke: stroke)
}

/// Draw a vertical line at x=value
#let draw-vline(cetz-draw, x, ymin: -10, ymax: 10, stroke: black) = {
  cetz-draw.line((x, ymin), (x, ymax), stroke: stroke)
}

/// Place text at coordinates
#let draw-text(cetz-draw, x, y, content, angle: 0deg, anchor: "center") = {
  cetz-draw.content((x, y), content, angle: angle, anchor: anchor)
}

