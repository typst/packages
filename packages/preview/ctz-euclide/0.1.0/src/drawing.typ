// ctz-euclide/src/drawing.typ
// High-level drawing functions that work directly with cetz.draw

#import "@preview/cetz:0.4.2" as cetz
#import "util.typ"
#import "draw.typ"

/// Point style presets
#let point-styles = (
  cross: (shape: "cross", size: 4pt),
  dot: (shape: "dot", size: 3pt),
  circle: (shape: "circle", size: 3pt),
  plus: (shape: "plus", size: 4pt),
  square: (shape: "square", size: 3pt),
  diamond: (shape: "diamond", size: 4pt),
  triangle: (shape: "triangle", size: 4pt),
)

/// Draw a point with specified style
/// Usage: draw-point(cetz-draw, "ctz:A", style: "cross")
#let draw-point(cetz-draw, coord, style: "cross", color: black) = {
  let s = point-styles.at(style, default: point-styles.cross)
  let sz = s.size

  if s.shape == "dot" {
    cetz-draw.circle(coord, radius: sz, fill: color, stroke: none)
  } else if s.shape == "circle" {
    cetz-draw.circle(coord, radius: sz, fill: white, stroke: color + 1pt)
  } else if s.shape == "cross" {
    cetz-draw.line((rel: (-sz, -sz), to: coord), (rel: (sz, sz), to: coord), stroke: color + 1.5pt)
    cetz-draw.line((rel: (-sz, sz), to: coord), (rel: (sz, -sz), to: coord), stroke: color + 1.5pt)
  } else if s.shape == "plus" {
    cetz-draw.line((rel: (-sz, 0pt), to: coord), (rel: (sz, 0pt), to: coord), stroke: color + 1.5pt)
    cetz-draw.line((rel: (0pt, -sz), to: coord), (rel: (0pt, sz), to: coord), stroke: color + 1.5pt)
  } else if s.shape == "square" {
    cetz-draw.rect((rel: (-sz, -sz), to: coord), (rel: (sz, sz), to: coord), fill: color, stroke: none)
  } else if s.shape == "diamond" {
    cetz-draw.line(
      (rel: (0pt, sz), to: coord),
      (rel: (sz, 0pt), to: coord),
      (rel: (0pt, -sz), to: coord),
      (rel: (-sz, 0pt), to: coord),
      close: true, fill: color, stroke: none
    )
  } else if s.shape == "triangle" {
    cetz-draw.line(
      (rel: (0pt, sz), to: coord),
      (rel: (sz * 0.866, -sz * 0.5), to: coord),
      (rel: (-sz * 0.866, -sz * 0.5), to: coord),
      close: true, fill: color, stroke: none
    )
  }
}

/// Draw multiple points
#let draw-points(cetz-draw, pt-func, ..names, style: "cross", color: black) = {
  for name in names.pos() {
    draw-point(cetz-draw, pt-func(name), style: style, color: color)
  }
}

/// Draw segment tick marks (for indicating equal lengths)
/// count: 1 = |, 2 = ||, 3 = |||
#let draw-segment-mark(cetz-draw, p1, p2, count: 1, size: 0.15, color: black) = {
  // This needs raw coordinates, so we use a get-ctx approach
  cetz-draw.get-ctx(ctx => {
    // Resolve coordinates
    let (_, c1) = cetz.coordinate.resolve(ctx, p1)
    let (_, c2) = cetz.coordinate.resolve(ctx, p2)

    let mx = (c1.at(0) + c2.at(0)) / 2
    let my = (c1.at(1) + c2.at(1)) / 2
    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)
    let len = calc.sqrt(dx*dx + dy*dy)

    if len < 0.001 { return }

    // Perpendicular direction
    let px = -dy / len * size
    let py = dx / len * size

    // Draw ticks
    let spacing = size * 2.4
    for i in range(count) {
      let offset = (i - (count - 1) / 2) * spacing
      let cx = mx + offset * dx / len
      let cy = my + offset * dy / len
      cetz-draw.line((cx - px, cy - py), (cx + px, cy + py), stroke: color + 1.5pt)
    }
  })
}

/// Draw a compass arc (construction arc showing equal distances)
#let draw-compass(cetz-draw, center, through, delta: 60, color: gray, stroke-width: 0.5pt) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, center)
    let (_, t) = cetz.coordinate.resolve(ctx, through)

    let radius = util.dist(c, t)
    let theta = calc.atan2(t.at(1) - c.at(1), t.at(0) - c.at(0))

    // Convert to an angle value (Typst angle type) if needed.
    // `calc.atan2` may return either an angle or a unitless number (radians).
    let theta-angle = if type(theta) == angle { theta } else { theta * 180 / calc.pi * 1deg }

    let half-delta = delta / 2 * 1deg
    cetz-draw.arc(
      center,
      start: theta-angle - half-delta,
      stop: theta-angle + half-delta,
      radius: radius,
      stroke: color + stroke-width
    )
  })
}

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
    label-point(cetz-draw, pt-func(name), [$#name$], pos: p, dist: dist)
  }
}

