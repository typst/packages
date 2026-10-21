// =====================================================
// FUNC - Function plotting with robust adaptive sampling
// =====================================================
// This module implements the algorithm for handling functions
// with singularities like sin(π/x) by detecting oscillations
// and drawing envelope bars instead of misleading lines.

#import "../shape/point.typ": point

// =====================================================
// Robust Adaptive Sampling Algorithm
// =====================================================

/// Helper: Check if value is valid (and reasonably bounded)
/// Values beyond ±100 are likely off-screen — typical plots are -20 to 20
#let is-valid(val) = {
  val != none and val == val and val != calc.inf and val != -calc.inf and calc.abs(val) < 100
}

/// Helper: Safely evaluate function, returning none for errors
#let safe-eval(f, x) = {
  // Skip x=0 if it might cause issues (very common singularity)
  let eps = 1e-10

  // Try to evaluate - if x is extremely small, it might cause division issues
  if calc.abs(x) < eps {
    return none
  }

  // Evaluate the function
  let y = f(x)

  // Check if result is valid
  if is-valid(y) {
    y
  } else {
    none
  }
}



/// Adaptive sampler based on slope change (curvature)
/// Starts from left, adjusting step size based on the "change rate of the current slope"
/// Uses a refinement limit to prevent infinite subdivision in highly oscillatory regions
/// Adaptive sampler using recursive subdivision
/// Handles singularities, oscillations, and domain gaps seamlessly.
#let adaptive-sample(f, x-min, x-max, y-min: auto, y-max: auto, samples: 200, tolerance: 0.5) = {
  // 1. Setup constants
  let range-width = x-max - x-min
  let min-step = range-width / 1e5 // Machine precision limit for zoom
  let max-depth = 12 // Recursion depth limit (2^12 = 4096 segments worst case)

  // 2. Helper: Safe Evaluation
  let safe-eval(x) = {
    if calc.abs(x) < 1e-12 { return none } // Strict zero avoidance
    let y = f(x)

    let is_y_valid = if y != none and y == y and y != calc.inf and y != -calc.inf {
      let y_min_val = if y-min == auto { -100 } else { y-min }
      let y_max_val = if y-max == auto { 100 } else { y-max }
      y >= y_min_val and y <= y_max_val
    } else {
      false
    }

    if is_y_valid { y } else { none }
  }

  // 3. Helper: Generate Dense Envelope (for oscillations)
  // Creates a zig-zag fill for a segment [x1, x2]
  let generate-envelope(x1, x2) = {
    let pts = ()
    let steps = 10
    let dx = (x2 - x1) / steps
    for i in range(steps + 1) {
      let x = x1 + dx * i
      let y = safe-eval(x)
      if y != none { pts.push((x, y)) }
    }
    pts
  }

  // 4. Recursive Sampler
  // Returns an array of points for the segment [x1, x2]
  let rec-sample(x1, y1, x2, y2, depth) = {
    let xm = (x1 + x2) / 2
    let ym = safe-eval(xm)

    // A. Handle Singularity / Invalid Midpoint
    if ym == none {
      // If midpoint is invalid, we might be crossing an asymptote or domain hole.
      // Try to zoom in recursively to find the edge, but don't go too deep.
      if depth < max-depth {
        return rec-sample(x1, y1, xm, ym, depth + 1) + (none,) + rec-sample(xm, ym, x2, y2, depth + 1)
      } else {
        return (none,)
      }
    }

    // B. Handle Endpoints being invalid (should be handled by caller, but safety check)
    if y1 == none or y2 == none {
      // Deep recursion to find valid boundary?
      // For simplicity, if we are deep and still invalid, just return what we have.
      if depth < max-depth {
        return rec-sample(x1, y1, xm, ym, depth + 1) + ((xm, ym),) + rec-sample(xm, ym, x2, y2, depth + 1)
      }
      return ((xm, ym),)
    }

    // C. Check Flatness / Curvature
    // Simple linearity check: is the midpoint close to the line connect P1 and P2?
    // Or angle check.
    // Let's use simple distance tolerance for now, normalized by step size.

    // Line P1-P2: y - y1 = m(x - x1) -> mx - y + (y1 - mx1) = 0
    // Distance of Pm to line.
    let den = x2 - x1
    let val-est = y1 + (y2 - y1) * (xm - x1) / den
    let err = calc.abs(ym - val-est)

    // Acceptance criteria
    if err < tolerance or depth >= max-depth {
      // If we hit depth limit and error is still HUGE, it's an oscillation.
      // Generate a dense envelope for this tiny segment to fill it.
      if depth >= max-depth and err > tolerance * 10 {
        return generate-envelope(x1, x2)
      }
      return ((xm, ym),) // Return midpoint
    }

    // D. Split
    return rec-sample(x1, y1, xm, ym, depth + 1) + ((xm, ym),) + rec-sample(xm, ym, x2, y2, depth + 1)
  }

  // 5. Initial Sampling Points
  // Start with uniform initial points to seed the recursion
  // This prevents missing features entirely if they fall between x-min and x-max.
  let init-steps = int(samples) // Use full sample count for seed to avoid aliasing high-freq
  let step-size = range-width / init-steps

  let points = ()

  for i in range(init-steps) {
    let x1 = x-min + i * step-size
    let x2 = x1 + step-size
    // Ensure we hit x-max exactly on last step
    if i == init-steps - 1 { x2 = x-max }

    let y1 = safe-eval(x1)
    let y2 = safe-eval(x2)

    // Add start point of segment if it's the very first point or after a break
    if i == 0 or points.len() == 0 or points.last() == none {
      if y1 != none { points.push((x1, y1)) }
    }

    // Recursively fill segment
    // Note: rec-sample returns INTERIOR points. We append them.
    // We do NOT add x2 here, the next iteration (or end) will add it.

    // Logic:
    // If y1, y2 both valid: standard recurse.
    // If one invalid: still recurse to find edge.
    // If both invalid: might be empty space, but recurse once to check middle?

    if y1 != none or y2 != none {
      let seg-pts = rec-sample(x1, y1, x2, y2, 0)
      points += seg-pts
    } else {
      // Both endpoints invalid. Check middle just in case feature is entirely inside.
      let xm = (x1 + x2) / 2
      let ym = safe-eval(xm)
      if ym != none {
        // Found something! Recurse.
        points += rec-sample(x1, y1, x2, y2, 0)
      } else {
        // Empty segment.
        points.push(none)
      }
    }

    // Add end point of segment (which is start of next)
    if y2 != none {
      points.push((x2, y2))
    } else {
      points.push(none)
    }
  }

  // 6. Gap Filling (Bleed) logic
  // "Probe" the edges to see if they are volatile (singularity/oscillation)
  let bleed = range-width * 0.005

  // Robust Edge Checker
  let check-edge-and-fill = (pts, is-start) => {
    let limit-idx = if is-start { 0 } else { pts.len() - 1 }
    // Find the edge point
    let valid-edge-pt = none
    if is-start {
      // Search forward
      for p in pts {
        if p != none {
          valid-edge-pt = p
          break
        }
      }
    } else {
      // Search backward
      for i in range(pts.len() - 1, -1, step: -1) {
        if pts.at(i) != none {
          valid-edge-pt = pts.at(i)
          break
        }
      }
    }

    if valid-edge-pt == none { return pts } // Empty plot

    // Check if this point is actually at the requested domain edge (within tolerance)
    let edge-target = if is-start { x-min } else { x-max }
    if calc.abs(valid-edge-pt.at(0) - edge-target) > range-width * 0.01 {
      return pts // Edge is far from requested domain (clipped?), don't bleed
    }

    // PROBE: Sample densely a tiny region *inwards* from the edge
    // to determine behavior.
    let probe-count = 10
    let probe-width = range-width * 0.001 // Look at 0.1% of domain
    let dx = probe-width / probe-count
    let probe-pts = ()
    let direction = if is-start { 1 } else { -1 } // 1 = x increasing (inwards from min), -1 = x decreasing (inwards from max)

    // Collect probe statistics
    let min-y = valid-edge-pt.at(1)
    let max-y = valid-edge-pt.at(1)
    let max-slope = 0.0

    for i in range(1, probe-count + 1) {
      let x = valid-edge-pt.at(0) + dx * i * direction
      let y = safe-eval(x)
      if y != none {
        probe-pts.push(y)
        if y < min-y { min-y = y }
        if y > max-y { max-y = y }

        // Check slope relative to edge
        let run = calc.abs(x - valid-edge-pt.at(0))
        let rise = calc.abs(y - valid-edge-pt.at(1))
        if run > 0 {
          let s = rise / run
          if s > max-slope { max-slope = s }
        }
      }
    }

    // DECISION: Trigger bleed if:
    // 1. Slope is massive (Asymptote or fast oscillation)
    // 2. OR significant amplitude in tiny window (Oscillation near extremum where slope might be 0)

    let slope-thresh = 1000.0
    let amp-thresh = 0.1 // If we move 0.1 units y in 0.001 units x, that's steep!

    // Actually, amp 0.1 in width 0.001 IS slope 100.
    // Let's stick to slope threshold, but max-slope covers the "peak" case
    // because near a peak, slope is low, but slightly further away it's high.
    // With 10 probe points, we'll catch the steep part of the wave.

    if max-slope > slope-thresh {
      // Generate Bleed Box
      let x-edge = valid-edge-pt.at(0)
      let x-out = x-edge - bleed * direction // Outwards (opposite to scan dir)

      let box = ((x-edge, min-y), (x-out, min-y), (x-out, max-y), (x-edge, max-y))

      if is-start {
        return box + pts
      } else {
        return pts + box
      }
    }
    return pts
  }

  // Apply checks
  points = check-edge-and-fill(points, true)
  points = check-edge-and-fill(points, false)

  // 7. Filter clean
  // Remove adjacent nones, ensure valid struct
  let result = ()
  let last-none = false
  for p in points {
    if p == none {
      if not last-none {
        result.push(none)
        last-none = true
      }
    } else {
      result.push(p)
      last-none = false
    }
  }
  result
}

