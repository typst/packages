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
#let vec_sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec_add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec_scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec_norm(v) = calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))

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
#let lorentz_transform(pos, beta) = {
  let x = pos.at(0)
  let ct = pos.at(1)
  let g = gamma(beta)
  let x_prime = g * (x - beta * ct)
  let ct_prime = g * (ct - beta * x)
  (x_prime, ct_prime)
}

/// Inverse Lorentz transform: from primed frame back to rest frame
#let lorentz_inverse(pos, beta) = {
  lorentz_transform(pos, -beta)
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
  label_anchor: "auto",
  label_padding: 0.2,
  anchor: auto,
  padding: auto,
  label_color: auto,
) = {
  (
    type: "event",
    id: id,
    pos: pos,
    label: label,
    shape: shape,
    color: color,
    size: size,
    label_anchor: if anchor != auto { anchor } else { label_anchor },
    label_padding: if padding != auto { padding } else { label_padding },
    label_color: label_color,
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
  wl_type: "massive",
  color: black,
  label: none,
  stroke_width: 1.5pt,
  label_pos: 0.5,
  label_anchor: "auto",
) = {
  (
    type: "worldline",
    points: points.pos(),
    style: style,
    wl_type: wl_type,
    color: color,
    label: label,
    stroke_width: stroke_width,
    label_pos: label_pos,
    label_anchor: label_anchor,
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
  show_past: true,
  show_future: true,
  fill_future: none,
  fill_past: none,
  stroke_color: rgb("#E4D0B3"),
  stroke_width: 1pt,
) = {
  (
    type: "lightcone",
    origin: origin,
    extent: extent,
    show_past: show_past,
    show_future: show_future,
    fill_future: fill_future,
    fill_past: fill_past,
    stroke_color: stroke_color,
    stroke_width: stroke_width,
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
  stroke_width: 1pt,
  grid_stroke: none,
  grid_spacing: 1,
) = {
  (
    type: "frame",
    beta: beta,
    origin: origin,
    extent: extent,
    color: color,
    xlabel: xlabel,
    ctlabel: ctlabel,
    stroke_width: stroke_width,
    grid_stroke: grid_stroke,
    grid_spacing: grid_spacing,
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
  stroke_width: 0.5pt,
  label: none,
) = {
  (
    type: "simultaneity",
    ct: ct,
    beta: beta,
    extent: extent,
    color: color,
    style: style,
    stroke_width: stroke_width,
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
  s_squared,
  origin: (0, 0),
  branch: "all",
  color: gray,
  stroke_width: 0.5pt,
  style: "dotted",
  samples: 100,
) = {
  (
    type: "hyperbola",
    s_squared: s_squared,
    origin: origin,
    branch: branch,
    color: color,
    stroke_width: stroke_width,
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
  show_axes: true,
  xlabel: $x$,
  ctlabel: auto,
  natural_units: true,
  axes_color: black,
  axes_stroke: 1pt,
  grid: none,
  grid_step: 1,
) = {
  cetz.canvas(length: length, {
    import cetz.draw: circle, content, line, rect

    let xmin = xrange.at(0)
    let xmax = xrange.at(1)
    let ctmin = ctrange.at(0)
    let ctmax = ctrange.at(1)

    // Resolve time label
    let final_ctlabel = if ctlabel != auto {
      ctlabel
    } else if natural_units {
      $t$
    } else {
      $c t$
    }


    // Helper to clip a line ax + by + c = 0 to the viewport
    let get_clipped_segment = (a, b, c_val) => {
      let pts = ()
      // Left: x = xmin => y = -(c + a*xmin)/b
      if calc.abs(b) > 1e-6 {
        let y = -(c_val + a * xmin) / b
        if y >= ctmin - 1e-6 and y <= ctmax + 1e-6 { pts.push((xmin, y)) }
      }
      // Right: x = xmax => y = -(c + a*xmax)/b
      if calc.abs(b) > 1e-6 {
        let y = -(c_val + a * xmax) / b
        if y >= ctmin - 1e-6 and y <= ctmax + 1e-6 { pts.push((xmax, y)) }
      }
      // Bottom: y = ctmin => x = -(c + b*ctmin)/a
      if calc.abs(a) > 1e-6 {
        let x = -(c_val + b * ctmin) / a
        if x >= xmin - 1e-6 and x <= xmax + 1e-6 { pts.push((x, ctmin)) }
      }
      // Top: y = ctmax => x = -(c_val + b*ctmax)/a
      if calc.abs(a) > 1e-6 {
        let x = -(c_val + b * ctmax) / a
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
    let resolve_pos(p) = {
      if type(p) == str {
        events.at(p, default: (0, 0))
      } else {
        p
      }
    }

    // Draw grid if requested
    if grid != none {
      let x = xmin + grid_step
      while x < xmax {
        line((x, ctmin), (x, ctmax), stroke: grid)
        x = x + grid_step
      }
      let ct = ctmin + grid_step
      while ct < ctmax {
        line((xmin, ct), (xmax, ct), stroke: grid)
        ct = ct + grid_step
      }
    }

    // Draw light cones (first, so they're behind everything)
    for item in items {
      if item.type == "lightcone" {
        let origin = resolve_pos(item.origin)
        let ox = origin.at(0)
        let oct = origin.at(1)
        let ext = if item.extent == auto {
          calc.max(calc.abs(ctmax - oct), calc.abs(oct - ctmin))
        } else {
          item.extent
        }

        // Future light cone
        if item.show_future {
          if item.fill_future != none {
            // Fill the future cone region
            let top_ct = calc.min(oct + ext, ctmax)
            let dx = top_ct - oct
            line(
              origin,
              (ox - dx, top_ct),
              (ox + dx, top_ct),
              close: true,
              fill: item.fill_future,
              stroke: none,
            )
          }
          // Right edge (x = ox + (ct - oct))
          let ct_end = calc.min(oct + ext, ctmax)
          line(origin, (ox + (ct_end - oct), ct_end), stroke: (paint: item.stroke_color, thickness: item.stroke_width))
          // Left edge (x = ox - (ct - oct))
          line(origin, (ox - (ct_end - oct), ct_end), stroke: (paint: item.stroke_color, thickness: item.stroke_width))
        }

        // Past light cone
        if item.show_past {
          if item.fill_past != none {
            let bot_ct = calc.max(oct - ext, ctmin)
            let dx = oct - bot_ct
            line(
              origin,
              (ox - dx, bot_ct),
              (ox + dx, bot_ct),
              close: true,
              fill: item.fill_past,
              stroke: none,
            )
          }
          let ct_end = calc.max(oct - ext, ctmin)
          line(origin, (ox + (oct - ct_end), ct_end), stroke: (paint: item.stroke_color, thickness: item.stroke_width))
          line(origin, (ox - (oct - ct_end), ct_end), stroke: (paint: item.stroke_color, thickness: item.stroke_width))
        }
      }
    }

    // Draw hyperbolas
    for item in items {
      if item.type == "hyperbola" {
        let s2 = item.s_squared
        let orig = item.origin
        let ox = orig.at(0)
        let oct = orig.at(1)

        let stroke_style = (
          paint: item.color,
          thickness: item.stroke_width,
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
            if pts.len() > 1 { line(..pts, stroke: stroke_style) }
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
            if pts.len() > 1 { line(..pts, stroke: stroke_style) }
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
            if pts.len() > 1 { line(..pts, stroke: stroke_style) }
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
            if pts.len() > 1 { line(..pts, stroke: stroke_style) }
          }
        }
      }
    }

    // Draw simultaneity lines
    for item in items {
      if item.type == "simultaneity" {
        let ct_val = item.ct
        let beta = item.beta
        // Determine x-range based on extent
        let (x_start, x_end) = if item.extent == auto {
          (xmin, xmax)
        } else {
          if type(item.extent) == array {
            (item.extent.at(0), item.extent.at(1))
          } else {
            (-item.extent, item.extent)
          }
        }

        let stroke_style = (
          paint: item.color,
          thickness: item.stroke_width,
          dash: if item.style == "dashed" { "dashed" } else if item.style == "dotted" { "dotted" } else { none },
        )

        if beta == 0 {
          // Horizontal line at ct = ct_val
          // Clip to viewport x-range
          let x0 = calc.max(xmin, x_start)
          let x1 = calc.min(xmax, x_end)

          if x0 < x1 {
            line((x0, ct_val), (x1, ct_val), stroke: stroke_style)
          }
        } else {
          // Tilted line: ct = beta*x + ct_val/gamma
          let g = gamma(beta)
          let ct_intercept = ct_val / g

          let p_start = (x_start, ct_intercept + beta * x_start)
          let p_end = (x_end, ct_intercept + beta * x_end)

          // We need to clip this segment to the viewport
          // Line eq: -beta*x + 1*y - ct_intercept = 0 => a=-beta, b=1, c=-ct_intercept
          // But we also have segment limits p_start, p_end (defined by extent)

          // First, get the line clipped to the box
          let seg = get_clipped_segment(-beta, 1.0, -ct_intercept)

          if seg != none {
            // Intersect viewport segment with extent segment
            // Since it's a line, we can just sort points by x
            // Extent points:
            let ex_x_min = calc.min(p_start.at(0), p_end.at(0))
            let ex_x_max = calc.max(p_start.at(0), p_end.at(0))

            // Viewport points:
            let vp_x_min = calc.min(seg.at(0).at(0), seg.at(1).at(0))
            let vp_x_max = calc.max(seg.at(0).at(0), seg.at(1).at(0))

            // Intersection
            let final_x_min = calc.max(ex_x_min, vp_x_min)
            let final_x_max = calc.min(ex_x_max, vp_x_max)

            if final_x_min < final_x_max {
              // Recompute y for these x's to be precise
              let y1 = ct_intercept + beta * final_x_min
              let y2 = ct_intercept + beta * final_x_max
              line((final_x_min, y1), (final_x_max, y2), stroke: stroke_style)
            }
          }
        }

        if item.label != none {
          content((xmax, ct_val), item.label, anchor: "west", padding: 0.2)
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
        if item.grid_stroke != none {
          let g = gamma(beta)
          let step = item.grid_spacing
          let g_stroke = item.grid_stroke

          // Compute global bounds in primed coordinates to determine range
          let corners = ((xmin, ctmin), (xmax, ctmin), (xmax, ctmax), (xmin, ctmax))
          let corners_prime = corners.map(p => lorentz_transform(p, beta))
          let xs_prime = corners_prime.map(p => p.at(0))
          let cts_prime = corners_prime.map(p => p.at(1))

          let xp_min = calc.min(..xs_prime)
          let xp_max = calc.max(..xs_prime)
          let ctp_min = calc.min(..cts_prime)
          let ctp_max = calc.max(..cts_prime)

          // Floor/Ceil to nearest step
          let i_start = calc.floor(xp_min / step) * step
          let i_end = calc.ceil(xp_max / step) * step

          let i = i_start
          while i <= i_end + 1e-6 {
            // Line x' = i => x - beta*ct - i/gamma = 0
            // a=1, b=-beta, c=-i/gamma
            if calc.abs(i) > 1e-4 {
              // Skip main axis
              let seg = get_clipped_segment(1.0, -beta, -i / g)
              if seg != none {
                line(seg.at(0), seg.at(1), stroke: g_stroke)
              }
            }
            i += step
          }

          let j_start = calc.floor(ctp_min / step) * step
          let j_end = calc.ceil(ctp_max / step) * step

          let j = j_start
          while j <= j_end + 1e-6 {
            // Line ct' = j => ct - beta*x - j/gamma = 0
            // a=-beta, b=1, c=-j/gamma
            if calc.abs(j) > 1e-4 {
              // Skip main axis
              let seg = get_clipped_segment(-beta, 1.0, -j / g)
              if seg != none {
                line(seg.at(0), seg.at(1), stroke: g_stroke)
              }
            }
            j += step
          }
        }

        // --- DRAW PRIMED AXES ---
        let stroke_style = (paint: item.color, thickness: item.stroke_width)

        // Equation for ct' axis: x' = 0 => x - beta*ct - (ox - beta*oct) = 0
        let ct_axis_c = -(ox - beta * oct)

        // Equation for x' axis: ct' = 0 => -beta*x + ct - (oct - beta*ox) = 0
        let x_axis_c = -(oct - beta * ox)

        // Check extent
        let ct_end_pt = none
        let x_end_pt = none

        if item.extent == auto {
          // Clip to viewport
          let ct_seg = get_clipped_segment(1.0, -beta, ct_axis_c)
          let x_seg = get_clipped_segment(-beta, 1.0, x_axis_c)

          if ct_seg != none {
            // Direction of ct' axis is (beta, 1)
            // Draw from p1 to p2. Check direction.
            let p1 = ct_seg.at(0)
            let p2 = ct_seg.at(1)
            let v = vec_sub(p2, p1)
            // Dot with (beta, 1)
            let dot = v.at(0) * beta + v.at(1) * 1.0
            if dot < 0 {
              line(p2, p1, stroke: stroke_style, mark: (end: "stealth", fill: item.color))
              ct_end_pt = p1
            } else {
              line(p1, p2, stroke: stroke_style, mark: (end: "stealth", fill: item.color))
              ct_end_pt = p2
            }
          }
          if x_seg != none {
            // Direction of x' axis is (1, beta)
            let p1 = x_seg.at(0)
            let p2 = x_seg.at(1)
            let v = vec_sub(p2, p1)
            // Dot with (1, beta)
            let dot = v.at(0) * 1.0 + v.at(1) * beta
            if dot < 0 {
              line(p2, p1, stroke: stroke_style, mark: (end: "stealth", fill: item.color))
              x_end_pt = p1
            } else {
              line(p1, p2, stroke: stroke_style, mark: (end: "stealth", fill: item.color))
              x_end_pt = p2
            }
          }
        } else {
          // Manual extent
          let (min_ext, max_ext) = if type(item.extent) == array {
            (item.extent.at(0), item.extent.at(1))
          } else {
            (-item.extent, item.extent)
          }

          // ct' axis direction vector (normalized geometric vector)
          let norm_ct = calc.sqrt(1 + calc.pow(beta, 2))
          // Unit vector for ct' direction (beta, 1) normalized
          let u_ct = (beta / norm_ct, 1.0 / norm_ct)

          let p_start = (ox + u_ct.at(0) * min_ext, oct + u_ct.at(1) * min_ext)
          let p_end = (ox + u_ct.at(0) * max_ext, oct + u_ct.at(1) * max_ext)

          // Draw ct' axis
          line(p_start, p_end, stroke: stroke_style, mark: (end: "stealth", fill: item.color))
          ct_end_pt = p_end

          // x' axis direction (1, beta) normalized
          let norm_x = calc.sqrt(1 + calc.pow(beta, 2))
          let u_x = (1.0 / norm_x, beta / norm_x)

          let p_start_x = (ox + u_x.at(0) * min_ext, oct + u_x.at(1) * min_ext)
          let p_end_x = (ox + u_x.at(0) * max_ext, oct + u_x.at(1) * max_ext)

          // Draw x' axis
          line(p_start_x, p_end_x, stroke: stroke_style, mark: (end: "stealth", fill: item.color))
          x_end_pt = p_end_x
        }

        // Labels
        let def_ct_prime = if natural_units { $t'$ } else { $c t'$ }
        let ct_label = if item.ctlabel == auto { def_ct_prime } else { item.ctlabel }
        let x_label = if item.xlabel == auto { $x'$ } else { item.xlabel }

        if ct_end_pt != none {
          content(ct_end_pt, text(fill: item.color, ct_label), anchor: "south-west", padding: 0.15)
        }
        if x_end_pt != none {
          content(x_end_pt, text(fill: item.color, x_label), anchor: "south-west", padding: 0.15)
        }
      }
    }

    // Draw worldlines
    for item in items {
      if item.type == "worldline" {
        let pts = item.points.map(p => resolve_pos(p))

        let dash = if item.style == "dashed" { "dashed" } else if item.style == "dotted" { "dotted" } else { none }
        let stroke_style = (paint: item.color, thickness: item.stroke_width, dash: dash)

        if pts.len() >= 2 {
          if item.wl_type == "light" {
            // Draw at 45° regardless of actual endpoints
            // This is for indicating a light ray direction
            line(..pts, stroke: (paint: item.color, thickness: item.stroke_width, dash: "loosely-dashed"))
          } else {
            line(..pts, stroke: stroke_style)
          }

          // Draw label at midpoint
          if item.label != none {
            let idx = int(item.label_pos * (pts.len() - 1))
            let p = pts.at(idx)
            let anchor = if item.label_anchor == "auto" { "east" } else { item.label_anchor }
            content(p, text(fill: item.color, item.label), anchor: anchor, padding: 0.2)
          }
        }
      }
    }

    // Draw main axes (if enabled)
    if show_axes {
      let stroke_style = (paint: axes_color, thickness: axes_stroke)

      // x-axis
      line((xmin, 0), (xmax, 0), stroke: stroke_style, mark: (end: "stealth", fill: axes_color))
      content((xmax, 0), xlabel, anchor: "north-west", padding: 0.15)

      // ct-axis
      line((0, ctmin), (0, ctmax), stroke: stroke_style, mark: (end: "stealth", fill: axes_color))
      content((0, ctmax), final_ctlabel, anchor: "south-east", padding: 0.15)
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
          let anchor = if item.label_anchor == "auto" { "south-west" } else { item.label_anchor }
          let fill_color = if item.label_color != auto { item.label_color } else { item.color }
          content(pos, text(fill: fill_color, item.label), anchor: anchor, padding: item.label_padding)
        }
      }
    }
  })
}