/// Draw arc tick mark (for equal arcs)
#let draw-arc-mark(cetz-draw, center, start-pt, end-pt, count: 1, size: 0.2, color: black) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, center)
    let (_, s) = cetz.coordinate.resolve(ctx, start-pt)
    let (_, e) = cetz.coordinate.resolve(ctx, end-pt)

    let radius = util.dist(c, s)
    let start-angle = calc.atan2(s.at(1) - c.at(1), s.at(0) - c.at(0))
    let end-angle = calc.atan2(e.at(1) - c.at(1), e.at(0) - c.at(0))

    // Convert to degrees
    let to-deg(a) = if type(a) == angle { a / 1deg } else { a * 180 / calc.pi }
    let start-deg = to-deg(start-angle)
    let end-deg = to-deg(end-angle)

    // Normalize angles
    if end-deg < start-deg { end-deg = end-deg + 360 }

    let mid-deg = (start-deg + end-deg) / 2
    let spacing = 3  // degrees

    for i in range(count) {
      let offset = (i - (count - 1) / 2) * spacing
      let angle-deg = mid-deg + offset
      let angle-rad = angle-deg * calc.pi / 180

      let px = c.at(0) + radius * calc.cos(angle-rad)
      let py = c.at(1) + radius * calc.sin(angle-rad)
      let rx = calc.cos(angle-rad)
      let ry = calc.sin(angle-rad)

      cetz-draw.line(
        (px - size/2 * rx, py - size/2 * ry),
        (px + size/2 * rx, py + size/2 * ry),
        stroke: color + 1.5pt
      )
    }
  })
}

/// Draw an extended line (beyond the two points)
#let draw-line-extended(cetz-draw, p1, p2, extend-before: 0.5, extend-after: 0.5, ..style) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, p1)
    let (_, c2) = cetz.coordinate.resolve(ctx, p2)

    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)

    let start = (c1.at(0) - extend-before * dx, c1.at(1) - extend-before * dy)
    let end = (c2.at(0) + extend-after * dx, c2.at(1) + extend-after * dy)

    cetz-draw.line(start, end, ..style)
  })
}

/// Mark an angle with arc and label, with smart label positioning
/// - vertex: the vertex of the angle (where the arc is drawn)
/// - a, b: the two rays endpoints (angle is measured from a to b counterclockwise)
/// - label: the label content (e.g., $alpha$ or $30°$)
/// - radius: arc radius (default 0.6)
/// - label-radius: distance from vertex to label center along bisector (default: radius + 0.2)
/// - label-offset: (along, perp) offset relative to bisector direction (default: (0, 0))
///   - along: moves label along bisector (negative = closer to vertex, positive = farther)
///   - perp: moves label perpendicular to bisector (positive = counterclockwise, negative = clockwise)
/// - direction: "ccw" (counter-clockwise) or "cw" (clockwise)
/// - stroke: arc stroke style
/// - fill: arc fill color
#let mark-angle(
  cetz-draw,
  cetz-angle,
  vertex,
  a,
  b,
  label: none,
  radius: 0.6,
  label-radius: auto,
  label-offset: (0, 0),
  direction: auto,
  stroke: black,
  fill: none,
  name: none,
) = {
  cetz-draw.get-ctx(ctx => {
    // Determine direction if set to auto
    let final-direction = direction
    if direction == auto {
      let (_, v) = cetz.coordinate.resolve(ctx, vertex)
      let (_, pa) = cetz.coordinate.resolve(ctx, a)
      let (_, pb) = cetz.coordinate.resolve(ctx, b)

      // Vectors from vertex to the two points
      let va = (pa.at(0) - v.at(0), pa.at(1) - v.at(1))
      let vb = (pb.at(0) - v.at(0), pb.at(1) - v.at(1))

      // Cross product: if positive, ccw angle from a to b is < 180°
      // if negative, ccw angle from a to b is > 180°, so use cw instead
      let cross = va.at(0) * vb.at(1) - va.at(1) * vb.at(0)

      // Draw the smaller (interior) angle:
      // - If cross >= 0, the ccw angle is smaller, so use "ccw"
      // - If cross < 0, the cw angle is smaller, so use "cw"
      final-direction = if cross >= 0 { "ccw" } else { "cw" }
    }

    // Draw the angle arc using cetz.angle on the background layer
    cetz.draw.on-layer(-1, {
      cetz-angle.angle(
        vertex, a, b,
        radius: radius,
        direction: final-direction,
        stroke: stroke,
        fill: fill,
        name: name,
        label: none,  // We handle label ourselves
      )
    })
  })

  // If there's a label, position it along the angle bisector
  if label != none {
    cetz-draw.get-ctx(ctx => {
      let (_, v) = cetz.coordinate.resolve(ctx, vertex)
      let (_, pa) = cetz.coordinate.resolve(ctx, a)
      let (_, pb) = cetz.coordinate.resolve(ctx, b)

      // Use the angle bisector direction - this reliably points toward
      // the interior of the angle (the smaller arc)
      let bisector = draw.angle-bisector-direction(pa, v, pb)

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

      cetz-draw.content((label-x, label-y), label)
    })
  }
}