// =====================================================
// Function Object
// =====================================================

/// Create a function object for plotting
///
/// Parameters:
/// - f: The function (x => y for standard, t => (x, y) for parametric)
/// - domain: Input domain as (min, max)
/// - func-type: "standard" (y=f(x)), "parametric", or "polar"
/// - samples: Number of samples for uniform sampling (if not robust)
/// - robust: If true, use adaptive sampling for singularity handling
/// - label: Optional label for legend
/// - style: Optional style overrides (stroke color, thickness)
#let func(
  f,
  domain: (-5, 5),
  func-type: "standard",
  samples: 200,
  adaptive: true,
  hole: (),
  filled-hole: (),
  label: none,
  style: auto,
) = {
  // Compute cached points if robust mode
  let cached = if adaptive and func-type == "standard" {
    adaptive-sample(f, domain.at(0), domain.at(1), samples: samples)
  } else {
    none
  }

  (
    type: "func",
    f: f,
    domain: domain,
    func-type: func-type,
    samples: samples,
    robust: adaptive,
    hole: hole,
    filled-hole: filled-hole,
    label: label,
    style: style,
    cached-points: cached,
  )
}

#let graph(f, domain: (-5, 5), samples: 200, adaptive: true, hole: (), filled-hole: (), label: none, style: auto) = {
  func(
    f,
    domain: domain,
    func-type: "standard",
    samples: samples,
    adaptive: adaptive,
    hole: hole,
    filled-hole: filled-hole,
    label: label,
    style: style,
  )
}



