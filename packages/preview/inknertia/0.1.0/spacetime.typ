#import "@preview/cetz:0.4.2"

// ============================================================
// Spacetime Diagrams Module for Special Relativity
// ============================================================
// This module provides functions to draw Minkowski spacetime
// diagrams, including events, worldlines, light cones, and
// reference frames.
//
// Conventions:
// - Natural units: c = 1 (light travels at 45°)
// - Vertical axis: ct (time × speed of light)
// - Horizontal axis: x (space)
// - Velocity parameter beta = v/c (dimensionless, -1 < β < 1)
// ============================================================

// Vector math helpers
#let vec-sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec-add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec-scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec-norm(v) = calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))

// ============================================================
// Lorentz Transformation Helpers
// ============================================================

/// Compute the Lorentz factor gamma for a given beta
#let gamma(beta) = {
  if calc.abs(beta) >= 1 {
    panic("beta must be in the range (-1, 1)")
  }
  1 / calc.sqrt(1 - calc.pow(beta, 2))
}

/// Transform coordinates (x, ct) to a frame moving with velocity beta
/// Returns (x', ct') in the primed frame
#let lorentz-transform(pos, beta) = {
  let x = pos.at(0)
  let ct = pos.at(1)
  let g = gamma(beta)
  let x-prime = g * (x - beta * ct)
  let ct-prime = g * (ct - beta * x)
  (x-prime, ct-prime)
}

/// Inverse Lorentz transform: from primed frame back to rest frame
#let lorentz-inverse(pos, beta) = {
  lorentz-transform(pos, -beta)
}

// ============================================================
// Event
// ============================================================

/// Create an event marker at a point in spacetime
/// - id: Unique identifier for the event
/// - pos: Position (x, ct) in spacetime
/// - label: Optional label content
/// - shape: "dot", "circle", "square", or "none"
/// - color: Color of the marker
/// - size: Size of the marker
#let event(
  id,
  pos,
  label: none,
  shape: "dot",
  color: black,
  size: 0.1,
  label-anchor: "auto",
  label-padding: 0.2,
  anchor: auto,
  padding: auto,
  label-color: auto,
) = {
  (
    type: "event",
    id: id,
    pos: pos,
    label: label,
    shape: shape,
    color: color,
    size: size,
    label-anchor: if anchor != auto { anchor } else { label-anchor },
    label-padding: if padding != auto { padding } else { label-padding },
    label-color: label-color,
  )
}

// ============================================================
// Worldline
// ============================================================

/// Create a worldline connecting events or points
/// - points: Array of (x, ct) coordinates or event IDs
/// - style: "solid", "dashed", or "dotted"
/// - type: "massive" (straight), "light" (45°), "accelerated" (curved)
/// - color: Line color
/// - label: Optional label
/// - stroke_width: Line thickness
#let worldline(
  ..points,
  style: "solid",
  wl-type: "massive",
  color: black,
  label: none,
  stroke-width: 1.5pt,
  label-pos: 0.5,
  label-anchor: "auto",
) = {
  (
    type: "worldline",
    points: points.pos(),
    style: style,
    wl-type: wl-type,
    color: color,
    label: label,
    stroke-width: stroke-width,
    label-pos: label-pos,
    label-anchor: label-anchor,
  )
}

// ============================================================
// Light Cone
// ============================================================

/// Draw a light cone centered on an event
/// - origin: (x, ct) position or event ID
/// - extent: How far the cone extends
/// - show_past: Draw past light cone
/// - show_future: Draw future light cone
/// - fill_future: Fill color for future cone interior
/// - fill_past: Fill color for past cone interior
/// - stroke_color: Color of the cone edges
#let lightcone(
  origin,
  extent: auto,
  show-past: true,
  show-future: true,
  fill-future: none,
  fill-past: none,
  stroke-color: rgb("#E4D0B3"),
  stroke-width: 1pt,
) = {
  (
    type: "lightcone",
    origin: origin,
    extent: extent,
    show-past: show-past,
    show-future: show-future,
    fill-future: fill-future,
    fill-past: fill-past,
    stroke-color: stroke-color,
    stroke-width: stroke-width,
  )
}

// ============================================================
// Reference Frame (Primed Axes)
// ============================================================