/// Global style configuration key
#let _global-style-key = "ctz-global-style"

/// Default global style
#let default-global-style = (
  point: (
    shape: "cross",
    size: 0.12,
    stroke: black + 1.5pt,
  ),
  angle: (
    radius: 0.6,
    stroke: black,
    fill: none,
    label-radius: auto,
  ),
  label: (
    padding: 0.15,
    single-padding: 0.25,
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

/// Draw points using global style
/// Usage: draw-points-styled(cetz-draw, pt, "A", "B", "C", "O")
#let draw-points-styled(cetz-draw, pt-func, ..names) = {
  cetz-draw.get-ctx(ctx => {
    let style = get-style(ctx)
    let ps = style.point

    for name in names.pos() {
      let coord = pt-func(name)
      let (_, c) = cetz.coordinate.resolve(ctx, coord)
      let x = c.at(0)
      let y = c.at(1)
      let sz = ps.size

      if ps.shape == "cross" {
        cetz-draw.line((x - sz, y - sz), (x + sz, y + sz), stroke: ps.stroke)
        cetz-draw.line((x - sz, y + sz), (x + sz, y - sz), stroke: ps.stroke)
      } else if ps.shape == "dot" {
        cetz-draw.circle((x, y), radius: sz, fill: ps.at("fill", default: black), stroke: none)
      } else if ps.shape == "circle" {
        cetz-draw.circle((x, y), radius: sz, fill: ps.at("fill", default: none), stroke: ps.at("stroke", default: black))
      } else if ps.shape == "plus" {
        cetz-draw.line((x - sz, y), (x + sz, y), stroke: ps.stroke)
        cetz-draw.line((x, y - sz), (x, y + sz), stroke: ps.stroke)
      } else if ps.shape == "square" {
        cetz-draw.rect((x - sz, y - sz), (x + sz, y + sz), fill: ps.at("fill", default: black), stroke: none)
      }
    }
  })
}

/// Label multiple points with automatic positioning based on global style
/// Usage: label-points-styled(cetz-draw, pt, "A", "B", "C", A: "above", B: "below left")
/// Position can be a string or a dictionary with pos and offset: A: (pos: "above", offset: (0.1, 0))
#let label-points-styled(cetz-draw, pt-func, ..args) = {
  let names = args.pos()
  let positions = args.named()

  cetz-draw.get-ctx(ctx => {
    let style = get-style(ctx)
    let default-pos = "above"
    let padding = style.label.padding

    for name in names {
      let spec = positions.at(name, default: default-pos)
      let (pos, offset) = if type(spec) == str {
        (spec, (0, 0))
      } else if type(spec) == dictionary {
        (spec.at("pos", default: default-pos), spec.at("offset", default: (0, 0)))
      } else {
        (default-pos, (0, 0))
      }

      let anchor = draw.ctz-pos-to-anchor(pos)
      let label-padding = if pos in ("above", "below", "left", "right") {
        style.label.single-padding
      } else {
        padding
      }
      let coord = pt-func(name)
      let (_, c) = cetz.coordinate.resolve(ctx, coord)
      let label-coord = (c.at(0) + offset.at(0), c.at(1) + offset.at(1))

      cetz-draw.content(label-coord, [$#name$], anchor: anchor, padding: label-padding)
    }
  })
}

// =============================================================================
// DRAWING COMMANDS
// =============================================================================

/// Draw a polygon from named points
/// Usage: draw-polygon(cetz-draw, pt, "A", "B", "C", "D", stroke: black, fill: none)
#let draw-polygon(cetz-draw, pt-func, ..args) = {
  let names = args.pos()
  let style = args.named()
  let stroke-style = style.at("stroke", default: black)
  let fill-style = style.at("fill", default: none)
  let close = style.at("close", default: true)

  cetz-draw.get-ctx(ctx => {
    let coords = names.map(name => {
      let (_, c) = cetz.coordinate.resolve(ctx, pt-func(name))
      c
    })

    // Manually close by concatenating first point at end
    if close and coords.len() > 0 {
      coords = coords + (coords.at(0),)
    }

    cetz-draw.line(..coords, stroke: stroke-style, fill: fill-style)
  })
}

