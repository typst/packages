// ctz-euclide/src/drawing/clipping.typ
// Line clipping functions (Cohen-Sutherland algorithm)

#import "@preview/cetz:0.4.2" as cetz
#import "../util.typ"

// =============================================================================
// CLIP REGION STATE
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

// =============================================================================
// COHEN-SUTHERLAND LINE CLIPPING
// =============================================================================

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

// =============================================================================
// CLIPPED DRAWING FUNCTIONS
// =============================================================================

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

    if len < util.eps-visual { return }

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

      if len < util.eps-visual { return }

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