/// Create a parametric curve
/// f should be: t => (x, y)
#let parametric(f, domain: (0, 2 * calc.pi), samples: 200, label: none, style: auto) = {
  func(f, domain: domain, func-type: "parametric", samples: samples, label: label, style: style)
}

/// Create a polar curve
/// r-func should be: θ => r
#let polar-func(r-func, domain: (0, 2 * calc.pi), samples: 200, label: none, style: auto) = {
  // Convert polar to parametric internally
  let f = t => {
    let r = r-func(t)
    (r * calc.cos(t), r * calc.sin(t))
  }
  func(f, domain: domain, func-type: "parametric", samples: samples, label: label, style: style)
}

/// Create a function using Lagrangian interpolation
/// Constructs a polynomial that passes through all given points
///
/// Parameters:
/// - ..points: Variable number of arrays of length 2, each representing (x, y) coordinates
/// - domain: Input domain as (min, max) - defaults to min/max x of points with 20% padding
/// - samples: Number of samples for uniform sampling
/// - adaptive: If true, use adaptive sampling for singularity handling
/// - label: Optional label for legend
/// - style: Optional style overrides (stroke color, thickness)
///
/// Example:
/// ```typ
/// #lagrangian-interpolation((0, 1), (1, 2), (2, 5))
/// ```
#let lagrangian-interpolation(
  ..points,
  domain: auto,
  samples: 200,
  adaptive: true,
  label: none,
  style: auto,
) = {
  // Extract point arrays
  let pts = points.pos()
  
  // Validate: need at least 2 points
  if pts.len() < 2 {
    panic("lagrangian-interpolation requires at least 2 points")
  }
  
  // Validate: each point must be array of length 2
  for (i, pt) in pts.enumerate() {
    if type(pt) != array or pt.len() != 2 {
      panic("Point " + str(i) + " must be an array of length 2: (x, y)")
    }
  }
  
  // Extract x and y coordinates
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  
  // Check for duplicate x values (would make interpolation undefined)
  for i in range(xs.len()) {
    for j in range(i + 1, xs.len()) {
      if calc.abs(xs.at(i) - xs.at(j)) < 1e-10 {
        panic("Duplicate x values found: x = " + str(xs.at(i)))
      }
    }
  }
  
  // Determine domain if auto
  let (x-min, x-max) = if domain == auto {
    let min-x = calc.min(..xs)
    let max-x = calc.max(..xs)
    let padding = (max-x - min-x) * 0.2
    (min-x - padding, max-x + padding)
  } else {
    domain
  }
  
  // Build Lagrangian interpolation polynomial
  // L(x) = Σ(i=0 to n-1) y_i * Π(j≠i) (x - x_j) / (x_i - x_j)
  let lagrangian-poly = x => {
    let result = 0.0
    let n = pts.len()
    
    for i in range(n) {
      let x_i = xs.at(i)
      let y_i = ys.at(i)
      
      // Compute the basis polynomial for point i
      let basis = 1.0
      for j in range(n) {
        if i != j {
          let x_j = xs.at(j)
          basis = basis * (x - x_j) / (x_i - x_j)
        }
      }
      
      result = result + y_i * basis
    }
    
    result
  }
  
  // Create function object
  func(
    lagrangian-poly,
    domain: (x-min, x-max),
    func-type: "standard",
    samples: samples,
    adaptive: adaptive,
    label: label,
    style: style,
  )
}

/// Check if object is a function
#let is-func(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "func"
}