/// Fill a polygon (no stroke by default)
/// Usage: fill-polygon(cetz-draw, pt, "A", "B", "C", color: blue.lighten(80%), opacity: 0.5)
#let fill-polygon(cetz-draw, pt-func, ..args) = {
  let names = args.pos()
  let style = args.named()
  let fill-color = style.at("color", default: gray.lighten(50%))
  let opacity = style.at("opacity", default: 1)
  let stroke-style = style.at("stroke", default: none)

  cetz-draw.get-ctx(ctx => {
    let coords = names.map(name => {
      let (_, c) = cetz.coordinate.resolve(ctx, pt-func(name))
      c
    })

    let actual-fill = if opacity < 1 {
      fill-color.transparentize((1 - opacity) * 100%)
    } else {
      fill-color
    }

    cetz-draw.line(..coords, close: true, stroke: stroke-style, fill: actual-fill)
  })
}

/// Draw a segment with optional arrows and dimension label
/// Usage: draw-segment(cetz-draw, pt, "A", "B", arrows: "->", dim: $5$, stroke: black)
#let draw-segment(cetz-draw, pt-func, p1-name, p2-name, arrows: none, dim: none, dim-pos: "above", dim-dist: 0.3, stroke: black) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    // Determine mark style based on arrows parameter
    let mark-start = none
    let mark-end = none
    if arrows != none {
      if arrows == "->" { mark-end = ">" }
      else if arrows == "<-" { mark-start = ">" }
      else if arrows == "<->" { mark-start = ">"; mark-end = ">" }
      else if arrows == "|-|" { mark-start = "|"; mark-end = "|" }
      else if arrows == "|->" { mark-start = "|"; mark-end = ">" }
      else if arrows == "<-|" { mark-start = ">"; mark-end = "|" }
    }

    // Draw the segment
    if mark-start != none or mark-end != none {
      cetz-draw.line(c1, c2, stroke: stroke, mark: (start: mark-start, end: mark-end))
    } else {
      cetz-draw.line(c1, c2, stroke: stroke)
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

        cetz-draw.content(label-pos, dim)
      }
    }
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
    let start-angle = calc.atan2(s.at(1) - c.at(1), s.at(0) - c.at(0))
    let end-angle = calc.atan2(e.at(1) - c.at(1), e.at(0) - c.at(0))

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
    stroke: stroke,
    mark: if mark-start != none or mark-end != none { (start: mark-start, end: mark-end) } else { none }
  )
}

/// Draw a circle with explicit radius (R option)
/// Usage: draw-circle-r(cetz-draw, "O", 3, stroke: black, fill: none)
#let draw-circle-r(cetz-draw, center, radius, stroke: black, fill: none) = {
  cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
}