/// Draw axes for a reference frame moving at velocity beta
/// - beta: Velocity as fraction of c (v/c), range (-1, 1)
/// - origin: Origin of the primed frame in rest frame coordinates
/// - extent: How far the axes extend
/// - color: Color of the primed axes
/// - xlabel: Label for x' axis
/// - ctlabel: Label for ct' axis
#let frame(
  beta: 0,
  origin: (0, 0),
  extent: auto,
  color: blue,
  xlabel: auto,
  ctlabel: auto,
  stroke-width: 1pt,
  grid-stroke: none,
  grid-spacing: 1,
) = {
  (
    type: "frame",
    beta: beta,
    origin: origin,
    extent: extent,
    color: color,
    xlabel: xlabel,
    ctlabel: ctlabel,
    stroke-width: stroke-width,
    grid-stroke: grid-stroke,
    grid-spacing: grid-spacing,
  )
}

// ============================================================
// Simultaneity Line
// ============================================================

/// Draw a line of constant time (simultaneity)
/// - ct: The ct-coordinate (in rest frame, or ct' in primed frame)
/// - beta: If provided, draw tilted simultaneity for moving frame
/// - extent: How far the line extends
/// - color: Line color
/// - style: "solid", "dashed", "dotted"
#let simultaneity(
  ct,
  beta: 0,
  extent: auto,
  color: gray,
  style: "dashed",
  stroke-width: 0.5pt,
  label: none,
) = {
  (
    type: "simultaneity",
    ct: ct,
    beta: beta,
    extent: extent,
    color: color,
    style: style,
    stroke-width: stroke-width,
    label: label,
  )
}

// ============================================================
// Hyperbola (Calibration Curves)
// ============================================================

/// Draw a calibration hyperbola for proper time/length
/// - s_squared: The invariant interval s² (positive for timelike, negative for spacelike)
/// - branch: "future", "past", "right", "left", or "all"
/// - color: Curve color
#let hyperbola(
  s-squared,
  origin: (0, 0),
  branch: "all",
  color: gray,
  stroke-width: 0.5pt,
  style: "dotted",
  samples: 100,
) = {
  (
    type: "hyperbola",
    s-squared: s-squared,
    origin: origin,
    branch: branch,
    color: color,
    stroke-width: stroke-width,
    style: style,
    samples: samples,
  )
}

// ============================================================
// Main Spacetime Diagram Function
// ============================================================

