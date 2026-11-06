// =====================================================
// CALCULUS - Analysis and visualization tools
// =====================================================

#import "../shape/point.typ": point
#import "../shape/line.typ": segment

/// Calculate numerical derivative of f at x
/// Uses symmetric difference quotient for better accuracy
#let derivative-at(f, x, h: 1e-5) = {
  (f(x + h) - f(x - h)) / (2 * h)
}

/// Create a tangent line to function f at x
///
/// Parameters:
/// - f: The function
/// - x: The x-coordinate for the tangent
/// - length: Length of the drawn tangent line (default: 2)
/// - label: Optional label
/// - style: Style overrides
#let tangent(f, x, length: 2, label: none, style: auto) = {
  let y = f(x)
  let m = derivative-at(f, x) // slope

  let dx = length / 2
  let x1 = x - dx
  let y1 = y - m * dx
  let x2 = x + dx
  let y2 = y + m * dx

  segment(point(x1, y1), point(x2, y2), label: label, style: style)
}

/// Create a normal line to function f at x
///
/// Parameters:
/// - f: The function
/// - x: The x-coordinate
/// - length: Length of drawn line
/// - label: Optional label
/// - style: Style overrides
#let normal(f, x, length: 2, label: none, style: auto) = {
  let y = f(x)
  let m-tangent = derivative-at(f, x)

  if calc.abs(m-tangent) < 1e-10 {
    // Horizontal tangent, vertical normal
    let dy = length / 2
    segment(point(x, y - dy), point(x, y + dy), label: label, style: style)
  } else {
    let m = -1 / m-tangent
    let dx = length / calc.sqrt(1 + m * m)
    let x1 = x - dx
    let y1 = y - m * dx
    let x2 = x + dx
    let y2 = y + m * dx

    segment(point(x1, y1), point(x2, y2), label: label, style: style)
  }
}

/// Create Riemann Sum rectangles for visualization
///
/// Parameters:
/// - f: Function to integrate
/// - domain: (start, end) tuple
/// - n: Number of rectangles
/// - method: "left", "right", "midpoint", or "trapezoid"
/// - label: Label for the area
/// - style: Style overrides (fill color, stroke)
/// - smooth: If true, hide interior strokes for clean integral visualization
#let riemann-sum(f, domain, n, method: "left", label: none, style: auto, smooth: false) = {
  let (a, b) = domain
  let dx = (b - a) / n
  let rects = ()
  let max-height = 0

  // Determine if we should draw interior strokes
  let draw-interior = not smooth

  for i in range(n) {
    let x0 = a + i * dx
    let x1 = a + (i + 1) * dx

    let height = if method == "left" {
      f(x0)
    } else if method == "right" {
      f(x1)
    } else if method == "midpoint" {
      f((x0 + x1) / 2)
    } else {
      0
    }

    // Track max height for label positioning
    if height > max-height { max-height = height }

    // For smooth integrals, only stroke the outline
    let rect-style = if draw-interior {
      style
    } else {
      // Only draw top edge, suppress left/right/bottom strokes
      if style != auto and "stroke" in style {
        (stroke: if i == 0 or i == n - 1 { style.stroke } else { none })
      } else {
        (stroke: none)
      }
    }

    if method == "trapezoid" {
      let y0 = f(x0)
      let y1 = f(x1)
      let trap-max = calc.max(y0, y1)
      if trap-max > max-height { max-height = trap-max }

      rects.push((
        type: "polygon",
        points: (point(x0, 0), point(x0, y0), point(x1, y1), point(x1, 0)),
        label: none,
        style: rect-style,
        fill: if style != auto and "fill" in style { style.fill } else { auto },
      ))
    } else {
      // Rectangle polygon
      rects.push((
        type: "polygon",
        points: (point(x0, 0), point(x0, height), point(x1, height), point(x1, 0)),
        label: none,
        style: rect-style,
        fill: if style != auto and "fill" in style { style.fill } else { auto },
      ))
    }
  }

  // Add centered label above the Riemann sum using a custom point
  if label != none {
    let center-x = (a + b) / 2
    let label-y = max-height * 1.05 // 5% above the tallest rectangle
    rects.push((
      type: "point",
      x: center-x,
      y: label-y,
      label: label,
      style: (
        radius: 0,
        fill: none,
        stroke: none,
      ),
    ))
  }

  rects
}