/// Draw a circle through a point
/// Usage: draw-circle-through(cetz-draw, pt, "O", "A", stroke: black)
#let draw-circle-through(cetz-draw, pt-func, center-name, through-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, pt-func(center-name))
    let (_, t) = cetz.coordinate.resolve(ctx, pt-func(through-name))
    let radius = util.dist(c, t)
    cetz-draw.circle(c, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw a circle by diameter
/// Usage: draw-circle-diameter(cetz-draw, pt, "A", "B", stroke: black)
#let draw-circle-diameter(cetz-draw, pt-func, p1-name, p2-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))
    let center = util.midpoint(c1, c2)
    let radius = util.dist(c1, c2) / 2
    cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw circumcircle of triangle
/// Usage: draw-circumcircle(cetz-draw, pt, "A", "B", "C", stroke: black)
#let draw-circumcircle(cetz-draw, pt-func, a-name, b-name, c-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, pa) = cetz.coordinate.resolve(ctx, pt-func(a-name))
    let (_, pb) = cetz.coordinate.resolve(ctx, pt-func(b-name))
    let (_, pc) = cetz.coordinate.resolve(ctx, pt-func(c-name))

    // Calculate circumcenter
    let (pb1-p1, pb1-p2, mid-ab) = util.perpendicular-bisector(pa, pb)
    let (pb2-p1, pb2-p2, mid-ac) = util.perpendicular-bisector(pa, pc)

    let dx1 = pb1-p2.at(0) - pb1-p1.at(0)
    let dy1 = pb1-p2.at(1) - pb1-p1.at(1)
    let dx2 = pb2-p2.at(0) - pb2-p1.at(0)
    let dy2 = pb2-p2.at(1) - pb2-p1.at(1)

    let denom = dx1 * dy2 - dy1 * dx2
    if calc.abs(denom) < 1e-9 { return }

    let t = ((pb2-p1.at(0) - pb1-p1.at(0)) * dy2 - (pb2-p1.at(1) - pb1-p1.at(1)) * dx2) / denom
    let center = (pb1-p1.at(0) + t * dx1, pb1-p1.at(1) + t * dy1)
    let radius = util.dist(center, pa)

    cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw incircle of triangle
/// Usage: draw-incircle(cetz-draw, pt, "A", "B", "C", stroke: black)
#let draw-incircle(cetz-draw, pt-func, a-name, b-name, c-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, pa) = cetz.coordinate.resolve(ctx, pt-func(a-name))
    let (_, pb) = cetz.coordinate.resolve(ctx, pt-func(b-name))
    let (_, pc) = cetz.coordinate.resolve(ctx, pt-func(c-name))

    // Side lengths
    let la = util.dist(pb, pc)
    let lb = util.dist(pa, pc)
    let lc = util.dist(pa, pb)
    let total = la + lb + lc

    if total < 1e-9 { return }

    // Incenter
    let center = (
      (la * pa.at(0) + lb * pb.at(0) + lc * pc.at(0)) / total,
      (la * pa.at(1) + lb * pb.at(1) + lc * pc.at(1)) / total,
    )

    // Inradius = Area / s
    let abx = pb.at(0) - pa.at(0)
    let aby = pb.at(1) - pa.at(1)
    let acx = pc.at(0) - pa.at(0)
    let acy = pc.at(1) - pa.at(1)
    let area = calc.abs(abx * acy - aby * acx) / 2
    let s = total / 2
    let radius = area / s

    cetz-draw.circle(center, radius: radius, stroke: stroke, fill: fill)
  })
}

/// Draw a semicircle with diameter AB
/// Usage: draw-semicircle(cetz-draw, pt, "A", "B", stroke: black, above: true)
#let draw-semicircle(cetz-draw, pt-func, p1-name, p2-name, stroke: black, fill: none, above: true) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))
    let center = util.midpoint(c1, c2)
    let radius = util.dist(c1, c2) / 2

    // Calculate start angle from p1
    let angle = calc.atan2(c1.at(1) - center.at(1), c1.at(0) - center.at(0))
    let start-deg = if type(angle) == angle { angle } else { angle * 1deg }

    if above {
      cetz-draw.arc(center, start: start-deg, stop: start-deg + 180deg, radius: radius, stroke: stroke, fill: fill)
    } else {
      cetz-draw.arc(center, start: start-deg, stop: start-deg - 180deg, radius: radius, stroke: stroke, fill: fill)
    }
  })
}

/// Draw a circular sector
/// Usage: draw-sector(cetz-draw, pt, "O", "A", "B", stroke: black, fill: blue.lighten(80%))
#let draw-sector(cetz-draw, pt-func, center-name, start-name, end-name, stroke: black, fill: none) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, pt-func(center-name))
    let (_, s) = cetz.coordinate.resolve(ctx, pt-func(start-name))
    let (_, e) = cetz.coordinate.resolve(ctx, pt-func(end-name))

    let radius = util.dist(c, s)
    let start-angle = calc.atan2(s.at(1) - c.at(1), s.at(0) - c.at(0))
    let end-angle = calc.atan2(e.at(1) - c.at(1), e.at(0) - c.at(0))

    let start-deg = if type(start-angle) == angle { start-angle } else { start-angle * 1deg }
    let end-deg = if type(end-angle) == angle { end-angle } else { end-angle * 1deg }

    // Draw arc and lines to center to form sector
    cetz-draw.line(c, s, stroke: stroke)
    cetz-draw.arc(c, start: start-deg, stop: end-deg, radius: radius, stroke: stroke)
    cetz-draw.line(e, c, stroke: stroke)

    // Fill if requested - draw filled arc sector
    if fill != none {
      // Create a path for the filled sector
      let n-steps = 36
      let angle-diff = end-deg - start-deg
      let points = (c,)
      for i in range(n-steps + 1) {
        let angle = start-deg + angle-diff * i / n-steps
        points.push((c.at(0) + radius * calc.cos(angle), c.at(1) + radius * calc.sin(angle)))
      }
      cetz-draw.line(..points, close: true, fill: fill, stroke: none)
    }
  })
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

    cetz-draw.line(start, end, stroke: stroke)
  })
}

// =============================================================================
// MARKING COMMANDS
// =============================================================================