/// Draw a spacetime diagram
/// - items: Array of events, worldlines, light cones, etc.
/// - xrange: (xmin, xmax) for the x-axis
/// - ctrange: (ctmin, ctmax) for the ct-axis
/// - length: Scale factor (physical length per unit)
/// - show_axes: Whether to draw the rest frame axes
/// - xlabel: Label for x-axis
/// - ctlabel: Label for ct-axis
/// - axes_color: Color of the main axes
#let spacetime(
  items,
  xrange: (-5, 5),
  ctrange: (-5, 5),
  length: 0.5cm,
  show-axes: true,
  xlabel: $x$,
  ctlabel: auto,
  natural-units: true,
  axes-color: black,
  axes-stroke: 1pt,
  grid: none,
  grid-step: 1,
) = {
  cetz.canvas(length: length, {
    import cetz.draw: circle, content, line, rect

    let xmin = xrange.at(0)
    let xmax = xrange.at(1)
    let ctmin = ctrange.at(0)
    let ctmax = ctrange.at(1)

    // Resolve time label
    let final-ctlabel = if ctlabel != auto {
      ctlabel
    } else if natural-units {
      $t$
    } else {
      $c t$
    }


    // Helper to clip a line ax + by + c = 0 to the viewport
    let get-clipped-segment = (a, b, c-val) => {
      let pts = ()
      // Left: x = xmin => y = -(c + a*xmin)/b
      if calc.abs(b) > 1e-6 {
        let y = -(c-val + a * xmin) / b
        if y >= ctmin - 1e-6 and y <= ctmax + 1e-6 { pts.push((xmin, y)) }
      }
      // Right: x = xmax => y = -(c + a*xmax)/b
      if calc.abs(b) > 1e-6 {
        let y = -(c-val + a * xmax) / b
        if y >= ctmin - 1e-6 and y <= ctmax + 1e-6 { pts.push((xmax, y)) }
      }
      // Bottom: y = ctmin => x = -(c + b*ctmin)/a
      if calc.abs(a) > 1e-6 {
        let x = -(c-val + b * ctmin) / a
        if x >= xmin - 1e-6 and x <= xmax + 1e-6 { pts.push((x, ctmin)) }
      }
      // Top: y = ctmax => x = -(c-val + b*ctmax)/a
      if calc.abs(a) > 1e-6 {
        let x = -(c-val + b * ctmax) / a
        if x >= xmin - 1e-6 and x <= xmax + 1e-6 { pts.push((x, ctmax)) }
      }

      // Deduplicate
      let unique = ()
      for p in pts {
        let exists = false
        for u in unique {
          if calc.abs(p.at(0) - u.at(0)) < 1e-4 and calc.abs(p.at(1) - u.at(1)) < 1e-4 { exists = true }
        }
        if not exists { unique.push(p) }
      }

      if unique.len() >= 2 {
        (unique.at(0), unique.at(1))
      } else {
        none
      }
    }

    // Build event lookup table
    let events = (:)
    for item in items {
      if item == none { continue }
      if item.type == "event" {
        events.insert(item.id, item.pos)
      }
    }

    // Helper to resolve position (either direct coords or event ID)
    let resolve-pos(p) = {
      if type(p) == str {
        events.at(p, default: (0, 0))
      } else {
        p
      }
    }

    // Draw grid if requested
    if grid != none {
      let x = xmin + grid-step
      while x < xmax {
        line((x, ctmin), (x, ctmax), stroke: grid)
        x = x + grid-step
      }
      let ct = ctmin + grid-step
      while ct < ctmax {
        line((xmin, ct), (xmax, ct), stroke: grid)
        ct = ct + grid-step
      }
    }

    // Draw light cones (first, so they're behind everything)
    for item in items {
      if item.type == "lightcone" {
        let origin = resolve-pos(item.origin)
        let ox = origin.at(0)
        let oct = origin.at(1)
        let ext = if item.extent == auto {
          calc.max(calc.abs(ctmax - oct), calc.abs(oct - ctmin))
        } else {
          item.extent
        }

        // Future light cone
        if item.show-future {
          if item.fill-future != none {
            // Fill the future cone region
            let top-ct = calc.min(oct + ext, ctmax)
            let dx = top-ct - oct
            line(
              origin,
              (ox - dx, top-ct),
              (ox + dx, top-ct),
              close: true,
              fill: item.fill-future,
              stroke: none,
            )
          }
          // Right edge (x = ox + (ct - oct))
          let ct-end = calc.min(oct + ext, ctmax)
          line(origin, (ox + (ct-end - oct), ct-end), stroke: (paint: item.stroke-color, thickness: item.stroke-width))
          // Left edge (x = ox - (ct - oct))
          line(origin, (ox - (ct-end - oct), ct-end), stroke: (paint: item.stroke-color, thickness: item.stroke-width))
        }

        // Past light cone
        if item.show-past {
          if item.fill-past != none {
            let bot-ct = calc.max(oct - ext, ctmin)
            let dx = oct - bot-ct
            line(
              origin,
              (ox - dx, bot-ct),
              (ox + dx, bot-ct),
              close: true,
              fill: item.fill-past,
              stroke: none,
            )
          }
          let ct-end = calc.max(oct - ext, ctmin)
          line(origin, (ox + (oct - ct-end), ct-end), stroke: (paint: item.stroke-color, thickness: item.stroke-width))
          line(origin, (ox - (oct - ct-end), ct-end), stroke: (paint: item.stroke-color, thickness: item.stroke-width))
        }
      }
    }

    // Draw hyperbolas
    for item in items {
      if item.type == "hyperbola" {
        let s2 = item.s-squared
        let orig = item.origin
        let ox = orig.at(0)
        let oct = orig.at(1)

        let stroke-style = (
          paint: item.color,
          thickness: item.stroke-width,
          dash: if item.style == "dashed" { "dashed" } else if item.style == "dotted" { "dotted" } else { none },
        )

        if s2 > 0 {
          // Timelike: ct² - x² = s², so ct = ±sqrt(s² + x²)
          // Future branch
          if item.branch in ("future", "all") {
            let pts = ()
            for i in range(item.samples + 1) {
              let x = xmin + (xmax - xmin) * i / item.samples
              let val = s2 + calc.pow(x - ox, 2)
              if val >= 0 {
                let ct = oct + calc.sqrt(val)
                if ct >= ctmin and ct <= ctmax {
                  pts.push((x, ct))
                }
              }
            }
            if pts.len() > 1 { line(..pts, stroke: stroke-style) }
          }
          // Past branch
          if item.branch in ("past", "all") {
            let pts = ()
            for i in range(item.samples + 1) {
              let x = xmin + (xmax - xmin) * i / item.samples
              let val = s2 + calc.pow(x - ox, 2)
              if val >= 0 {
                let ct = oct - calc.sqrt(val)
                if ct >= ctmin and ct <= ctmax {
                  pts.push((x, ct))
                }
              }
            }
            if pts.len() > 1 { line(..pts, stroke: stroke-style) }
          }
        } else if s2 < 0 {
          // Spacelike: x² - ct² = |s²|, so x = ±sqrt(|s²| + ct²)
          let abs_s2 = -s2
          // Right branch
          if item.branch in ("right", "all") {
            let pts = ()
            for i in range(item.samples + 1) {
              let ct = ctmin + (ctmax - ctmin) * i / item.samples
              let val = abs_s2 + calc.pow(ct - oct, 2)
              if val >= 0 {
                let x = ox + calc.sqrt(val)
                if x >= xmin and x <= xmax {
                  pts.push((x, ct))
                }
              }
            }
            if pts.len() > 1 { line(..pts, stroke: stroke-style) }
          }
          // Left branch
          if item.branch in ("left", "all") {
            let pts = ()
            for i in range(item.samples + 1) {
              let ct = ctmin + (ctmax - ctmin) * i / item.samples
              let val = abs_s2 + calc.pow(ct - oct, 2)
              if val >= 0 {
                let x = ox - calc.sqrt(val)
                if x >= xmin and x <= xmax {
                  pts.push((x, ct))
                }
              }
            }
            if pts.len() > 1 { line(..pts, stroke: stroke-style) }
          }
        }
      }
    }

    // Draw simultaneity lines
    for item in items {
      if item.type == "simultaneity" {
        let ct-val = item.ct
        let beta = item.beta
        // Determine x-range based on extent
        let (x-start, x-end) = if item.extent == auto {
          (xmin, xmax)
        } else {
          if type(item.extent) == array {
            (item.extent.at(0), item.extent.at(1))
          } else {
            (-item.extent, item.extent)
          }
        }

        let stroke-style = (
          paint: item.color,
          thickness: item.stroke-width,
          dash: if item.style == "dashed" { "dashed" } else if item.style == "dotted" { "dotted" } else { none },
        )

        if beta == 0 {
          // Horizontal line at ct = ct-val
          // Clip to viewport x-range
          let x0 = calc.max(xmin, x-start)
          let x1 = calc.min(xmax, x-end)

          if x0 < x1 {
            line((x0, ct-val), (x1, ct-val), stroke: stroke-style)
          }
        } else {
          // Tilted line: ct = beta*x + ct-val/gamma
          let g = gamma(beta)
          let ct-intercept = ct-val / g

          let p-start = (x-start, ct-intercept + beta * x-start)
          let p-end = (x-end, ct-intercept + beta * x-end)

          // We need to clip this segment to the viewport
          // Line eq: -beta*x + 1*y - ct-intercept = 0 => a=-beta, b=1, c=-ct-intercept
          // But we also have segment limits p-start, p-end (defined by extent)

          // First, get the line clipped to the box
          let seg = get-clipped-segment(-beta, 1.0, -ct-intercept)

          if seg != none {
            // Intersect viewport segment with extent segment
            // Since it's a line, we can just sort points by x
            // Extent points:
            let ex-x-min = calc.min(p-start.at(0), p-end.at(0))
            let ex-x-max = calc.max(p-start.at(0), p-end.at(0))

            // Viewport points:
            let vp-x-min = calc.min(seg.at(0).at(0), seg.at(1).at(0))
            let vp-x-max = calc.max(seg.at(0).at(0), seg.at(1).at(0))

            // Intersection
            let final-x-min = calc.max(ex-x-min, vp-x-min)
            let final-x-max = calc.min(ex-x-max, vp-x-max)

            if final-x-min < final-x-max {
              // Recompute y for these x's to be precise
              let y1 = ct-intercept + beta * final-x-min
              let y2 = ct-intercept + beta * final-x-max
              line((final-x-min, y1), (final-x-max, y2), stroke: stroke-style)
            }
          }
        }

        if item.label != none {
          content((xmax, ct-val), item.label, anchor: "west", padding: 0.2)
        }
      }
    }

    // Helper to clip a line ax + by + c = 0 to the viewport


    // Draw reference frames (primed axes)
    for item in items {
      if item.type == "frame" {
        let beta = item.beta
        let orig = item.origin
        let ox = orig.at(0)
        let oct = orig.at(1)

        // --- DRAW GRID FIRST (so it is behind axes) ---
        if item.grid-stroke != none {
          let g = gamma(beta)
          let step = item.grid-spacing
          let g-stroke = item.grid-stroke

          // Compute global bounds in primed coordinates to determine range
          let corners = ((xmin, ctmin), (xmax, ctmin), (xmax, ctmax), (xmin, ctmax))
          let corners-prime = corners.map(p => lorentz-transform(p, beta))
          let xs-prime = corners-prime.map(p => p.at(0))
          let cts-prime = corners-prime.map(p => p.at(1))

          let xp-min = calc.min(..xs-prime)
          let xp-max = calc.max(..xs-prime)
          let ctp-min = calc.min(..cts-prime)
          let ctp-max = calc.max(..cts-prime)

          // Floor/Ceil to nearest step
          let i-start = calc.floor(xp-min / step) * step
          let i-end = calc.ceil(xp-max / step) * step

          let i = i-start
          while i <= i-end + 1e-6 {
            // Line x' = i => x - beta*ct - i/gamma = 0
            // a=1, b=-beta, c=-i/gamma
            if calc.abs(i) > 1e-4 {
              // Skip main axis
              let seg = get-clipped-segment(1.0, -beta, -i / g)
              if seg != none {
                line(seg.at(0), seg.at(1), stroke: g-stroke)
              }
            }
            i += step
          }

          let j-start = calc.floor(ctp-min / step) * step
          let j-end = calc.ceil(ctp-max / step) * step

          let j = j-start
          while j <= j-end + 1e-6 {
            // Line ct' = j => ct - beta*x - j/gamma = 0
            // a=-beta, b=1, c=-j/gamma
            if calc.abs(j) > 1e-4 {
              // Skip main axis
              let seg = get-clipped-segment(-beta, 1.0, -j / g)
              if seg != none {
                line(seg.at(0), seg.at(1), stroke: g-stroke)
              }
            }
            j += step
          }
        }

        // --- DRAW PRIMED AXES ---
        let stroke-style = (paint: item.color, thickness: item.stroke-width)

        // Equation for ct' axis: x' = 0 => x - beta*ct - (ox - beta*oct) = 0
        let ct-axis-c = -(ox - beta * oct)

        // Equation for x' axis: ct' = 0 => -beta*x + ct - (oct - beta*ox) = 0
        let x-axis-c = -(oct - beta * ox)

        // Check extent
        let ct-end-pt = none
        let x-end-pt = none

        if item.extent == auto {
          // Clip to viewport
          let ct-seg = get-clipped-segment(1.0, -beta, ct-axis-c)
          let x-seg = get-clipped-segment(-beta, 1.0, x-axis-c)

          if ct-seg != none {
            // Direction of ct' axis is (beta, 1)
            // Draw from p1 to p2. Check direction.
            let p1 = ct-seg.at(0)
            let p2 = ct-seg.at(1)
            let v = vec-sub(p2, p1)
            // Dot with (beta, 1)
            let dot = v.at(0) * beta + v.at(1) * 1.0
            if dot < 0 {
              line(p2, p1, stroke: stroke-style, mark: (end: "stealth", fill: item.color))
              ct-end-pt = p1
            } else {
              line(p1, p2, stroke: stroke-style, mark: (end: "stealth", fill: item.color))
              ct-end-pt = p2
            }
          }
          if x-seg != none {
            // Direction of x' axis is (1, beta)
            let p1 = x-seg.at(0)
            let p2 = x-seg.at(1)
            let v = vec-sub(p2, p1)
            // Dot with (1, beta)
            let dot = v.at(0) * 1.0 + v.at(1) * beta
            if dot < 0 {
              line(p2, p1, stroke: stroke-style, mark: (end: "stealth", fill: item.color))
              x-end-pt = p1
            } else {
              line(p1, p2, stroke: stroke-style, mark: (end: "stealth", fill: item.color))
              x-end-pt = p2
            }
          }
        } else {
          // Manual extent
          let (min-ext, max-ext) = if type(item.extent) == array {
            (item.extent.at(0), item.extent.at(1))
          } else {
            (-item.extent, item.extent)
          }

          // ct' axis direction vector (normalized geometric vector)
          let norm-ct = calc.sqrt(1 + calc.pow(beta, 2))
          // Unit vector for ct' direction (beta, 1) normalized
          let u-ct = (beta / norm-ct, 1.0 / norm-ct)

          let p-start = (ox + u-ct.at(0) * min-ext, oct + u-ct.at(1) * min-ext)
          let p-end = (ox + u-ct.at(0) * max-ext, oct + u-ct.at(1) * max-ext)

          // Draw ct' axis
          line(p-start, p-end, stroke: stroke-style, mark: (end: "stealth", fill: item.color))
          ct-end-pt = p-end

          // x' axis direction (1, beta) normalized
          let norm-x = calc.sqrt(1 + calc.pow(beta, 2))
          let u-x = (1.0 / norm-x, beta / norm-x)

          let p-start-x = (ox + u-x.at(0) * min-ext, oct + u-x.at(1) * min-ext)
          let p-end-x = (ox + u-x.at(0) * max-ext, oct + u-x.at(1) * max-ext)

          // Draw x' axis
          line(p-start-x, p-end-x, stroke: stroke-style, mark: (end: "stealth", fill: item.color))
          x-end-pt = p-end-x
        }

        // Labels
        let def-ct-prime = if natural-units { $t'$ } else { $c t'$ }
        let ct-label = if item.ctlabel == auto { def-ct-prime } else { item.ctlabel }
        let x-label = if item.xlabel == auto { $x'$ } else { item.xlabel }

        if ct-end-pt != none {
          content(ct-end-pt, text(fill: item.color, ct-label), anchor: "south-west", padding: 0.15)
        }
        if x-end-pt != none {
          content(x-end-pt, text(fill: item.color, x-label), anchor: "south-west", padding: 0.15)
        }
      }
    }

    // Draw worldlines
    for item in items {
      if item.type == "worldline" {
        let pts = item.points.map(p => resolve-pos(p))

        let dash = if item.style == "dashed" { "dashed" } else if item.style == "dotted" { "dotted" } else { none }
        let stroke-style = (paint: item.color, thickness: item.stroke-width, dash: dash)

        if pts.len() >= 2 {
          if item.wl-type == "light" {
            // Draw at 45° regardless of actual endpoints
            // This is for indicating a light ray direction
            line(..pts, stroke: (paint: item.color, thickness: item.stroke-width, dash: "loosely-dashed"))
          } else {
            line(..pts, stroke: stroke-style)
          }

          // Draw label at midpoint
          if item.label != none {
            let idx = int(item.label-pos * (pts.len() - 1))
            let p = pts.at(idx)
            let anchor = if item.label-anchor == "auto" { "east" } else { item.label-anchor }
            content(p, text(fill: item.color, item.label), anchor: anchor, padding: 0.2)
          }
        }
      }
    }

    // Draw main axes (if enabled)
    if show-axes {
      let stroke-style = (paint: axes-color, thickness: axes-stroke)

      // x-axis
      line((xmin, 0), (xmax, 0), stroke: stroke-style, mark: (end: "stealth", fill: axes-color))
      content((xmax, 0), xlabel, anchor: "north-west", padding: 0.15)

      // ct-axis
      line((0, ctmin), (0, ctmax), stroke: stroke-style, mark: (end: "stealth", fill: axes-color))
      content((0, ctmax), final-ctlabel, anchor: "south-east", padding: 0.15)
    }

    // Draw events (on top of everything)
    for item in items {
      if item.type == "event" {
        let pos = item.pos

        if item.shape == "dot" {
          circle(pos, radius: item.size, fill: item.color, stroke: none)
        } else if item.shape == "circle" {
          circle(pos, radius: item.size, fill: none, stroke: (paint: item.color, thickness: 1pt))
        } else if item.shape == "square" {
          let s = item.size
          rect((pos.at(0) - s, pos.at(1) - s), (pos.at(0) + s, pos.at(1) + s), fill: item.color, stroke: none)
        }

        // Draw label
        if item.label != none {
          let anchor = if item.label-anchor == "auto" { "south-west" } else { item.label-anchor }
          let fill-color = if item.label-color != auto { item.label-color } else { item.color }
          content(pos, text(fill: fill-color, item.label), anchor: anchor, padding: item.label-padding)
        }
      }
    }
  })
}
