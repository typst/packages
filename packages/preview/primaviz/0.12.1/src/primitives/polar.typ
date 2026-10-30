// polar.typ - Polar/radial drawing primitives for circular charts
//
// Geometry only: points, wedges, rings. Label placement lives in
// polar-labels.typ, frame/legend sizing in radial.typ.

/// Returns an array of (x, y) points approximating an arc.
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - r (length): Radius
/// - start-deg (float): Start angle in degrees
/// - end-deg (float): End angle in degrees
/// - steps (auto, int): Number of line segments; auto computes from arc span
/// -> array
#let arc-points(cx, cy, r, start-deg, end-deg, steps: auto) = {
  let span = end-deg - start-deg
  let n = if steps == auto { calc.max(int(calc.abs(span) / 5), 3) } else { steps }
  array.range(n + 1).map(s => {
    let a = (start-deg + span * s / n) * 1deg
    (cx + r * calc.cos(a), cy + r * calc.sin(a))
  })
}

/// The point at `r` from the centre in direction `deg`
/// (0 = right, 90 = down, -90 = up).
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - r (length): Distance from the centre
/// - deg (float): Angle in degrees
/// -> array
#let polar-pt(cx, cy, r, deg) = (cx + r * calc.cos(deg * 1deg), cy + r * calc.sin(deg * 1deg))

/// Returns polygon points for a pie slice (center + outer arc).
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - r (length): Radius
/// - start-deg (float): Start angle in degrees
/// - end-deg (float): End angle in degrees
/// -> array
#let pie-slice-points(cx, cy, r, start-deg, end-deg) = {
  let span = end-deg - start-deg
  let steps = calc.max(int(calc.abs(span) / 3), 3)
  ((cx, cy),) + arc-points(cx, cy, r, start-deg, end-deg, steps: steps)
}

/// Returns polygon points for a filled annular wedge (donut slice).
/// Outer arc runs start→end, inner arc runs end→start.
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - r-inner (length): Inner radius
/// - r-outer (length): Outer radius
/// - start-deg (float): Start angle in degrees
/// - end-deg (float): End angle in degrees
/// -> array
#let annular-wedge-points(cx, cy, r-inner, r-outer, start-deg, end-deg) = {
  let outer = arc-points(cx, cy, r-outer, start-deg, end-deg)
  let inner = arc-points(cx, cy, r-inner, end-deg, start-deg)
  outer + inner
}

/// Draws one wedge: a pie slice (`r-inner` = 0) or a donut/ring segment.
///
/// A sweep of a full turn is drawn as a circle or a thick-stroked circle,
/// not a polygon, so it has no seam where its two ends meet. Nothing is
/// drawn for an empty sweep, so a zero value leaves no stray hairline.
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - r-inner (length): Inner radius (0 for a pie slice)
/// - r-outer (length): Outer radius
/// - start-deg (float): Start angle in degrees
/// - end-deg (float): End angle in degrees
/// - fill (color): Fill
/// - stroke (stroke): Outline (the separator between neighbours)
/// -> content
#let place-wedge(cx, cy, r-inner, r-outer, start-deg, end-deg, fill, stroke: none) = {
  let span = calc.abs(end-deg - start-deg)
  if span < 0.01 or r-outer <= r-inner {
    none
  } else if span >= 359.99 and r-inner <= 0pt {
    place(left + top, dx: cx - r-outer, dy: cy - r-outer,
      circle(radius: r-outer, fill: fill, stroke: stroke))
  } else if span >= 359.99 {
    let rm = (r-inner + r-outer) / 2
    place(left + top, dx: cx - rm, dy: cy - rm,
      circle(radius: rm, fill: none, stroke: (r-outer - r-inner) + fill))
  } else {
    let pts = if r-inner <= 0pt { pie-slice-points(cx, cy, r-outer, start-deg, end-deg) }
      else { annular-wedge-points(cx, cy, r-inner, r-outer, start-deg, end-deg) }
    place(left + top, polygon(fill: fill, stroke: stroke, ..pts))
  }
}

/// Draws a band along a circle (a progress ring, a gauge dial): a filled
/// annular sector, optionally with round ends. A single filled shape, so
/// unlike a chain of thick line segments it has no seams or ticks.
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - r (length): Radius of the band's centre line
/// - width (length): Band thickness
/// - start-deg (float): Start angle in degrees
/// - end-deg (float): End angle in degrees
/// - fill (color): Fill
/// - round (bool): Round both ends
/// -> content
#let place-arc-band(cx, cy, r, width, start-deg, end-deg, fill, round: false) = {
  place-wedge(cx, cy, calc.max(0pt, r - width / 2), r + width / 2, start-deg, end-deg, fill)
  let span = calc.abs(end-deg - start-deg)
  if round and span > 0.01 and span < 359.99 {
    for deg in (start-deg, end-deg) {
      let (x, y) = polar-pt(cx, cy, r, deg)
      place(left + top, dx: x - width / 2, dy: y - width / 2,
        circle(radius: width / 2, fill: fill, stroke: none))
    }
  }
}

/// Returns the separator stroke for adjacent filled segments.
/// Uses theme background if set (blends with page), otherwise white.
///
/// - theme (dictionary): Resolved theme
/// - thickness (length): Stroke width
/// -> stroke
#let separator-stroke(theme, thickness: 0.5pt) = {
  let color = if theme.background != none { theme.background } else { white }
  thickness + color
}