/// Mark a segment with tick marks (|, ||, |||)
/// Usage: mark-segment(cetz-draw, pt, "A", "B", mark: 1, size: 0.15, color: black)
#let mark-segment(cetz-draw, pt-func, p1-name, p2-name, mark: 1, size: 0.15, pos: 0.5, color: black, slant: 20deg, thickness: 1pt) = {
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
        let start-angle = calc.atan2(va-y, va-x)
        let end-angle = calc.atan2(vc-y, vc-x)
        let start-deg = if type(start-angle) == angle { start-angle } else { start-angle * 1deg }
        let end-deg = if type(end-angle) == angle { end-angle } else { end-angle * 1deg }
        cetz-draw.arc(pv, start: start-deg, stop: end-deg, radius: size, stroke: color + 1pt)
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
      let angle = calc.atan2(dy, dx)
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
    let x = xmin
    while x <= xmax {
      cetz-draw.line((x, ymin), (x, ymax), stroke: sub-stroke)
      x = x + sub-xstep
    }
    // Horizontal sub-lines
    let y = ymin
    while y <= ymax {
      cetz-draw.line((xmin, y), (xmax, y), stroke: sub-stroke)
      y = y + sub-ystep
    }
  }

  // Draw main grid lines
  // Vertical lines
  let x = xmin
  while x <= xmax {
    cetz-draw.line((x, ymin), (x, ymax), stroke: stroke)
    x = x + xstep
  }
  // Horizontal lines
  let y = ymin
  while y <= ymax {
    cetz-draw.line((xmin, y), (xmax, y), stroke: stroke)
    y = y + ystep
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

  // X axis
  cetz-draw.line((xmin, 0), (xmax, 0), stroke: stroke, mark: (end: arrow-mark))

  // Y axis
  cetz-draw.line((0, ymin), (0, ymax), stroke: stroke, mark: (end: arrow-mark))

  // X axis ticks
  if ticks {
    let x = xmin
    while x <= xmax {
      if calc.abs(x) > 0.001 {  // Skip origin
        cetz-draw.line((x, -tick-size), (x, tick-size), stroke: stroke)
      }
      x = x + xstep
    }

    // Y axis ticks
    let y = ymin
    while y <= ymax {
      if calc.abs(y) > 0.001 {  // Skip origin
        cetz-draw.line((-tick-size, y), (tick-size, y), stroke: stroke)
      }
      y = y + ystep
    }
  }

  // Labels
  if labels {
    // X axis tick labels
    let x = xmin
    while x <= xmax {
      if calc.abs(x) > 0.001 {  // Skip origin
        let label-text = if calc.rem(x, 1) == 0 { str(int(x)) } else { str(x) }
        cetz-draw.content((x, -0.3), text(size: 8pt)[#label-text])
      }
      x = x + xstep
    }

    // Y axis tick labels
    let y = ymin
    while y <= ymax {
      if calc.abs(y) > 0.001 {  // Skip origin
        let label-text = if calc.rem(y, 1) == 0 { str(int(y)) } else { str(y) }
        cetz-draw.content((-0.3, y), text(size: 8pt)[#label-text])
      }
      y = y + ystep
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
    let x = xmin
    while x <= xmax {
      if calc.abs(x) > 0.001 {
        cetz-draw.line((x, -tick-size), (x, tick-size), stroke: stroke)
      }
      x = x + xstep
    }
  }

  // Labels
  if labels {
    let x = xmin
    while x <= xmax {
      if calc.abs(x) > 0.001 {
        let label-text = if calc.rem(x, 1) == 0 { str(int(x)) } else { str(x) }
        cetz-draw.content((x, -0.3), text(size: 8pt)[#label-text])
      }
      x = x + xstep
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
    let y = ymin
    while y <= ymax {
      if calc.abs(y) > 0.001 {
        cetz-draw.line((-tick-size, y), (tick-size, y), stroke: stroke)
      }
      y = y + ystep
    }
  }

  // Labels
  if labels {
    let y = ymin
    while y <= ymax {
      if calc.abs(y) > 0.001 {
        let label-text = if calc.rem(y, 1) == 0 { str(int(y)) } else { str(y) }
        cetz-draw.content((-0.3, y), text(size: 8pt)[#label-text])
      }
      y = y + ystep
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

// =============================================================================
// CLIPPING (Line Clipping to Rectangle)
// =============================================================================

/// Global clip region state key
#let _clip-region-key = "ctz-clip-region"

/// Set global clip region
/// Usage: set-clip-region(cetz-draw, xmin, ymin, xmax, ymax)
#let set-clip-region(cetz-draw, xmin, ymin, xmax, ymax) = {
  cetz-draw.set-ctx(ctx => {
    ctx.shared-state.insert(_clip-region-key, (xmin: xmin, ymin: ymin, xmax: xmax, ymax: ymax))
    ctx
  })
}

/// Clear global clip region
#let clear-clip-region(cetz-draw) = {
  cetz-draw.set-ctx(ctx => {
    if _clip-region-key in ctx.shared-state {
      let _ = ctx.shared-state.remove(_clip-region-key)
    }
    ctx
  })
}

/// Get current clip region (returns none if not set)
#let get-clip-region(ctx) = {
  ctx.shared-state.at(_clip-region-key, default: none)
}

// Cohen-Sutherland outcodes
#let _INSIDE = 0
#let _LEFT = 1
#let _RIGHT = 2
#let _BOTTOM = 4
#let _TOP = 8

/// Compute the outcode for a point relative to a rectangle
#let _compute-outcode(x, y, xmin, ymin, xmax, ymax) = {
  let code = _INSIDE
  if x < xmin { code = code + _LEFT }
  else if x > xmax { code = code + _RIGHT }
  if y < ymin { code = code + _BOTTOM }
  else if y > ymax { code = code + _TOP }
  code
}

/// Cohen-Sutherland line clipping algorithm
/// Returns none if line is completely outside, or ((x0, y0), (x1, y1)) if clipped
#let clip-line-to-rect(x0, y0, x1, y1, xmin, ymin, xmax, ymax) = {
  let outcode0 = _compute-outcode(x0, y0, xmin, ymin, xmax, ymax)
  let outcode1 = _compute-outcode(x1, y1, xmin, ymin, xmax, ymax)

  let iterations = 0
  let max-iterations = 20

  while iterations < max-iterations {
    iterations = iterations + 1

    // Check if both points inside (all outcode bits are 0)
    let both-inside = (outcode0 == 0 and outcode1 == 0)
    if both-inside {
      return ((x0, y0), (x1, y1))
    }

    // Check if bitwise AND is non-zero (both outside same edge)
    let both-left = (calc.rem(outcode0, 2) == 1) and (calc.rem(outcode1, 2) == 1)
    let both-right = (calc.rem(calc.quo(outcode0, 2), 2) == 1) and (calc.rem(calc.quo(outcode1, 2), 2) == 1)
    let both-bottom = (calc.rem(calc.quo(outcode0, 4), 2) == 1) and (calc.rem(calc.quo(outcode1, 4), 2) == 1)
    let both-top = (calc.rem(calc.quo(outcode0, 8), 2) == 1) and (calc.rem(calc.quo(outcode1, 8), 2) == 1)

    if both-left or both-right or both-bottom or both-top {
      return none  // Line completely outside
    }

    // At least one point outside, pick it
    let outcode-out = if outcode0 != 0 { outcode0 } else { outcode1 }

    let x = 0
    let y = 0

    // Find intersection point
    if calc.rem(calc.quo(outcode-out, 8), 2) == 1 {
      // Point is above
      x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0)
      y = ymax
    } else if calc.rem(calc.quo(outcode-out, 4), 2) == 1 {
      // Point is below
      x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0)
      y = ymin
    } else if calc.rem(calc.quo(outcode-out, 2), 2) == 1 {
      // Point is to the right
      y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0)
      x = xmax
    } else if calc.rem(outcode-out, 2) == 1 {
      // Point is to the left
      y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0)
      x = xmin
    }

    // Replace outside point with intersection
    if outcode-out == outcode0 {
      x0 = x
      y0 = y
      outcode0 = _compute-outcode(x0, y0, xmin, ymin, xmax, ymax)
    } else {
      x1 = x
      y1 = y
      outcode1 = _compute-outcode(x1, y1, xmin, ymin, xmax, ymax)
    }
  }

  // If we get here, return what we have
  if outcode0 == 0 and outcode1 == 0 {
    return ((x0, y0), (x1, y1))
  }
  none
}

/// Draw a line clipped to a rectangle boundary
/// Usage: draw-clipped-line(cetz-draw, p1, p2, xmin, ymin, xmax, ymax, stroke: blue)
#let draw-clipped-line(cetz-draw, p1, p2, xmin, ymin, xmax, ymax, stroke: black) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, p1)
    let (_, c2) = cetz.coordinate.resolve(ctx, p2)

    let result = clip-line-to-rect(c1.at(0), c1.at(1), c2.at(0), c2.at(1), xmin, ymin, xmax, ymax)

    if result != none {
      let ((x0, y0), (x1, y1)) = result
      cetz-draw.line((x0, y0), (x1, y1), stroke: stroke)
    }
  })
}

/// Draw an extended line clipped to a rectangle boundary
/// This is the main function for drawing "infinite" lines that are clipped to the canvas
/// Usage: draw-clipped-line-add(cetz-draw, pt-func, p1-name, p2-name, bounds, add: (10, 10), stroke: black)
#let draw-clipped-line-add(cetz-draw, pt-func, p1-name, p2-name, xmin, ymin, xmax, ymax, add: (10, 10), stroke: black) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)
    let len = calc.sqrt(dx*dx + dy*dy)

    if len < 0.001 { return }

    // Normalize direction
    let ux = dx / len
    let uy = dy / len

    // Extend the line
    let add-left = if type(add) == array { add.at(0) } else { add }
    let add-right = if type(add) == array { add.at(1) } else { add }

    let x0 = c1.at(0) - ux * add-left * len
    let y0 = c1.at(1) - uy * add-left * len
    let x1 = c2.at(0) + ux * add-right * len
    let y1 = c2.at(1) + uy * add-right * len

    // Clip to rectangle
    let result = clip-line-to-rect(x0, y0, x1, y1, xmin, ymin, xmax, ymax)

    if result != none {
      let ((cx0, cy0), (cx1, cy1)) = result
      cetz-draw.line((cx0, cy0), (cx1, cy1), stroke: stroke)
    }
  })
}

