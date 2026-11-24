// polar.typ - Polar/radial drawing primitives for circular charts

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

/// Places a label at polar coordinates with automatic quadrant-aware alignment.
/// Left-side labels right-align (text ends at the point), right-side labels
/// left-align (text starts at the point), top/bottom labels center.
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - angle-deg (float): Angle in degrees (0 = right, 90 = down, -90 = up)
/// - r (length): Distance from center to label anchor
/// - body (content): Label content
/// - box-width (length): Width of the alignment box
/// -> content
#let place-polar-label(cx, cy, angle-deg, r, body, box-width: 4em) = {
  let a = angle-deg * 1deg
  let cos-val = calc.cos(a)
  let sin-val = calc.sin(a)
  let lx = cx + r * cos-val
  let ly = cy + r * sin-val

  // Horizontal: left-side labels shift box left so right edge meets anchor
  let dx-adj = if cos-val < -0.1 { -box-width }
               else if cos-val > 0.1 { 0em }
               else { -box-width / 2 }
  let h-align = if cos-val < -0.1 { right }
                else if cos-val > 0.1 { left }
                else { center }

  // Vertical: top labels sit below anchor, bottom labels above, middle centered
  let v-shift = if sin-val < -0.1 { 0em }
                else if sin-val > 0.1 { -1em }
                else { -0.5em }

  place(left + top, dx: lx, dy: ly,
    move(dx: dx-adj, dy: v-shift,
      box(width: box-width, align(h-align, body))))
}

/// Places a filled circle that masks the center of a donut/ring chart.
/// Uses theme background color if set, otherwise white.
///
/// - cx (length): Center x
/// - cy (length): Center y
/// - r (length): Radius of the hole
/// - theme (dictionary): Resolved theme
/// -> content
#let place-donut-hole(cx, cy, r, theme) = {
  let fill-color = if theme.background != none { theme.background } else { white }
  place(left + top, dx: cx - r, dy: cy - r,
    circle(radius: r, fill: fill-color, stroke: none))
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