/// Draw a rectangle boundary (for showing the clip region)
#let draw-clip-boundary(cetz-draw, xmin, ymin, xmax, ymax, stroke: black + 0.5pt) = {
  cetz-draw.rect((xmin, ymin), (xmax, ymax), stroke: stroke, fill: none)
}

/// Draw the global clip boundary (uses stored clip region)
#let draw-global-clip-boundary(cetz-draw, stroke: black + 0.5pt) = {
  cetz-draw.get-ctx(ctx => {
    let clip = get-clip-region(ctx)
    if clip != none {
      cetz-draw.rect((clip.xmin, clip.ymin), (clip.xmax, clip.ymax), stroke: stroke, fill: none)
    }
  })
}

/// Draw an extended line using the global clip region
/// This is the main function for drawing "infinite" lines that are automatically clipped
/// Usage: draw-line-global-clip(cetz-draw, pt-func, p1-name, p2-name, add: (10, 10), stroke: black)
#let draw-line-global-clip(cetz-draw, pt-func, p1-name, p2-name, add: (10, 10), stroke: black) = {
  cetz-draw.get-ctx(ctx => {
    let clip = get-clip-region(ctx)
    if clip == none {
      // No clip region set, draw unclipped extended line
      let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
      let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

      let dx = c2.at(0) - c1.at(0)
      let dy = c2.at(1) - c1.at(1)

      let (add-before, add-after) = if type(add) == array { add } else { (add, add) }

      let start = (c1.at(0) - add-before * dx, c1.at(1) - add-before * dy)
      let end = (c2.at(0) + add-after * dx, c2.at(1) + add-after * dy)

      cetz-draw.line(start, end, stroke: stroke)
    } else {
      // Use the global clip region
      let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
      let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

      let dx = c2.at(0) - c1.at(0)
      let dy = c2.at(1) - c1.at(1)
      let len = calc.sqrt(dx*dx + dy*dy)

      if len < 0.001 { return }

      let ux = dx / len
      let uy = dy / len

      let add-left = if type(add) == array { add.at(0) } else { add }
      let add-right = if type(add) == array { add.at(1) } else { add }

      let x0 = c1.at(0) - ux * add-left * len
      let y0 = c1.at(1) - uy * add-left * len
      let x1 = c2.at(0) + ux * add-right * len
      let y1 = c2.at(1) + uy * add-right * len

      let result = clip-line-to-rect(x0, y0, x1, y1, clip.xmin, clip.ymin, clip.xmax, clip.ymax)

      if result != none {
        let ((cx0, cy0), (cx1, cy1)) = result
        cetz-draw.line((cx0, cy0), (cx1, cy1), stroke: stroke)
      }
    }
  })
}

/// Draw a simple segment using global clip region if set
#let draw-segment-global-clip(cetz-draw, pt-func, p1-name, p2-name, stroke: black) = {
  cetz-draw.get-ctx(ctx => {
    let clip = get-clip-region(ctx)
    let (_, c1) = cetz.coordinate.resolve(ctx, pt-func(p1-name))
    let (_, c2) = cetz.coordinate.resolve(ctx, pt-func(p2-name))

    if clip == none {
      cetz-draw.line(c1, c2, stroke: stroke)
    } else {
      let result = clip-line-to-rect(c1.at(0), c1.at(1), c2.at(0), c2.at(1), clip.xmin, clip.ymin, clip.xmax, clip.ymax)
      if result != none {
        let ((x0, y0), (x1, y1)) = result
        cetz-draw.line((x0, y0), (x1, y1), stroke: stroke)
      }
    }
  })
}
